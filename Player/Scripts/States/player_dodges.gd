extends PlayerState

@onready var dodge_length := $dodge_length

var initial_dir: Vector3
var input_dir: Vector3
var final_dir: Vector3
var speed : float = 0

var timer: int = 0

func start():
	input_handler.clear_action_buffer("dodge")
	print(data + " dodge")
	player.jump_stage = 0
	
	dodge_length.start()
	player.set_hurt_box(false)
	
	match data:
		"air":
			player.velocity.y = player.air_dodge_vel_pulse
			player.gravity = player.air_dodge_gravity
			
			player.air_dodges -= 1
			
			
		"ground":
			player.velocity.y = player.ground_dodge_vel_pulse
			player.gravity = player.air_dodge_gravity
			
			play_anim_blend("ground_dodge")
	
	timer = 0
	
	initial_dir = player.hor_velocity.normalized()* player.target_speed
	#play_anim("dodge_old")
	
	#print(speed)
	
func get_player_dir():
	if player.direction.length() > 0.1:
		input_dir = player.direction.normalized()
	else:
		input_dir = player.last_dir
		#print(player.last_dir)
	
	player.model_twist_override_angle = atan2(input_dir.x, input_dir.z) + -PI
	
func exit():
	player.velocity.y *= 0.9
	player.gravity = player.fall_gravity
	player.set_hurt_box(true)
	#player.velocity = player.velocity.normalized() * player.target_speed
	#player.speed = player.target_speed
	dodge_length.stop()
	#print(player.speed)
	if data == "ground":
		if !player.is_on_floor():
			player.can_jump = false
	
	player.model_twist_override_angle = -999
	
	return

func process_physics(delta: float):
	player.calc_wall_slide()
	if player.state_wall_slide_jump_check():
		return
	
	if timer < player.dodge_initial_redirect_frame:
		get_player_dir()
		
		if timer == 0:
			player.vfx_controller.spawn_particle("dodge", true, player.position, Vector3(0, atan2(input_dir.x, input_dir.z) + -PI, 0))
		
		var angle_clamp_amount: float = 1.0
		
		match data:
			"air":
				angle_clamp_amount = player.dodge_angle_clamp.sample(initial_dir.normalized().dot(input_dir.normalized()))
				
		var dodge_speed: float = (player.speed) * angle_clamp_amount
		
		player.target_speed = clampf(player.target_speed * angle_clamp_amount, player.dodge_min_speed, 999999)
		speed = clampf(player.speed, player.dodge_min_speed + player.dodge_add_speed, 999999)
	else:
		speed = lerpf(speed, player.target_speed, player.dodge_accel_speed * delta)
		
		#match data:
		#	"ground":
		#		if Input.is_action_pressed("slide"):
		#			change_state("slide")
		#		return
	
	final_dir = input_dir * speed
	
	player.velocity.x = final_dir.x
	player.velocity.z = final_dir.z
	
	timer += 1
	
	match data:
		"air":
			player.calc_wall_slide()
			if player.state_landing_check():
				return
			if Input.is_action_just_pressed("dodge"):
				return
		"ground":
			if dodge_length.is_stopped():
				#print("sdfsdf")
				if player.state_landing_check():
					return
				else:
					change_state("fall")
			
			#dodge jump
			if player.input_handler.is_action_buffered("jump") && player.is_on_floor():
				final_dir = input_dir * player.target_speed
				
				player.velocity.x = final_dir.x
				player.velocity.z = final_dir.z
				player.speed = player.target_speed
				
				change_state("dodge_jump")
				return

	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)

func _on_dodge_length_timeout() -> void:
	if data == "air":
		change_state("fall")
	#else:
	#	player.state_landing_check()
