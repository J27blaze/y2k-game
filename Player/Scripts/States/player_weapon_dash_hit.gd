extends PlayerState

var initial_vel: Vector3 = Vector3.ZERO
var initial_dir: Vector3 = Vector3.ZERO
var move_dir: Vector3 = Vector3.ZERO

var timer: int = 0
var jump_cut : bool = true

func start():
	print("weapon_dash_hit")
	#play_anim("dodge_old")
	
	player.can_jump = false
	timer = 0
	jump_cut = true
	
	#player.target_speed = player.weapon_dash_target_speed
	player.gravity = player.weapon_dash_hit_gravity
	initial_vel = data
	initial_dir = initial_vel.normalized()
	
	var initial_dir_hor: Vector3 = Vector3(initial_dir.x, 0, initial_dir.z)
	var initial_speed: float = initial_vel.length()
	var initial_angle: float = rad_to_deg(initial_dir_hor.signed_angle_to(player.direction, Vector3.UP))
	
	var new_vel: Vector3 = Vector3.ZERO
	
	#add backwards angle + controllable hewight
	#print(initial_dir_hor.dot(player.direction))
	if initial_dir_hor.dot(player.direction) > player.weapon_dash_hit_dot_threshold:
		#forward
		var angle: float = clampf(initial_angle, -player.weapon_dash_hit_angle_range/2, player.weapon_dash_hit_angle_range/2)
		new_vel = initial_dir_hor.rotated(Vector3.UP, deg_to_rad(angle)) * initial_speed
	else:
		new_vel = player.direction * player.weapon_dash_hit_backward_speed
		player.target_speed = player.weapon_dash_hit_backward_speed
		
	#new_vel = new_dir * clampf(initial_speed * player.weapon_dash_hit_speed_multiplier, player.target_speed, 999999)
	player.velocity.x = new_vel.x
	player.velocity.z = new_vel.z
	
	player.velocity.y = clampf(player.velocity.y * player.weapon_dash_hit_y_speed_multiplier, player.weapon_dash_hit_vel_pulse, 999999)
	
	#anim
	play_anim("weapon_dash_hit")
	player.model_pitch = 0
	#print(data)
	
func exit():
	player.gravity = player.fall_gravity
	return

func process_physics(delta: float):
	#if player.state_landing_check():
	#	return
	if player.velocity.y < 0:
		change_state("fall", false)
		return
	if player.state_dodge_check():
		return
	if player.state_weapon_dash_check():
		return
	player.calc_wall_slide()
	if player.state_wall_slide_jump_check():
		return
	
	move_dir = player.direction * player.target_speed
	player.vel_move_toward(move_dir, player.weapon_dash_hit_aceel, delta)
	
	if timer > player.jump_min_hold_frames && !Input.is_action_pressed("jump") && jump_cut:
		player.gravity = player.fall_gravity
		player.velocity.y *= player.weapon_dash_hit_y_cut
		jump_cut = false
	
	timer += 1
	
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	#if player.state_weapon_dash_check():
	#	return
