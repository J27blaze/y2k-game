extends PlayerState

@onready var dodge_length := $dodge_length

var initial_dir: Vector3
var input_dir: Vector3
var final_dir: Vector3
var speed : float = 0

var timer: int = 0

func start():
	print(data + " dodge")
	dodge_length.start()
	
	if data == "air":
		player.velocity.y = player.air_dodge_vel_pulse
		player.gravity = player.air_dodge_gravity
	
	timer = 0
	
	initial_dir = player.hor_velocity.normalized()* player.target_speed
	
	#print(speed)
	
func get_player_dir():
	if player.direction.length() > 0.1:
		input_dir = player.direction.normalized()
	else:
		input_dir = player.last_dir
		#print(player.last_dir)

func exit():
	player.velocity.y *= 0.9
	#player.velocity = player.velocity.normalized() * player.target_speed
	#player.speed = player.target_speed
	dodge_length.stop()
	print(player.speed)
	return

func process_physics(delta: float):
	if timer < player.dodge_initial_redirect_frame:
		get_player_dir()
		
		var angle_clamp_amount: float = player.dodge_angle_clamp.sample(initial_dir.normalized().dot(input_dir.normalized()))
		var dodge_speed: float = (player.speed) * angle_clamp_amount
		
		player.target_speed = clampf(player.target_speed * angle_clamp_amount, player.dodge_min_speed, 999999)
		speed = clampf(player.speed, player.dodge_min_speed + player.dodge_add_speed, 999999)
	else:
		speed = lerpf(speed, player.target_speed, player.dodge_accel_speed * delta)
	
	final_dir = input_dir * speed
	
	player.velocity.x = final_dir.x
	player.velocity.z = final_dir.z
	
	timer += 1
	
	if data == "air":
		player.calc_wall_slide()
		player.state_landing_check()
	elif dodge_length.is_stopped():
		player.state_landing_check()
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)

func _on_dodge_length_timeout() -> void:
	if data == "air":
		change_state("fall")
	else:
		player.state_landing_check()
