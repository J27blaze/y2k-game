class_name Player
extends CharacterBody3D

#player related
@onready var model_twist := $model_twist
var model_twist_override_angle : float = -999 #-999 is default value
var model_pitch : float = 0
var target_model_angle : Vector3

#controllers
@onready var camera_controller : CameraController = $player_camera_controller
@onready var animation_controller : AnimationController = $model_twist/animation_controller
@onready var vfx_controller : VFXController = $model_twist/VFX_controller

#colliders
@onready var standing_collider := $standing_collider
@onready var wall_slide_colliders := $wall_slide_colliders
@onready var floor_collider := $floor_collider
var wall_slide_rays: Array[Node]
var wall_rel_centre: Vector3 #0, 1.5, 0
var floor_normal: Vector3 = Vector3.ZERO
var god_mode: bool = false
@onready var step_collider := $step_collider
@onready var step_collider_range := $step_collider/range
@onready var step_collider_height := $step_collider/range/height
@onready var step_collider_shape := $step_collider/ShapeCast3D
@onready var step_ray_amount : int = step_collider.get_child_count(false)

#ui
@onready var ui: PlayerUI = $player_ui

#other
var centre: Vector3 = Vector3.ZERO
var height: float = 1.7
var style: int = 0 # 0-100 = one style point

#general movement
var direction: Vector3
var last_dir: Vector3 = Vector3.FORWARD
var hor_velocity: Vector3
var last_velocity: Vector3 = Vector3.ZERO
var camera_normal: Vector3 = Vector3.ZERO

var speed: float
var target_speed: float

var gravity: float

# input handlng
var input_handler = InputHandler.new()
var raw_input_dir: Vector2
var input_dir: Vector2

#player combbat
var health: int = 3 
var can_check_hurt_box: bool = true
@onready var hurt_box := $hurt_box
@onready var on_hurt_timer := $on_hurt_timer

@onready var state_machine := $state_machine

#region player variables
@export_category("Player Variables")

@export_range(0,20,0.01) var rotation_smoothing: float = 0.6
#@export var frame_step_length: int = 24
#endregion
#region run
@export_group("run") 
@export_range(0, 20, 0.1) var run_speed: float = 10.0
@export_range(0, 50, 0.1) var run_accel: float = 10.0
@export_range(0, 20, 0.05) var run_accel_speed: float = 10.0

@export_subgroup("step controls")
@export_range(0, 2, 0.01) var step_max_range : float = 0.5
@export_range(0, 2, 0.01) var step_max_height : float = 0.5
@export_range(0, 0.5, 0.001) var step_margin : float = 0.01
@export_range(1, 3, 0.01) var step_range_vel_multiplier : float = 1.
@export_range(0, 180, 0.5) var step_angle_range : float = 30
@export_range(0, 15, 1) var step_angle_amount_edging_count : float = 3

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

@export_subgroup("step controls")
@export_range(0, 2, 0.01) var air_step_max_height : float = 0.5
@export_range(0, 2, 0.01) var air_vault_max_height : float = 0.5
@export_range(1, 3, 0.005) var air_range_vel_multiplier : float = 1.
@export_range(0, 20, 0.05) var air_min_vault_speed_threshold : float = 2.
@export_range(0, 1, 0.01) var air_wall_score_threshold : float = 0.3 # higher the tighter mmmmphhhhhmhmhmm... tight..... k-kachaann...
var jump_stage: int = 0

@export_group("double_jump")
@export_range(0, 50, 0.05) var double_jump_vel_pulse: float = 10.
@export_range(0, 1, 0.001) var double_jump_vel_cut: float = 10.

@export_group("triple_jump")
@export_range(0, 50, 0.05) var triple_jump_vel_pulse: float = 10.
@export_range(0, 1, 0.001) var triple_jump_vel_cut: float = 10.
@export_range(0, 10, 0.05) var triple_jump_min_speed: float = 5.

#endregion
#region wall slide
@export_group("wall slide")
@export_range(0, 1, 0.01) var wall_slide_y_vel_cut: float = 0.5

@export_range(0, 2, 0.05) var wall_slide_range: float = 0.5
@export_range(0, 360, 0.5) var wall_slide_angle_range: float = 0.4
@export_range(0, 1, 0.05) var wall_slide_angle_threshold: float = 12.
@export_range(0, 1, 0.05) var wall_slide_direction_threshold: float = 12.

@export_range(0, 20, 0.1) var wall_slide_speed: float = 12.
@export_range(0, 20, 0.1) var wall_slide_min_speed: float = 12.

@export_range(0, 80, 0.05) var wall_slide_gravity: float = 10.
@export_range(0, 15, 0.05) var wall_slide_pull_force: float = 10.

@export_range(0, 10, 0.005) var camera_wall_slide_offset: float = 1.0

var can_wall_slide_air_dodge: bool = true

#endregion
#region wall slide jump
@export_group("wall slide jump")
@export_range(0, 8, 0.05) var wall_slide_jump_speed_increase: float = 5.
@export var wall_slide_jump_speed_increase_scaling: Curve
@export_range(0, 50, 0.05) var wall_slide_jump_vel_pulse: float = 17 #  slightly more than base jump

@export_range(0, 180, 0.05) var wall_slide_jump_min_angle: float = 5.
@export_range(0, 180, 0.05) var wall_slide_jump_max_angle: float = 45

@export_range(0, 50, 0.05) var wall_slide_jump_accel: float = 10.
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
@export_range(0, 60, 0.05) var slide_tangent_max_speed: float = 3.
@export_range(0, 1, 0.005) var slide_tangent_max_speed_slow: float = 3.

@export_range(0, 15, 1) var perfect_slide_after_frame_window: float = 3.
@export_range(0, 15, 0.05) var perfect_slide_speed_boost: float = 3.0
@export var perfect_slide_speed_boost_scaling: Curve
#endregion 
#region dodges
@export_group("dodges")
var air_dodges: int = 1
@export_range(0, 30, 0.05) var dodge_min_speed:float = 15.0
@export_range(0, 30, 0.05) var dodge_add_speed:float = 15.0
@export_range(0, 20, 0.05) var dodge_accel_speed: float = 10.0
@export_range(0, 10, 1) var dodge_initial_redirect_frame:int = 2
@export var dodge_angle_clamp : Curve
@export_range(0, 5, 1) var max_air_dodges: float = 1

@export_range(0, 25, 0.05) var ground_dodge_vel_pulse:float = 3.0

@export_range(0, 25, 0.05) var air_dodge_vel_pulse:float = 3.0
@export_range(0, 80, 0.05) var air_dodge_gravity: float = 10.

@export_group("dodges - jump")
@export_range(0, 50, 0.05) var dodge_jump_vel_pulse: float = 10.
@export_range(0, 20, 0.01) var dodge_jump_speed: float = 10.
@export_range(0, 60, 1) var dodge_jump_frames: float = 10.
@export_range(0, 40, 0.05) var dodge_jump_accel: float = 10.

@export_range(0, 20, 0.005) var dodge_jump_speed_increase: float = 10.
@export var dodge_jump_speed_boost_scaling: Curve
#endregion 

#region vault jump
@export_group("vault jump")
@export_range(0, 50, 0.05) var vault_jump_vel_pulse: float = 10.
@export_range(0, 40, 0.05) var vault_jump_accel: float = 10.
@export_range(0, 20, 1) var vault_jump_min_hold_frames: float = 4.
@export_range(0, 1, 0.001) var vault_jump_vel_height_cut: float = 0.8

@export_range(0, 20, 0.1) var vault_min_speed: float = 10.0
@export_range(0, 10, 0.1) var vault_perfect_speed_boost: float = 10.0
@export var vault_perfect_speed_boost_scaling: Curve
#endregion

#region weapon_dash
@export_group("dash")
@export_range(-1, 1, 0.01) var weapon_dash_min_angle: float = 0.1
#refers to thew area shape, not node
var target: Node = null
@export_range(0, 60, 0.01) var weapon_dash_speed: float = 0.1
@export var weapon_dash_speed_timer_scaler: Curve #x = physics frames
@export_range(0, 60, 0.01) var weapon_dash_target_speed: float = 0.1
@export_range(0, 60, 0.01) var weapon_dash_hit_aceel: float = 2.
@export_range(0, 20, 0.005) var weapon_dash_hit_speed_aceel: float = 2.
@export_range(0, 1, 0.005) var weapon_dash_hit_y_speed_multiplier: float = 0.8
@export_range(0, 1, 0.005) var weapon_dash_hit_y_cut: float = 0.8
@export_range(0, 50, 0.01) var weapon_dash_hit_vel_pulse: float = 2.
@export_range(0, 50, 0.01) var weapon_dash_hit_gravity: float = 2.
@export_range(0, 10, 1) var weapon_dash_damage: float = 1
@export_subgroup("forward")
@export_range(0, 360, 0.5) var weapon_dash_hit_angle_range: float = 20.
@export_subgroup("backward")
@export_range(0, 20, 0.01) var weapon_dash_hit_backward_speed: float = 6.
@export_range(-1, 1, 0.005) var weapon_dash_hit_dot_threshold: float = 0
#endregion
#region attacks
@export_group("attack")
var is_attacking: bool = false
var attack_stage: int = 0
@onready var append_attack_state : AppendAttackState = $state_machine/append_attack
@export var attack_anim_speeds : Array[float] = [0,0,0] # attack one anim length, attack two anim length ...
@export var attack_input_speeds : Array[float] = [0,0,0]

@export var air_attack_anim_speeds : Array[float] = [0,0,0] # attack one input buffer length, attack two input buffer length ...
@export var air_attack_input_speeds : Array[float] = [0,0,0]

@export var max_combo: int = 1 #, 0, 1
@export_range(0,2,0.05) var attack_combo_speed := 0.0

@export_range(0, 1, 0.005) var air_attack_y_cut : float = 0.8
@export_range(0, 1, 0.005) var air_attack_fall_y_cut : float = 0.8
#endregion


func _ready() -> void:
	#debug
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_machine.init(self)
	camera_controller.set_smoothing("mid")
	camera_controller.set_offset_smoothing("slow")
	camera_controller.set_offset(Vector3.ZERO)
	
	#set wall slide range
	var ray_amount = wall_slide_colliders.get_child_count()
	print(ray_amount)
	var i = 0
	for ray in wall_slide_colliders.get_children():
		ray.target_position = Vector3(0, 0, wall_slide_range)
		ray.rotation.y = deg_to_rad(180 - wall_slide_angle_range/2 + (i+1)*(wall_slide_angle_range/ray_amount))
		
		wall_slide_rays.append(ray)
		
		i += 1
	
	wall_rel_centre = wall_slide_colliders.position
	
	#set step stuff
	snap_step(0)
	
	height = standing_collider.shape.height
	gravity = fall_gravity
	air_dodges = max_air_dodges

func _input(event: InputEvent):
	#debug stuff
	
	raw_input_dir =  input_handler.get_raw_input_dir()
	input_dir =  input_handler.get_input_dir()
	
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
	
	step_collider.global_rotation.y = Vector3.FORWARD.signed_angle_to(last_dir, Vector3.UP)
	
	input_handler.process_physics(delta)
	state_machine.process_physics(delta)
	state_machine.always_physics_update(delta)
	
	if Input.is_action_just_pressed("debug_mode"):
		god_mode = !god_mode
		if god_mode:
			state_machine.change_state("god_mode")
	
	#player_slide
	floor_normal = floor_collider.get_collision_normal() * int(floor_collider.is_colliding())
	
	ui.last_speed = speed
	move_and_slide()
	
	hor_velocity = Vector3(velocity.x, 0, velocity.z)
	speed = Vector3(velocity.x, 0, velocity.z).length()
	
	ui.cur_speed = speed
	
	#gravity
	if !is_on_floor():
		velocity.y = clampf(velocity.y - gravity * delta, -fall_terminal_vel, 999999)
	
	#print(jump_stage)
	
func _process(delta: float):
	#adds the camera rot to movement
	camera_controller.process(delta)
	#ui
	ui.camera_dir = camera_controller.camera_dir
	ui.mouse_dir = camera_controller.export_mouse_dir
	
	direction = (camera_controller.twist_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	camera_normal = (-camera_controller.global_transform.basis.z).normalized()
	#player.rotation
	if model_twist_override_angle != -999:
		target_model_angle.y = model_twist_override_angle
	else:
		target_model_angle.y = lerp_angle(target_model_angle.y, atan2(-last_dir.x, -last_dir.z),  rotation_smoothing * delta)#Vector3.FORWARD.signed_angle_to(last_dir, Vector3.UP)
	target_model_angle.x = lerp_angle(target_model_angle.x, model_pitch,  rotation_smoothing * delta)
	
	model_twist.rotation = target_model_angle
	
	state_machine.process_frame(delta)
	
	centre = position + Vector3.UP * height/2

#Global Movement Functions
func vel_move_toward(target_vector: Vector3, accel: float, delta: float):
	velocity.x = velocity.move_toward(target_vector, accel * delta).x
	velocity.z = velocity.move_toward(target_vector, accel * delta).z

func lerp_target_speed(speed_margin: float, accel: float, delta: float):
	var condition: bool = speed < target_speed - speed_margin
	if condition:
		target_speed = lerpf(target_speed, speed, accel * delta)
		
#Add air strafe BY USING SLIDE CODE

# State changes check
func state_landing_check() -> bool:
	if is_on_floor():
		can_jump = true
		can_wall_slide_air_dodge = true
		air_dodges = int(max_air_dodges)
		
		if direction == Vector3.ZERO:
			state_machine.change_state("idle")
		else:
			if Input.is_action_pressed("slide"):
				state_machine.change_state("slide")
			else:
				state_machine.change_state("run")
		
		increment_jump_stage()
		
		return true
	else:
		return false

#stage jumps
@onready var jump_stage_timer := $jump_stage_timer
func increment_jump_stage() -> void:
	if jump_stage >= 3:
		jump_stage = 0
	else: jump_stage += 1
	jump_stage_timer.start()

func _on_jump_stage_timer_timeout() -> void:
	jump_stage = 0

func state_jump() -> bool:
	if input_handler.is_action_buffered("jump") && can_jump:
		var stage: String = ""
		match jump_stage:
			2:
				stage = "double_"
			3:
				if speed > triple_jump_min_speed:
					stage = "triple_"
				else:
					stage = ""
					jump_stage = 0
			_:
				stage = ""
		state_machine.change_state(stage + "jump")
		return true
	else:
		return false

func state_dodge_check() -> bool:
	if input_handler.is_action_buffered("dodge") && air_dodges > 0:
		match state_machine.current_state.name:
			"run", "idle", "slide":
				state_machine.change_state("ground_dodge", "ground")
				return true
			"jump", "wall_slide_jump", "fall", "air_attack", _:
				state_machine.change_state("air_dodge", "air")
				return true
	else:
		return false


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

func state_wall_slide_check() -> bool:
	if can_wall_slide():
		state_machine.change_state("wall_slide")
		return true
	else:
		return false
	#DebugDraw3D.draw_line(wall_point - wall_tan * 0.7, wall_point + wall_tan * 0.7, Color.BLUE)
	
func can_wall_slide() -> bool:
	#Player is matching direction of wall normal within a certain range, then wall_slide
	#find wall slide direction
	var cur_vel = hor_velocity.normalized()
	var wall_tan = wall_normal.rotated(Vector3.UP, PI/2)
	
	return abs(cur_vel.dot(wall_tan)) > wall_slide_angle_threshold && on_wall && speed > wall_slide_min_speed && abs(direction.dot(wall_tan)) > wall_slide_direction_threshold && direction.length() > 0.1

func snap_step(delta: float):
	var i : int = 0
	
	var can_step: bool = true
	var step_positions : Array[Vector3] = []
	var step_normals : Vector3 = Vector3.ZERO
	var is_a_flat_normal : bool = false
	
	var final_pos: Vector3 = Vector3.ZERO
	var correction : Vector3 = Vector3.ZERO
	#print(speed*delta)
	#print(floor_normal)
	# set step colliders
	for ray in step_collider.get_children(false):
		var range = ray			#get the forward ray
		var height_ray = ray.get_child(0)			# get the vertical ray
		
		position_snap_step_rays(range, height_ray, i, delta)
		
		#calc
		if !range.is_colliding() && height_ray.is_colliding():
			step_positions.append(height_ray.get_collision_point())
			step_normals += height_ray.get_collision_normal()
			if height_ray.get_collision_normal().dot(Vector3.UP) > 0.995: is_a_flat_normal = true
			#print( height_ray.get_collision_normal().dot(Vector3.UP))
			final_pos += height_ray.get_collision_point()
			
			DebugDraw3D.draw_square(height_ray.get_collision_point(), 0.1, Color.RED)
			
			if i < step_angle_amount_edging_count || i > step_ray_amount-1 - step_angle_amount_edging_count:
				can_step = false
			
		i += 1
	
	step_normals /= step_positions.size()
	if step_positions.size() > 0 && can_step && step_normals.dot(Vector3.UP) > 0.95 && is_a_flat_normal:
		final_pos /= step_positions.size()
		var corr: Vector3 = final_pos - position
		correction = Vector3(corr.x, 0, corr.z)
		#print(correction)
		
		#the final formula
		position = final_pos - (correction.normalized() * (correction.length() - 0.05)) + Vector3.UP * step_margin
		print("stepped!")
		
		
	DebugDraw3D.draw_square(final_pos, 0.2, Color.GREEN)
	DebugDraw3D.draw_line(final_pos, final_pos + correction, Color.YELLOW)
	DebugDraw3D.draw_square(position, 0.2, Color.BLUE)
	
	#print(final_pos)
	#print(step_positions.size())

func position_snap_step_rays(range: Node, height_ray: Node, index: int, delta: float, range_mult : float = step_range_vel_multiplier, cur_height: float = step_max_height + step_margin):
	var cur_range: float = (step_max_range + step_margin + speed*delta)*range_mult
	#var cur_height: float = step_max_height + step_margin
	
	range.rotation.y = deg_to_rad(index*step_angle_range/step_ray_amount*2 - step_angle_range + step_angle_range/step_ray_amount)
	range.position = Vector3(0, cur_height, 0)
	height_ray.position = Vector3(0, 0, -cur_range)
	range.target_position = Vector3(0,0,-cur_range)
	height_ray.target_position = Vector3(0,-cur_height + step_margin,0)
	
	range.force_raycast_update()
	height_ray.force_raycast_update()
			
	#if i < step_angle_amount_edging_count || i > step_ray_amount-1 - step_angle_amount_edging_count:
	var col: float = float(index)/step_ray_amount
	DebugDraw3D.draw_square(height_ray.global_position , 0.1, Color(col,col,col))

@onready var vault_wall_check : RayCast3D = $vault_wall_check
@onready var air_step_buffer : Timer = $air_step_buffer
func state_vault_snap_step(delta: float) -> bool:
	#initial conditions
	if target_speed > air_min_vault_speed_threshold:#  && velocity.y < 0:
		var i : int = 0
		
		var step_positions : Array[Vector3] = []
		var final_pos : Vector3 = Vector3.ZERO
		
		for ray in step_collider.get_children(false):
			
			var range = ray
			var height_ray = ray.get_child(0)
			
			position_snap_step_rays(range, height_ray, i, delta, air_range_vel_multiplier, air_vault_max_height + step_margin)
			
			if !range.is_colliding() && height_ray.is_colliding():
				step_positions.append(height_ray.get_collision_point())
				final_pos += height_ray.get_collision_point()
				
				DebugDraw3D.draw_square(height_ray.get_collision_point(), 0.1, Color.RED)
			
			i += 1
		
		if step_positions.size() > 0:
			final_pos /= step_positions.size()
			DebugDraw3D.draw_square(final_pos, 0.2, Color.GREEN)
			
			vault_wall_check.enabled = true
			var vault_wall_pos = Vector3(position.x, final_pos.y - 0.05, position.z)
			vault_wall_check.position = vault_wall_pos
			vault_wall_check.target_position = final_pos - Vector3(0, 0.05, 0) - vault_wall_pos
			
			var wall_score : float = vault_wall_check.get_collision_normal().dot(last_dir.normalized())
			
			DebugDraw3D.draw_line(position, position + vault_wall_check.get_collision_normal() * 3, Color.RED)
			DebugDraw3D.draw_line(position, position + last_dir.normalized() * 3, Color.YELLOW)
			
			#print(wall_score)
			
			if air_wall_score_threshold < -wall_score && speed > 0.1 && air_step_buffer.is_stopped():
				if abs(final_pos.y - position.y) <= air_step_max_height + step_margin:
					#step when falling
					var corr: Vector3 = final_pos - position
					var correction = Vector3(corr.x, 0, corr.z)
					position = final_pos + (Vector3.UP * step_margin) - (correction.normalized() * (correction.length() - 0.05))
					air_step_buffer.start()
					if velocity.y < 0:
						state_landing_check()
					print("air stepped!")
					return false
				else:
					state_machine.change_state("vaulting", [final_pos, vault_wall_check.get_collision_normal()])
					return true
		
	return false

func _on_air_step_buffer_timeout() -> void:
	pass # Replace with function body.
	
func state_wall_slide_jump_check() -> bool:
	if on_wall && input_handler.is_action_buffered("jump"):
		state_machine.change_state("wall_slide_jump")
		return true
	else: return false

func state_weapon_dash_check() -> bool:
	if input_handler.is_action_buffered("weapon_dash") && target != null:
		state_machine.change_state("weapon_dash")
		return true
	else:
		return false

#attack
func append_weapon_attack(state: String) -> bool:
	if input_handler.is_action_buffered("weapon_attack") && !is_attacking || Input.is_action_pressed("weapon_attack") && !is_attacking :
		input_handler.clear_action_buffer("weapon_attack")
		
		#hard coding go crazy
		append_attack_state.attack(state)
		
		return true
	return false

func state_air_attack() -> bool:
	if input_handler.is_action_buffered("weapon_attack") && !is_attacking || Input.is_action_pressed("weapon_attack") && !is_attacking :
		state_machine.change_state("attack_air")
		return true
	return false

#hit
var hit_boxes: Array[Area3D]
func hit_check() -> bool:
	if can_check_hurt_box:
		if hurt_box.has_overlapping_areas():
			hit_boxes = hurt_box.get_overlapping_areas()
			health -= hit_boxes[0].damage
			print(health)
			
			on_hit()
			
			return true
	return false
	
func state_tumble_check() -> bool:
	#GENUINLY WTF DOES THIS MEAN LOLLLLLOLOLOLOLOLOOLOPL
	if can_check_hurt_box:
		if hurt_box.has_overlapping_areas():
			if hit_boxes[0].tumble:
				print("tumble")
				#add tumble state
				return true
	return false

func on_hit() -> void:
	set_hurt_box(false)
	on_hurt_timer.start()
func _on_hurt_timer_timeout() -> void:
	set_hurt_box(true)
func set_hurt_box(state: bool):
	hurt_box.monitoring = state
	can_check_hurt_box = state
