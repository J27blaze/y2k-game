extends PlayerState

func start():
	print("idle")
	player.target_speed = 0
	play_anim("idle")

func process_physics(delta: float):
	if player.direction != Vector3.ZERO:
		change_state("run")
		return
	if input_handler.is_action_buffered("jump") && player.can_jump:
		change_state("jump")
		return
	player.state_dodge_check()
	
	player.vel_move_toward(Vector3.ZERO, player.run_accel, delta)
