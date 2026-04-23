extends PlayerState

@onready var dodge_length := $dodge_length

var initial_dir: Vector3

func start():
	print("weapon_dash_hit")
	play_anim("dodge_old")
	
	player.gravity = player.fall_gravity
	
func exit():
	return

func process_physics(delta: float):
	return
