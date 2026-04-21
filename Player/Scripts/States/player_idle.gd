extends PlayerState

func start():
	print("idle")
	player.target_speed = 0
	play_anim("idle")

func process_physics(delta: float):
	if player.direction != Vector3.ZERO:
		change_state("run")
		return
	if player.state_jump():
		return
	if player.state_dodge_check():
		return
	
	player.vel_move_toward(Vector3.ZERO, player.run_accel, delta)
