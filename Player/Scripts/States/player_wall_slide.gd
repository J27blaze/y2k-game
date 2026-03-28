extends PlayerState

var inital_speed: float
var last_wall_normal: Vector3 = Vector3.ZERO

var wall_side: int

func start():
	print("wall slide")
	player.can_jump = false
	player.velocity.y = 0
	player.gravity = player.wall_slide_gravity
	
	inital_speed = clampf(player.target_speed, player.wall_slide_speed, 999999)
	player.target_speed = inital_speed
	
	if player.wall_normal.rotated(Vector3.UP, PI/2).dot(player.hor_velocity) > player.wall_normal.rotated(Vector3.UP, -PI/2).dot(player.hor_velocity):
		wall_side = 1
	else:
		wall_side = -1 

func process_physics(delta: float):
	last_wall_normal = player.wall_normal
	
	player.calc_wall_slide()
	var dir = player.wall_normal.rotated(Vector3.UP, PI/2*wall_side)
	var wall_pull_force: Vector3 = player.wall_normal.rotated(Vector3.UP, PI) * player.wall_slide_pull_force
	
	#player leaves wall
	if !player.on_wall || !player.can_wall_slide():
		#fall
		#player.velocity -= wall_pull_force
		change_state("fall")
		return
	player.state_landing_check()
	
	#player wall angle too steep
	if abs(last_wall_normal.dot(player.wall_normal)) < player.wall_slide_angle_threshold:
		#bonk state
		change_state("jump")
		return
	
	player.vel_move_toward((dir * inital_speed) + wall_pull_force, 999999, delta)
	
	#change rot
	player.wall_slide_colliders.global_rotation.y = Vector3.FORWARD.signed_angle_to(dir, Vector3.UP)
	
	player.state_wall_slide_jump_check()
