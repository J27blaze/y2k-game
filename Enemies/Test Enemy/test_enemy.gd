extends Enemy

@export_range(0, 10, 1) var start_health: float = 10

func _ready():
	health = start_health
	print("init")

func _physics_process(delta: float) -> void:
	if is_players_target:
		DebugDraw3D.draw_square(position, 1, Color.BLUE)
