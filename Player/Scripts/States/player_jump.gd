extends PlayerState

@export var is_dodge_jump: bool = false

#var initial_vel: Vector3
var timer: int = 0
var jump_cut: bool = true
var initial_vel: Vector3
var wall_normal: Vector3

var accel: float = 0.0

func start():
	player.can_jump = false
	
	timer = 0 
	jump_cut = !is_dodge_jump
	player.input_handler.clear_action_buffer("jump")
	accel = player.jump_accel
	
	var min_speed : float = player.run_speed
	var jump_vel : float = player.jump_vel_pulse
	if is_dodge_jump:
		print("dodge_jump")
		min_speed = player.dodge_jump_speed
		jump_vel = player.dodge_jump_vel_pulse
		accel = player.dodge_jump_accel
		
		initial_vel = player.direction * clamp(player.target_speed, player.dodge_jump_speed, 999999)
		player.velocity.x = initial_vel.x
		player.velocity.z = initial_vel.z
	else:
		print("jump")
	
	player.target_speed = clampf(player.speed, min_speed, 99999)
	wall_normal = player.wall_normal
	#initial_vel = player.target_speed
	
	player.gravity = player.jump_gravity
	player.velocity.y = jump_vel
	play_anim("jump_1")

func exit():
	player.gravity = player.fall_gravity
	player.camera_set_offset(Vector3.ZERO)
	player.camera_set_offset_smoothing("slow")

func process_physics(delta: float) -> void:
	if player.velocity.y < 0:
		change_state("fall", is_dodge_jump)
		return
	
	if player.state_weapon_dash_check():
		return
	
	player.calc_wall_slide()
	if player.state_wall_slide_jump_check():
		return
	if !is_dodge_jump:
		if player.state_dodge_check():
			return
	
	#accel
	var move_dir = player.target_speed * player.direction
	if timer <= player.jump_inital_accel_frames && move_dir.length() >= 0.5:
		player.vel_move_toward(move_dir, player.jump_inital_accel, delta)
	else:
		player.vel_move_toward(move_dir, accel, delta)
	
	if timer > player.jump_min_hold_frames && !Input.is_action_pressed("jump") && jump_cut:
		player.gravity = player.fall_gravity
		player.velocity.y *= player.jump_vel_height_cut
		jump_cut = false
	
	#player.state_wall_slide_jump_check()
	player.lerp_target_speed(player.air_target_speed_margin, player.air_target_speed_accel, delta)
	
	var camera_offset = player.wall_normal.normalized() * player.camera_wall_slide_offset * int(player.on_wall)
	player.camera_set_offset(camera_offset)
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	timer += 1
