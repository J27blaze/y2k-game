class_name CameraController
extends Node

@export var player: Player

var offset: Vector3 = Vector3.ZERO
var target_offset: Vector3 = Vector3.ZERO

var target_position: Vector3 = Vector3.ZERO

var input_handler = InputHandler.new()

@export_range(0, 20, 0.1) var fast_smoothing: float
@export_range(0, 20, 0.1) var mid_smoothing: float
@export_range(0, 20, 0.1) var slow_smoothing: float

@export_range(0, 20, 0.1) var fast_offset_smoothing: float
@export_range(0, 20, 0.1) var mid_offset_smoothing: float
@export_range(0, 20, 0.1) var slow_offset_smoothing: float

@export_range(0,1,0.01) var rot_smoothing: float = 0.6
var offset_smoothing: float = 3.0
var pos_smoothing: float = 3.0

@onready var pitch := $camera_twist/camera_pitch
@onready var twist := $camera_twist
@onready var camera := $camera_twist/camera_pitch/Camera3D
var z_cam_pos : float = 0
@onready var col : RayCast3D = $camera_twist/camera_pitch/camera_col
@export var col_margin_error : float = 0.5
#@onready var player = parent()

#@export var global_offset: bool = true

var twist_basis
var global_transform

var camera_dir: Vector2
var mouse_dir: Vector2
var export_mouse_dir:  Vector2 = Vector2.ZERO #USED FOR EXPORTING DATA, NOT THE ACTUAL DATA

func _ready() -> void:
	twist.position = player.global_position
	set_offset_smoothing("slow")
	z_cam_pos = camera.position.z
	col.target_position = camera.position + -Vector3.FORWARD * col_margin_error
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_dir =  input_handler.get_mouse_camera_dir(event)
	camera_dir = lerp(camera_dir, input_handler.get_controller_camera_dir(), rot_smoothing)

# proccessed in player_controller.gd
func process(delta: float):
	#camera Rot | Added this to the camera controlls =(^.^)=
	twist_basis = twist.basis
	global_transform = camera.global_transform
	
	twist.rotate_y(-camera_dir.x - mouse_dir.x)
	pitch.rotate_x(-camera_dir.y - mouse_dir.y)
	#pitch clamp values
	pitch.rotation.x = clamp(pitch.rotation.x, -PI/2, PI/2)
	
	export_mouse_dir = mouse_dir
	mouse_dir = Vector2.ZERO
	
	#position
	target_position = player.global_position
	offset = lerp(offset, target_offset, offset_smoothing * delta) 
	twist.position = lerp(twist.position, target_position + offset, pos_smoothing * delta)
	
	#collision
	col.force_raycast_update()
	if col.is_colliding():
		var dist : float = col.get_collision_point().distance_to(col.global_position)
		print(dist)
		camera.position.z = dist - col_margin_error
	else:
		print(z_cam_pos)
		camera.position.z = z_cam_pos

func set_offset(camera_offset: Vector3):
	target_offset = camera_offset

func set_smoothing(input_offset):
	if input_offset is String:
		match input_offset:
			"slow":
				pos_smoothing = slow_smoothing
				return
			"mid":
				pos_smoothing = mid_smoothing
				return
			"fast":
				pos_smoothing = fast_smoothing
				return
			_:
				print("Invalid camera offset smoothing")
				pos_smoothing = slow_smoothing
				return
	if input_offset is float:
		pos_smoothing = input_offset

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
				print("Invalid camera offset smoothing")
				offset_smoothing = slow_smoothing
				return
	if input_offset is float:
		offset_smoothing = input_offset
