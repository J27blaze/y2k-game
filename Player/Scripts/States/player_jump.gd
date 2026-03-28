extends PlayerState

#var initial_vel: Vector3
var timer: int = 0
var jump_cut: bool = true
var initial_vel: Vector3
var wall_normal: Vector3

func start():
	print("jump")
	player.can_jump = false
	
	timer = 0
	jump_cut = true
	
	player.target_speed = clampf(player.speed, player.run_speed, 99999)
	wall_normal = player.wall_normal
	#initial_vel = player.target_speed
	
	player.gravity = player.jump_gravity
	player.velocity.y = player.jump_vel_pulse

func exit():
	player.gravity = player.fall_gravity

func process_physics(delta: float):
	if player.velocity.y < 0:
		change_state("fall")
		return
	
	player.calc_wall_slide()
	
	#accel
	var move_dir = player.target_speed * player.direction
	if timer <= player.jump_inital_accel_frames && move_dir.length() >= 0.5:
		player.vel_move_toward(move_dir, player.jump_inital_accel, delta)
	else:
		player.vel_move_toward(move_dir, player.jump_accel, delta)
	
	if timer > player.jump_min_hold_frames && !Input.is_action_pressed("jump") && jump_cut:
		player.gravity = player.fall_gravity
		player.velocity.y *= player.jump_vel_height_cut
		jump_cut = false
	
	#player.state_wall_slide_jump_check()
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	#Add like a air strafing equivelent. as a player controller fucntion.
	
	#DebugDraw3D.draw_line(player.centre, player.centre + initial_vel * 3, Color(0, 0, 1))
	#DebugDraw3D.draw_line(player.centre, player.centre + initial_vel.rotated(Vector3.UP, PI/2) * 3, Color(0, 0, 1))
	#DebugDraw3D.draw_line(player.centre, player.centre + initial_vel.rotated(Vector3.UP, PI/-2)* 3, Color(0, 0, 1))
	
	timer += 1
	
