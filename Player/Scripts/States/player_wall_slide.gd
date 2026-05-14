extends PlayerState

var inital_speed: float
var last_wall_normal: Vector3 = Vector3.ZERO

var wall_side: int

func start():
	print("wall slide")
	player.can_jump = false
	#player.air_dodges = int(player.max_air_dodges)
	#air dodges
	if player.can_wall_slide_air_dodge:
		#player.air_dodges = int(player.max_air_dodges)
		player.can_wall_slide_air_dodge = false
	
	player.velocity.y = 0
	player.gravity = player.wall_slide_gravity
	
	inital_speed = clampf(player.target_speed, player.wall_slide_speed, 999999)
	player.target_speed = inital_speed
	
	if player.wall_normal.rotated(Vector3.UP, PI/2).dot(player.hor_velocity) > player.wall_normal.rotated(Vector3.UP, -PI/2).dot(player.hor_velocity):
		wall_side = 1
	else:
		wall_side = -1 
	
	player.camera_set_offset_smoothing("fast")

func exit():
	player.camera_set_offset(Vector3.ZERO)
	player.camera_set_offset_smoothing("slow")

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
	if player.state_landing_check():
		return
	if player.state_weapon_dash_check():
		return
	
	player.hit_check()
	if player.state_tumble_check():
		return
	
	#player wall angle too steep
	if abs(last_wall_normal.dot(player.wall_normal)) < player.wall_slide_angle_threshold:
		#NETUAL WALL SLIDE STATE, #CHANHGE LATER
		change_state("jump")
		return
	
	player.vel_move_toward((dir * inital_speed) + wall_pull_force, 999999, delta)
	
	var camera_offset = player.wall_normal.normalized() * player.camera_wall_slide_offset
	player.camera_set_offset(camera_offset)
	
	#change rot
	player.wall_slide_colliders.global_rotation.y = Vector3.FORWARD.signed_angle_to(dir, Vector3.UP)
	
	if player.state_wall_slide_jump_check():
		return
