extends Node

@export var player: Player

var offset: Vector3 = Vector3.ZERO
var offset_smoothing: float = 3.0
var default_offset: Vector3 = Vector3.ZERO

var target_position: Vector3 = Vector3.ZERO

var input_handler = InputHandler.new()

@export_range(0, 10, 0.1) var fast_smoothing
@export_range(0, 10, 0.1) var mid_smoothing
@export_range(0, 10, 0.1) var slow_smoothing

@export_range(0,1,0.01) var camera_smoothing: float = 0.6

@onready var pitch := $camera_twist/camera_pitch
@onready var twist := $camera_twist
@onready var camera := $camera_twist/camera_pitch
#@onready var player = parent()

var twist_basis
var global_transform

var camera_dir: Vector2
var mouse_dir: Vector2

func _ready() -> void:
	twist.position = player.global_position
	default_offset = camera.position
	set_offset_smoothing("slow")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_dir =  input_handler.get_mouse_camera_dir(event)
	camera_dir = lerp(camera_dir, input_handler.get_controller_camera_dir(), camera_smoothing)

# proccessed in player_controller.gd
func process(delta: float):
	#camera Rot | Added this to the camera controlls =(^.^)=
	twist_basis = twist.basis
	global_transform = camera.global_transform
	
	twist.rotate_y(-camera_dir.x - mouse_dir.x)
	pitch.rotate_x(-camera_dir.y - mouse_dir.y)
	#pitch clamp values
	pitch.rotation.x = clamp(pitch.rotation.x, -PI/2, PI/2)
	
	mouse_dir = Vector2.ZERO
	
	#position
	target_position = player.global_position
	twist.position = lerp(twist.position, target_position, offset_smoothing * delta)
	camera.position = lerp(camera.position, offset + default_offset , offset_smoothing * delta) 

func set_offset(camera_offset: Vector3):
	offset = camera_offset

func set_offset_smoothing(input_offset):
	if input_offset is String:
		match input_offset:
			"slow":
				offset_smoothing = slow_smoothing
				return
			"mid":
				offset_smoothing = mid_smoothing
				return
			"fast":
				offset_smoothing = fast_smoothing
				return
			_:
				print("Invalid camera offset smoothing")
				offset_smoothing = slow_smoothing
				return
	if input_offset is float:
		offset_smoothing = input_offset
