extends Enemy

@export_range(0, 10, 1) var start_health: float = 10

func _ready():
	health = start_health
	print("init")
