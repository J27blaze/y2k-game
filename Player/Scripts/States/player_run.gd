extends PlayerState

func start():
	print("run")
	player.target_speed = clampf(player.speed, player.run_speed, 999999)
	play_anim("run")

func process_physics(delta: float):
	if player.direction == Vector3.ZERO:
		change_state("idle")
		return
	if input_handler.is_action_buffered("jump") && player.can_jump:
		change_state("jump")
		return
	if Input.is_action_pressed("slide"):
		change_state("slide")
		return
	if !player.is_on_floor():
		change_state("fall")
		return
	player.state_dodge_check()
		
	var move_dir = player.target_speed * player.direction
	player.vel_move_toward(move_dir, player.run_accel, delta)
	player.target_speed = lerpf(player.target_speed, player.run_speed, player.run_accel_speed * delta)
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
