extends PlayerState

var timer: int = 0
var accel: float = 0.0
	
func start():
	print("fall")
	
	timer = 0
	player.gravity = player.fall_gravity
	accel = player.fall_accel
	#anim
	match previous_state():
		"jump":
			play_anim("jump_1_fall")
			return
		"air_dodge":
			play_anim("jump_1_fall")
			return
		"dodge_jump":
			accel = player.dodge_jump_accel
			play_anim("jump_1_fall")
			return
		_:
			play_anim("jump_1_fall")
			return
	#print(previous_state())

func process_physics(delta: float) -> void:
	player.calc_wall_slide()
	if player.state_wall_slide_check():
		return
	if player.state_landing_check():
		return
	if player.state_weapon_dash_check():
		return
	
	if !data:
		if player.state_dodge_check():
			return
	
	#coyote time, lockey buggy but its cool
	if timer <= player.jump_coyote_frames && Input.is_action_just_pressed("jump") && player.can_jump:
		change_state("jump")
		return
	
	var move_dir = player.target_speed * player.direction
	player.vel_move_toward(move_dir, accel, delta)
	#player.vel_accel_speed(player.run_speed, player.run_max_speed, player.jump_speed_accel, player.jump_speed_accel, delta)
	
	player.lerp_target_speed(player.air_target_speed_margin, player.air_target_speed_accel, delta)
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	timer += 1
	
	return
	
func process_input(event: InputEvent):
	return
