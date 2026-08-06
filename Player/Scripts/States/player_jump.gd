extends PlayerState

@export var is_dodge_jump: bool = false
@export var jump_stage: int = 0

#var initial_vel: Vector3
var timer: int = 0
var jump_cut: bool = true
var initial_vel: Vector3
var wall_normal: Vector3

var accel: float = 0.1

var jump_vel : float = 0
var jump_cut_amount : float = 0

func start():
	player.can_jump = false
	
	timer = 0 
	jump_cut = !is_dodge_jump
	player.input_handler.clear_action_buffer("jump")
	accel = player.jump_accel
	
	var min_speed : float = player.run_speed
	jump_vel = player.jump_vel_pulse
	jump_cut_amount = player.jump_vel_height_cut
	
	match player.jump_stage:
		2: 
			jump_vel = player.double_jump_vel_pulse
			jump_cut_amount = player.double_jump_vel_cut
		3:
			jump_vel = player.triple_jump_vel_pulse
			jump_cut_amount = player.triple_jump_vel_cut
		_: pass
	
	if is_dodge_jump:
		print("dodge_jump")
		#jump stage
		player.jump_stage = 0
		
		min_speed = player.dodge_jump_speed
		jump_vel = player.dodge_jump_vel_pulse
		accel = player.dodge_jump_accel
		
		var speed_increase : float = (player.dodge_jump_speed_increase * player.dodge_jump_speed_boost_scaling.sample(player.speed))
		#print(player.dodge_jump_speed_boost_scaling.sample(player.speed))
		#print(speed_increase)
		initial_vel = player.direction * clamp(player.target_speed + speed_increase, player.dodge_jump_speed, 999999)
		player.velocity.x = initial_vel.x
		player.velocity.z = initial_vel.z
		
		player.target_speed = player.target_speed + speed_increase
	else:
		if player.jump_stage == 0:
			player.jump_stage = 1
		print(str(jump_stage) + "_jump")
		#jump stage 
		player.jump_stage_timer.stop()
		
		player.target_speed = clampf(player.speed, min_speed, 99999)
	
	wall_normal = player.wall_normal
	#initial_vel = player.target_speed
	
	player.gravity = player.jump_gravity
	player.velocity.y = jump_vel
	play_anim("jump_default")

func exit():
	player.gravity = player.fall_gravity

func process_physics(delta: float) -> void:	
	if player.velocity.y < 0:
		change_state("fall", is_dodge_jump)
		return
	
	player.hit_check()
	if player.state_tumble_check():
		return
	
	if player.state_weapon_dash_check():
		return
	if player.state_landing_check():
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
		player.velocity.y *= jump_cut_amount
		jump_cut = false
	
	#player.state_wall_slide_jump_check()
	player.lerp_target_speed(player.air_target_speed_margin, player.air_target_speed_accel, delta)
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	timer += 1
