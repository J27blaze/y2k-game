extends PlayerState

var final_pos: Vector3 = Vector3.ZERO
var wall_normal: Vector3 = Vector3.ZERO

@export var model_offsets: Vector3 = Vector3.ZERO

func start():
	print("vaulting")
	player.velocity = Vector3.ZERO
	player.gravity = 0.
	
	#first poart of data is poinr.
	#second is normal.
	final_pos = data[0]
	wall_normal = data[1]
	play_anim_blend("vault")
	
	player.model_twist_override_angle = atan2(wall_normal.x, wall_normal.z)
	
	var model_pos = final_pos + model_offsets.rotated(Vector3.UP, atan2(wall_normal.x, wall_normal.z))
	player.model_twist.is_lerping = false
	player.model_twist.position = model_pos
	print(model_pos)

func exit():
	player.model_twist.is_lerping = true
	player.model_twist_override_angle = -999

func process_physics(delta: float):
	DebugDraw3D.draw_square(final_pos, 0.2, Color.GREEN)
