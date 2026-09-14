extends PlayerState

#var initial_vel: Vector3
var timer: int = 0
var jump_cut: bool = true
var initial_vel: Vector3

var wall_normal: Vector3
var vault_pos: Vector3

var jump_vel : float = 0

var is_perfect_vault : bool = false

func start():
	player.can_jump = false
	player.air_dodges = int(player.max_air_dodges)
	jump_cut = true
	
	#first poart of data is poinr.
	#second is normal.
	vault_pos = data[0]
	wall_normal = data[1]
	
	player.position = vault_pos + Vector3.UP * player.step_margin
	
	timer = 0 
	
	is_perfect_vault = player.input_handler.is_action_buffered("vault")
	
	player.input_handler.clear_action_buffer("jump")
	player.input_handler.clear_action_buffer("vault")
	
	#jump stage
	player.jump_stage = 0
	
	jump_vel = player.vault_jump_vel_pulse
	
	var speed_boost:float = player.vault_perfect_speed_boost * player.vault_perfect_speed_boost_scaling.sample(player.speed)
	if is_perfect_vault:
		print("perfect_vault_jump")
		play_anim("vault_jump_back")
		
		#print(speed_boost)
		player.target_speed = clampf(player.target_speed + speed_boost, player.vault_min_speed + speed_boost, 999999)
	else:
		print("vault_jump")
		play_anim("vault_jump_default")
		
		player.target_speed = clampf(player.target_speed - speed_boost, 0, 999999)
	
	initial_vel = player.direction * player.target_speed
	
	player.velocity.x = initial_vel.x
	player.velocity.z = initial_vel.z
	#print(initial_vel)
	
	wall_normal = player.wall_normal
	#initial_vel = player.target_speed
	
	player.gravity = player.jump_gravity
	player.velocity.y = jump_vel

func exit():
	player.gravity = player.fall_gravity

func process_physics(delta: float) -> void:	
	if player.velocity.y < 0:
		change_state("fall")
		return
	
	player.hit_check()
	if player.state_tumble_check(): return
	
	if player.state_weapon_dash_check(): return
	if player.state_landing_check(): return
	
	player.calc_wall_slide()
	if player.state_wall_slide_jump_check(): return
	if player.state_air_attack(): return
	
	#accel
	var move_dir = player.target_speed * player.direction
	player.vel_move_toward(move_dir, player.vault_jump_accel, delta)
	
	if timer > player.vault_jump_min_hold_frames && !Input.is_action_pressed("jump") && jump_cut:
		player.gravity = player.fall_gravity
		player.velocity.y *= player.vault_jump_vel_height_cut
		jump_cut = false
	
	#player.state_wall_slide_jump_check()
	#player.lerp_target_speed(player.air_target_speed_margin, player.air_target_speed_accel, delta)
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	timer += 1
