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
	
	match data:
		"air":
			player.velocity.y = player.air_dodge_vel_pulse
			player.gravity = player.air_dodge_gravity
		"ground":
			player.velocity.y = player.ground_dodge_vel_pulse
			player.gravity = player.air_dodge_gravity
	
	timer = 0
	
	initial_dir = player.hor_velocity.normalized()* player.target_speed
	play_anim("dodge_old")
	
	#print(speed)
	
func exit():
	player.velocity.y *= 0.9
	player.gravity = player.fall_gravity
	#player.velocity = player.velocity.normalized() * player.target_speed
	#player.speed = player.target_speed
	dodge_length.stop()
	#print(player.speed)
	return

func process_physics(delta: float):
	return
