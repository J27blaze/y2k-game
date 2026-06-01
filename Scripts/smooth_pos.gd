extends Node3D

@export var target: Node3D
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Detach the visual sprite so it doesn't move with the physics jitter
	top_level = true
	target_position = target.global_position
	position = target_position

func _physics_process(delta: float) -> void:
	target_position = target.global_position

func _process(delta: float) -> void:
	# Get the fraction of the physics tick currently being processed (0.0 to 1.0)
	var interpolation_fraction: float = Engine.get_physics_interpolation_fraction()
	
	# Smoothly set the visual position between the old and new physics ticks
	#idk why 2x works but it does
	position = lerp(position, target_position, interpolation_fraction)
	#print(target_position)
