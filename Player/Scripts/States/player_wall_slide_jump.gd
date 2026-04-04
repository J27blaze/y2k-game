extends PlayerState

#var initial_vel: Vector3
var timer: int = 0
var jump_cut: bool = true
var initial_vel: Vector3 = Vector3.ZERO

var wall_normal: Vector3
var wall_side: int = 1
var dir: Vector3 = Vector3.ZERO

func start():
	print("wall_slide_jump")
	player.can_jump = false
	
	timer = 0
	jump_cut = true
	
	player.gravity = player.jump_gravity
	player.velocity.y = player.wall_slide_jump_vel_pulse
	wall_normal = player.wall_normal
	
	if wall_normal.rotated(Vector3.UP, PI/2).dot(player.hor_velocity) > wall_normal.rotated(Vector3.UP, -PI/2).dot(player.hor_velocity):
		wall_side = 1
	else:
		wall_side = -1 
	
	dir = player.wall_normal.rotated(Vector3.UP, PI/2*wall_side)
	
	var player_calc_speed = player.target_speed + (player.wall_slide_jump_speed_increase * player.wall_slide_jump_speed_increase_scaling.sample(player.target_speed - player.wall_slide_speed))
	player.target_speed = clampf(player_calc_speed, player.run_speed, 99999)

	initial_vel = player.hor_velocity.normalized()

func exit():
	player.gravity = player.fall_gravity

func process_physics(delta: float):
	if player.velocity.y < 0:
		change_state("fall")
		return
	
	player.calc_wall_slide()
	
	#similiar as player jump state
	
	#accel
	var move_dir = player.target_speed * player.direction
	
	if timer <= player.wall_slide_jump_inital_accel_frames:
		var initial_move_dir: Vector3
		var angle: float = abs(rad_to_deg(move_dir.signed_angle_to(dir, Vector3.UP))) * -wall_side
		var clamped_angle: float = abs(clamp(abs(angle), player.wall_slide_jump_min_angle, player.wall_slide_jump_max_angle) ) * -wall_side
		
		initial_move_dir = dir.rotated(Vector3.UP, deg_to_rad(clamped_angle)) * player.target_speed
		
		DebugDraw3D.draw_line(player.centre, player.centre + dir * 6, Color.RED)
		DebugDraw3D.draw_line(player.centre, player.centre + dir.rotated(Vector3.UP, deg_to_rad(angle)) * 3, Color.SANDY_BROWN)
		DebugDraw3D.draw_line(player.centre, player.centre + initial_move_dir.normalized() * 3, Color.BLUE)
		
		#print(wall_side)
		#print(angle)
		#print(clamped_angle)
		if timer <= 1:
			player.vel_move_toward(initial_move_dir, 999999, delta)
		else:
			player.vel_move_toward(initial_move_dir, player.jump_inital_accel, delta)
	else:
		#player.vel_move_toward(move_dir, player.jump_accel, delta)
		
		#debug
		DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
		DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
		player.vel_move_toward(move_dir, player.jump_accel, delta)
	
	if timer > player.jump_min_hold_frames && !Input.is_action_pressed("jump") && jump_cut:
		player.gravity = player.fall_gravity
		player.velocity.y *= player.jump_vel_height_cut
		jump_cut = false
	
	timer += 1
