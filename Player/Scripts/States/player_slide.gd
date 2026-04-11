extends PlayerState

var initial_dir: Vector3
var move_dir: Vector3
var timer: int = 0
var perfect_slided: bool = false
var floor_accel: Vector3 = Vector3.ZERO

var slide_timer: int = 0

func start():
	print("slide")
	
	perfect_slided = false
	slide_timer = 0
	floor_accel = Vector3.ZERO
	
	initial_dir = player.hor_velocity
	player.target_speed = clampf(player.speed, player.slide_min_speed, 999999)
	move_dir = initial_dir.normalized() * player.target_speed
	
	play_anim("slide")

func always_process_physics(delta: float):
	if player.is_on_floor():
		if timer <= player.perfect_slide_after_frame_window:
			timer += 1
	else:
		timer = 0
	#print(timer)

func exit():
	player.speed = player.target_speed

func process_physics(delta: float):
	if input_handler.is_action_buffered("jump") && player.can_jump:
		change_state("jump")
		return
	if Input.is_action_just_released("slide"):
		change_state("run")
		return
	player.state_dodge_check()
	
	if !perfect_slided && input_handler.is_action_buffered("slide") && timer < player.perfect_slide_after_frame_window:
		perfect_slide()
	if slide_timer > player.slide_friction_start_time:
		move_dir *= player.slide_friction
	floor_accel *= player.slide_friction
	
	# Calculate tangent of the slope angle
	var floor_normal: Vector3 = player.floor_normal
	var floor_tan: Vector3 = (floor_normal - Vector3.UP).normalized()
	var floor_hor_tan: Vector3 = Vector3(floor_tan.x, 0, floor_tan.z).normalized()
	
	var scaled_floor_accel: Vector3
	if player.speed < player.slide_tangent_max_speed:
		floor_accel += floor_hor_tan * player.slide_tangent_scaling * delta
	else:
		floor_accel += floor_hor_tan * player.slide_tangent_scaling * delta * player.slide_tangent_max_speed_slow
	
	scaled_floor_accel = floor_accel
	
	#slide handling
	var angle = rad_to_deg(move_dir.signed_angle_to(player.direction, Vector3.UP))
	angle = clampf(angle, -player.slide_handling, player.slide_handling)
	move_dir = move_dir.rotated(Vector3.UP, deg_to_rad(angle))
	#print(angle)
	#print(scaled_floor_accel.length())
	
	var final_move_dir: Vector3 = move_dir + scaled_floor_accel
	player.vel_move_toward(final_move_dir, 999999, delta)
	player.target_speed = final_move_dir.length()
	slide_timer += 1
	
	if !player.is_on_floor():
		change_state("fall")
		return
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	DebugDraw3D.draw_line(player.centre, player.centre +floor_tan * 2, Color.RED)
	DebugDraw3D.draw_line(player.centre, player.centre +floor_hor_tan * 2, Color.PINK)
	DebugDraw3D.draw_line(player.centre, player.centre + floor_normal * 1, Color.BLUE)

func perfect_slide():
	var calc_speed = initial_dir.length() + (player.perfect_slide_speed_boost * player.perfect_slide_speed_boost_scaling.sample(player.target_speed - player.slide_min_speed))
	
	player.target_speed = calc_speed
	move_dir = initial_dir.normalized() * player.target_speed
	
	perfect_slided = true
