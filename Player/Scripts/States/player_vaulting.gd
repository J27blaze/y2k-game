extends PlayerState

var final_pos: Vector3 = Vector3.ZERO

func start():
	print("vaulting")
	player.velocity = Vector3.ZERO
	player.gravity = 0.
	
	#first poart of data is poinr.
	#second is normal.
	final_pos = data[0]

func _physics_process(delta: float) -> void:
	DebugDraw3D.draw_square(final_pos, 0.2, Color.GREEN)
	#print("SDDS")
	#player.velocity = Vector3.ZERO
