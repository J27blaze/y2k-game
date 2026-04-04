extends Node3D

var offset: Vector3 = Vector3.ZERO
var default_offset: Vector3 = Vector3.ZERO
var offset_smoothing: float = 3.0

@export_range(0, 10, 0.1) var fast_offset_smoothing
@export_range(0, 10, 0.1) var mid_offset_smoothing
@export_range(0, 10, 0.1) var slow_offset_smoothing

@onready var pitch := $"camera_pitch"
@onready var camera := $camera_pitch/Camera3D
#@onready var player = parent()

func _ready() -> void:
	default_offset = position
	set_offset_smoothing("slow")
	
func _process(delta: float):
	position = lerp(position, offset + default_offset, offset_smoothing * delta)

func set_offset(camera_offset: Vector3):
	offset = camera_offset

func set_offset_smoothing(input_offset):
	if input_offset is String:
		match input_offset:
			"slow":
				offset_smoothing = slow_offset_smoothing
				return
			"mid":
				offset_smoothing = mid_offset_smoothing
				return
			"fast":
				offset_smoothing = fast_offset_smoothing
				return
			_:
				print("Invalid camera offset string")
				offset_smoothing = slow_offset_smoothing
				return
	if input_offset is float:
		offset_smoothing = input_offset
