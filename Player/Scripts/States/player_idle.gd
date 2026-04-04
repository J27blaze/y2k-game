extends PlayerState

func start():
	print("idle")
	player.target_speed = 0

func process_physics(delta: float):
	if player.direction != Vector3.ZERO:
		change_state("run")
		return
	if input_handler.is_action_buffered("jump") && player.can_jump:
		change_state("jump")
		return
	
	play_anim("idle")
	player.vel_move_toward(Vector3.ZERO, player.run_accel, delta)
