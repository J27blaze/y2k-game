extends PlayerState

var initial_dir: Vector3
var move_dir: Vector3

var timer: int = 0
var perfect_slided: bool = false

var slide_timer: int = 0

@onready var input_delay := $input_delay
var can_input: bool = false

@onready var cancel_delay := $cancel_delay
var can_cancel: bool = false

func start():
	print("slide")
	
	player.jump_stage = 0
	
	#MODEL TWIST
	target_vel_dir = atan2(player.velocity.x, player.velocity.z) + -PI
	target_player_dir = 0
	
	can_cancel = false
	can_input = false
	input_delay.start()
	cancel_delay.start()
	
	perfect_slided = false
	slide_timer = 0
	
	initial_dir = player.hor_velocity
	player.target_speed = clampf(player.speed, player.slide_min_speed, 999999)
	move_dir = initial_dir.normalized() * player.target_speed
	
	play_anim_blend("slide", 3, 4, 1)

func always_process_physics(delta : float):
	if player.is_on_floor():
		if timer <= player.perfect_slide_after_frame_window:
			timer += 1
	else:
		timer = 0
	#print(timer)

func exit():
	player.speed = player.target_speed
	input_delay.stop()
	cancel_delay.stop()
	can_cancel = false
	can_input = false
	
	player.model_twist_override_angle = -999
	player.model_pitch = 0

var target_player_dir: float = 0.0
var target_vel_dir: float = 0.0
@export_range(0, 8, 0.05) var model_twist_smoothing: float = 4.0
@export_range(4, 16, 0.05) var model_twist_smoothing2: float = 4.0
@export_range(0, 3.14, 0.05) var model_twist_clamp: float = 1

func process_frame(delta: float):
	var vel_dir: float = atan2(player.velocity.x, player.velocity.z) + -PI
	var player_dir: float = player.hor_velocity.signed_angle_to(player.direction, Vector3.UP)
	player_dir = clampf(player_dir, -model_twist_clamp, model_twist_clamp)
	
	target_vel_dir = lerp_angle(target_vel_dir, vel_dir, model_twist_smoothing2 * delta)
	target_player_dir = lerp_angle(target_player_dir, player_dir, model_twist_smoothing * delta)
	
	player.model_twist_override_angle = target_vel_dir + target_player_dir
	
func process_physics(delta: float):
	if !Input.is_action_pressed("slide") && can_cancel:
		change_state("run")
		return
	if can_input:
		if player.state_jump():
			return
		if player.state_dodge_check():
			return
		if player.state_weapon_dash_check():
			return
		
	player.hit_check()
	if player.state_tumble_check():
		return
	
	#perfect slide / start slide
	if !perfect_slided && input_handler.is_action_buffered("slide") && timer < player.perfect_slide_after_frame_window:
		perfect_slide()
		#print("perfect")
	if slide_timer > player.slide_friction_start_time:
		move_dir *= player.slide_friction
	#floor_accel *= player.slide_friction
	
	# Calculate tangent of the slope angle
	var floor_accel: Vector3 = Vector3.ZERO
	var floor_normal: Vector3 = player.floor_normal
	#var floor_tan: Vector3 = (floor_normal - Vector3.UP).normalized()
	
	#tangent
	var ref_axis := Vector3.UP
	var right_vector := floor_normal.cross(ref_axis).normalized()
	var floor_tan := right_vector.cross(floor_normal).normalized() * -1
	#if abs(floor_normal.dot(ref_axis)) > 0.99:
	#	ref_axis = Vector3.FORWARD # axis if on a perfectly flat surface
	
	var floor_hor_tan: Vector3 = Vector3(floor_tan.x, 0, floor_tan.z).normalized()
	var floor_hor_tan_scale: float = floor_tan.y * -player.slide_tangent_scaling
	
	var incline: bool = player.velocity.dot(floor_normal) > 0
	
	if player.speed < player.slide_tangent_max_speed:
		floor_accel = floor_hor_tan * delta * floor_hor_tan_scale
	else:
		floor_accel = floor_hor_tan * delta * floor_hor_tan_scale * player.slide_tangent_max_speed_slow 
	
	#print(floor_hor_tan)
	player.model_pitch = floor_tan.y * (int(incline) * 2 - 1)
	
	move_dir += floor_accel
	
	#slide handling
	var angle = rad_to_deg(move_dir.signed_angle_to(player.direction, Vector3.UP))
	angle = clampf(angle, -player.slide_handling, player.slide_handling)
	#dir_angle = lerp_angle(dir_angle, -angle, player.slide_handling * delta)
	move_dir = move_dir.rotated(Vector3.UP, deg_to_rad(angle))
	#print(angle)
	#print(scaled_floor_accel.length())
	
	player.vel_move_toward(move_dir, 999999, delta)
	player.target_speed = move_dir.length()
	slide_timer += 1
	
	if !player.is_on_floor():
		change_state("fall")
		return
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + move_dir *0.5, Color.ORANGE)
	
	const ds: float = 1
	DebugDraw3D.draw_line(player.centre, player.centre + floor_tan * ds, Color.RED)
	#DebugDraw3D.draw_line(player.centre, player.centre + Vector3.UP * floor_hor_tan_scale * ds, Color.RED)
	DebugDraw3D.draw_line(player.centre, player.centre + floor_hor_tan * ds, Color.PINK)
	DebugDraw3D.draw_line(player.centre, player.centre + floor_normal * ds, Color.BLUE)

func perfect_slide():
	var calc_speed = initial_dir.length() + (player.perfect_slide_speed_boost * player.perfect_slide_speed_boost_scaling.sample(player.speed))
	
	player.target_speed = calc_speed
	move_dir = initial_dir.normalized() * player.target_speed
	
	perfect_slided = true
	
	print("perfect slide")
	play_anim("slide", 3)

func _on_input_delay_timeout() -> void:
	can_input = true

func _on_cancel_delay_timeout() -> void:
	can_cancel = true
