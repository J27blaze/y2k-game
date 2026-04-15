class_name Player
extends CharacterBody3D

#camera
@onready var camera_twist := $camera_twist
@onready var camera_pitch := $camera_twist/camera_pitch

#player related
@onready var model_twist := $model_twist
@onready var animation_player := $model_twist/AnimationPlayer
@onready var standing_collider := $standing_collider
@onready var wall_slide_colliders := $wall_slide_colliders
@onready var floor_collider := $floor_collider
var wall_slide_rays: Array[Node]
var wall_rel_centre: Vector3 #0, 1.5, 0
var floor_normal: Vector3 = Vector3.ZERO
var god_mode: bool = false

#other
var centre: Vector3 = Vector3.ZERO
var height: float = 1.7
var style: int = 0 # 0-100 = one style point

#general movement
var direction: Vector3
var last_dir: Vector3 = Vector3.FORWARD
var hor_velocity: Vector3
var last_velocity: Vector3 = Vector3.ZERO

var speed: float
var target_speed: float

var gravity: float

# input handlng
var input_handler = InputHandler.new()
var raw_input_dir: Vector2
var input_dir: Vector2
var camera_dir: Vector2
var mouse_dir: Vector2

@onready var state_machine := $state_machine

#region player variables
@export_category("Player Variables")

@export_range(0,1,0.01) var camera_smoothing: float = 0.6
@export_range(0,1,0.01) var rotation_smoothing: float = 0.6
#endregion
#region run
@export_group("run") 
@export_range(0, 20, 0.1) var run_speed: float = 10.0
@export_range(0, 50, 0.1) var run_accel: float = 10.0
@export_range(0, 20, 0.05) var run_accel_speed: float = 10.0
#endregion
#region fall jump
@export_group("fall | jump")
var can_jump: bool = true
@export_range(0, 80, 0.05) var fall_gravity: float = 10.
@export_range(0, 80, 0.05) var jump_gravity: float = 10.
@export_range(0, 50, 0.05) var jump_vel_pulse: float = 10.
@export_range(0, 1, 0.001) var jump_vel_height_cut: float = 0.8
@export_range(0, 50, 0.05) var fall_terminal_vel: float = 25.

@export_range(0, 50, 0.05) var jump_accel: float = 10.
@export_range(0, 50, 0.05) var fall_accel: float = 10.
@export_range(0, 1000, 1) var jump_inital_accel: float = 10.

@export_range(0, 20, 1) var jump_min_hold_frames: float = 4.
@export_range(0, 20, 1) var jump_inital_accel_frames: float = 4.
@export_range(0, 20, 1) var jump_coyote_frames: float = 4.

@export_range(0, 15, 0.05) var air_target_speed_margin: float = 4.
@export_range(0, 20, 0.05) var air_target_speed_accel: float = 1.

#endregion
#region wall slide
@export_group("wall slide")
@export_range(0, 2, 0.05) var wall_slide_range: float = 0.5
@export_range(0, 360, 0.5) var wall_slide_angle_range: float = 0.4
@export_range(0, 1, 0.05) var wall_slide_angle_threshold: float = 12.
@export_range(0, 1, 0.05) var wall_slide_direction_threshold: float = 12.

@export_range(0, 20, 0.1) var wall_slide_speed: float = 12.
@export_range(0, 20, 0.1) var wall_slide_min_speed: float = 12.

@export_range(0, 80, 0.05) var wall_slide_gravity: float = 10.
@export_range(0, 15, 0.05) var wall_slide_pull_force: float = 10.

@export_range(0, 10, 0.005) var camera_wall_slide_offset: float = 1.0

#endregion
#region wall slide jump
@export_group("wall slide jump")
@export_range(0, 8, 0.05) var wall_slide_jump_speed_increase: float = 5.
@export var wall_slide_jump_speed_increase_scaling: Curve
@export_range(0, 50, 0.05) var wall_slide_jump_vel_pulse: float = 17 #  slightly more than base jump

@export_range(0, 180, 0.05) var wall_slide_jump_min_angle: float = 5.
@export_range(0, 180, 0.05) var wall_slide_jump_max_angle: float = 45

@export_range(0, 20, 1) var wall_slide_jump_inital_accel_frames: float = 4.
#endregion
#region slide
@export_group("slide")
#@export_range(0, 20, 0.1) var slide_speed: float = 12.0
@export_range(0, 1, 0.001) var slide_friction: float = 0.95
@export_range(0, 120, 1) var slide_friction_start_time: float = 3.
@export_range(0, 15, 0.01) var slide_handling: float = 3.
@export_range(0, 20, 0.01) var slide_min_speed: float = 3.
@export_range(0, 30, 0.005) var slide_tangent_scaling: float = 3.
@export_range(0, 20, 0.05) var slide_tangent_max_speed: float = 3.
@export_range(0, 1, 0.005) var slide_tangent_max_speed_slow: float = 3.

@export_range(0, 15, 1) var perfect_slide_after_frame_window: float = 3.
@export_range(0, 15, 0.05) var perfect_slide_speed_boost: float = 3.0
@export var perfect_slide_speed_boost_scaling: Curve
#endregion 
#region slide
@export_group("dodges")
var dodges: int = 2
@export_range(0, 30, 0.05) var dodge_min_speed:float = 15.0
@export_range(0, 30, 0.05) var dodge_add_speed:float = 15.0
@export_range(0, 20, 0.05) var dodge_accel_speed: float = 10.0
@export_range(0, 10, 1) var dodge_initial_redirect_frame:int = 2
@export var dodge_angle_clamp : Curve

@export_range(0, 25, 0.05) var ground_dodge_vel_pulse:float = 3.0

@export_range(0, 25, 0.05) var air_dodge_vel_pulse:float = 3.0
@export_range(0, 80, 0.05) var air_dodge_gravity: float = 10.

@export_group("dodges - jump")
var can_dodge_jump: bool = false
@export_range(0, 50, 0.05) var dodge_jump_vel_pulse: float = 10.
@export_range(0, 20, 0.01) var dodge_jump_speed: float = 10.
@export_range(0, 60, 1) var dodge_jump_frames: float = 10.

#endregion 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_machine.init(self)
	camera_set_offset(Vector3.ZERO)
	
	#set wall slide range
	var ray_amount = wall_slide_colliders.get_child_count()
	print(ray_amount)
	var i = 0
	for ray in wall_slide_colliders.get_children():
		ray.target_position = Vector3(0, 0, wall_slide_range + 0.5)
		ray.rotation.y = deg_to_rad(180 - wall_slide_angle_range/2 + (i+1)*(wall_slide_angle_range/ray_amount))
		
		wall_slide_rays.append(ray)
		
		i += 1
	
	wall_rel_centre = wall_slide_colliders.position
	
	height = standing_collider.shape.height
	gravity = fall_gravity

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_dir =  input_handler.get_mouse_camera_dir(event)
	#debug stuff
	
	raw_input_dir =  input_handler.get_raw_input_dir()
	input_dir =  input_handler.get_input_dir()
	
	camera_dir = lerp(camera_dir, input_handler.get_controller_camera_dir(), camera_smoothing)
	
	input_handler.process_input(event)
	state_machine.process_input(event)

func _physics_process(delta: float):
	#wall_slide_colliders rot
	if velocity.length() > 0.4:
		wall_slide_colliders.global_rotation.y = Vector3.FORWARD.signed_angle_to(hor_velocity, Vector3.UP)
	#player rotation
	if direction.length() > 0.5:
		last_dir = direction.normalized()
		
	if velocity.length() > 0.5:
		last_velocity = velocity
	
	input_handler.process_physics(delta)
	state_machine.process_physics(delta)
	state_machine.always_physics_update(delta)
	
	if Input.is_action_just_pressed("debug_mode"):
		god_mode = !god_mode
		if god_mode:
			state_machine.change_state("god_mode")
	
	move_and_slide()
	
	hor_velocity = Vector3(velocity.x, 0, velocity.z)
	speed = Vector3(velocity.x, 0, velocity.z).length()
	
	#gravity
	if !is_on_floor():
		velocity.y = clampf(velocity.y - gravity * delta, -fall_terminal_vel, 999999)
	
	#player_slide
	floor_normal = floor_collider.get_collision_normal() * int(floor_collider.is_colliding())
	
func _process(delta: float):	
	#camera Rot
	camera_twist.rotate_y(-camera_dir.x - mouse_dir.x)
	camera_pitch.rotate_x(-camera_dir.y - mouse_dir.y)
	camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, -1.4, 0.45)
	#adds the camera rot to movement
	direction = (camera_twist.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	mouse_dir = Vector2.ZERO
	state_machine.process_frame(delta)
	
	#player.rotation
	model_twist.global_rotation.y = lerp_angle(model_twist.global_rotation.y, atan2(-last_dir.x, -last_dir.z), 0.1)#Vector3.FORWARD.signed_angle_to(last_dir, Vector3.UP)
	
	centre = position + Vector3.UP * height/2

#camera controls, inherets camera_controls.gd
func camera_set_offset(camera_offset: Vector3):
	camera_twist.set_offset(camera_offset)

func camera_set_offset_smoothing(input_offset):
	camera_twist.set_offset_smoothing(input_offset)

func play_anim(animation_name: String):
	animation_player.play(animation_name)

#Global Movement Functions
func vel_move_toward(target_vector: Vector3, accel: float, delta: float):
	velocity.x = velocity.move_toward(target_vector, accel * delta).x
	velocity.z = velocity.move_toward(target_vector, accel * delta).z

func lerp_target_speed(speed_margin: float, accel: float, delta: float):
	var condition: bool = speed > target_speed + speed_margin || speed < target_speed - speed_margin
	if condition:
		target_speed = lerpf(target_speed, speed, accel * delta)
	
#Add air strafe BY USING SLIDE CODE

# State changes check
func state_landing_check():
	if is_on_floor():
		can_jump = true
		if direction == Vector3.ZERO:
			state_machine.change_state("idle")
			return
		else:
			if Input.is_action_pressed("slide"):
				state_machine.change_state("slide")
			else:
				state_machine.change_state("run")

func state_jump():
	if can_dodge_jump:
		state_machine.change_state("dodge_jump")
	else:
		state_machine.change_state("jump")
	return

func state_dodge_check():
	if input_handler.is_action_buffered("dodge"):
		match state_machine.current_state.name:
			"jump":
				state_machine.change_state("air_dodge", "air")
				return
			"wall_slide_jump":
				state_machine.change_state("air_dodge", "air")
				return
			"fall":
				state_machine.change_state("air_dodge", "air")
				return
			"run":
				state_machine.change_state("ground_dodge", "ground")
				return
			"idle":
				state_machine.change_state("ground_dodge", "ground")
				return
			"slide":
				state_machine.change_state("ground_dodge", "ground")
				return


var wall_normal: Vector3
var on_wall: bool = false
var wall_point: Vector3

func calc_wall_slide():
	#if there is a gap between the rays (implying that there the player is touching two walls) then get closes point
	
	on_wall = false
	var wall_points: Array[Node] = []
	wall_point = Vector3.INF
	
	for ray in wall_slide_rays:
		if ray.is_colliding():
			wall_points.append(ray)
			on_wall = true
		
	var i: int = 0
	for ray in wall_points:
		if wall_points[i].get_collision_point().distance_to(position + wall_rel_centre) < wall_point.distance_to(position + wall_rel_centre):
			wall_point = wall_points[i].get_collision_point()
			wall_normal = wall_points[i].get_collision_normal()
		i += 1
	#print(wall_point)
	DebugDraw3D.draw_square(wall_point, 0.2, Color.GREEN)
	DebugDraw3D.draw_line(wall_point, wall_point + wall_normal * 1.2, Color.GREEN)
	
	return
	
func state_wall_slide_check():
	if can_wall_slide():
		state_machine.change_state("wall_slide")
	
	#DebugDraw3D.draw_line(wall_point - wall_tan * 0.7, wall_point + wall_tan * 0.7, Color.BLUE)
	return
func can_wall_slide():
	#Player is matching direction of wall normal within a certain range, then wall_slide
	#find wall slide direction
	var cur_vel = hor_velocity.normalized()
	var wall_tan = wall_normal.rotated(Vector3.UP, PI/2)
	
	return abs(cur_vel.dot(wall_tan)) > wall_slide_angle_threshold && on_wall && speed > wall_slide_min_speed && abs(direction.dot(wall_tan)) > wall_slide_direction_threshold && direction.length() > 0.1
	
func state_wall_slide_jump_check():
	if on_wall && input_handler.is_action_buffered("jump"):
		state_machine.change_state("wall_slide_jump")
	return
