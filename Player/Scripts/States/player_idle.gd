extends PlayerState

func start():
	print("idle")
	player.target_speed = 0
	play_anim_blend("idle")
	#player.animation_controller.animation_state_machine.travel("idle")

func process_physics(delta: float):
	if player.direction != Vector3.ZERO:
		change_state("run")
		return
	if player.state_jump(): return
	if player.state_dodge_check(): return
	if player.state_weapon_dash_check(): return
		
	player.hit_check()
	if player.state_tumble_check(): return
	if player.append_weapon_attack("idle"): return
	
	player.vel_move_toward(Vector3.ZERO, player.run_accel, delta)
