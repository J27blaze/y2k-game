extends PlayerState

@onready var area_collider := $enemy_targeting_collider/sphere

func always_process_physics(delta: float):
	area_collider.position = player.position

func init() -> void:
	var shape = CylinderShape3D.new()
	shape.radius = player.dash_radius
	shape.height = player.dash_radius
	area_collider.shape = shape

func start():
	return

func exit():
	return

func process_physics(delta: float):
	return
	
