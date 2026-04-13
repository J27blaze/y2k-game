extends PlayerState

func start():
	print("idle")
	player.target_speed = 0
	play_anim("idle")

func process_physics(delta: float):
	if player.direction != Vector3.ZERO:
		change_state("run")
		return

	player.can_jump_check()
	player.state_dodge_check()
	
	player.vel_move_toward(Vector3.ZERO, player.run_accel, delta)
