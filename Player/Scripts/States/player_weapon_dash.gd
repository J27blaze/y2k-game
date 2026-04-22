extends PlayerState

#raycast pool
@export_range(0, 64, 1) var raycast_pool_size: int = 1 
@onready var area_collider := $enemy_targeting_collider
@onready var ray_node := $base/ray
@onready var base := $base

var rays : Array[Node] = []
var active_rays : Array[Node] = []
var enemies: Array[Node] = []

var target: Node = null

@export var enemy_pos_targeting_offset: Vector3 = Vector3.ZERO

func init() -> void:
	#var shape = CylinderShape3D.new()
	#shape.radius = player.dash_radius
	#shape.height = player.dash_radius
	#area_collider.shape = shape
	
	weapon_hitbox_col.disabled = true
	
	#add rays
	for i in raycast_pool_size-1:
		base.add_child(ray_node.duplicate(true))
	for ray in base.get_children():
		rays.append(ray)
	print(rays)

func always_process_physics(delta: float):
	area_collider.position = player.position
	base.position = player.position
	if !enemies.is_empty():
		calc_target()
	else:
		target = null
		player.target = target

func _on_enemy_targeting_collider_area_entered(area: Area3D) -> void:
	enemies.append(area)
	var new_ray = filter_deactive_rays().front()
	
	if new_ray != null: #check if ray is within ray pool
		new_ray.enabled = true
		
		active_rays.append(new_ray)
		#print(active_rays)
func filter_deactive_rays():
	var filtered_rays: Array[Node]
	for ray in rays:
		if !ray.enabled:
			filtered_rays.append(ray)
			
	return filtered_rays

func _on_enemy_targeting_collider_area_exited(area: Area3D) -> void:
	enemies.erase(area)
	var new_ray = active_rays.back()
	
	if new_ray != null:
		new_ray.enabled = false
		new_ray.target_position = Vector3.ZERO
		active_rays.erase(new_ray)
		
		#print(active_rays)

func calc_target():
	var i: int = 0
	var vector_dots: Array[float] = []
	var targetable_ememies: Array[Node] = []
	
	for enemy in enemies:
		#get raycast
		var enemy_pos: Vector3 = enemy.global_position + enemy_pos_targeting_offset
		var ray_target_pos = enemy_pos - player.centre
		active_rays[i].target_position = ray_target_pos
		
		#get on screen
		var enemy_on_screen: bool = enemy.get_parent().is_on_screen()
		
		#gets normals
		var camera_dir: Vector3 = player.camera_normal.normalized()
		var enemy_dir: Vector3 = player.centre.direction_to(enemy_pos).normalized()
		var dot = camera_dir.dot(enemy_dir)
		
		DebugDraw3D.draw_line(enemy_pos, enemy_pos - enemy_dir * 2, Color.CHARTREUSE)
		DebugDraw3D.draw_line(enemy_pos, enemy_pos - camera_dir * 2, Color.CHOCOLATE)
		
		if !active_rays[i].is_colliding() && enemy_on_screen && dot > player.weapon_dash_min_angle: # enemy can be targeted
			targetable_ememies.append(enemy)
			
			vector_dots.append(dot)
			
			#print(player.camera_normal)
			
		i += 1
		
	#print(vector_dots)
	if vector_dots.find(vector_dots.max()) != -1:
		target = targetable_ememies[vector_dots.find(vector_dots.max())]
		DebugDraw3D.draw_square(target.global_position, 1, Color.GREEN)
	else:
		target = null 
	player.target = target

#player movement
var initial_speed: float =0.0
@onready var min_dash_time := $min_dash_time
var dir: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO

@onready var weapon_hitbox := $weapon_hitbox
@onready var weapon_hitbox_col := $weapon_hitbox/shape

func start():
	#assumed target is not null.
	target_position = target.global_position + enemy_pos_targeting_offset
	var initial_vel: Vector3 = player.velocity
	initial_speed = player.target_speed
	
	dir = player.centre.direction_to(target_position) * player.weapon_dash_speed
	player.target_speed = player.weapon_dash_target_speed #clampf(Vector3(dir.x, 0, dir.z).length(), 0, player.weapon_dash_target_speed)
	
	weapon_hitbox.position = player.global_position
	weapon_hitbox_col.disabled = false
	
	min_dash_time.start()

func _on_min_dash_time_timeout() -> void:
	change_state("fall")

func exit():
	weapon_hitbox_col.disabled = true
	return

func process_physics(delta: float):
	if player.state_dodge_check():
		return
	if weapon_hitbox.has_overlapping_areas():
		change_state("jump")
		return
	
	player.velocity = dir
	weapon_hitbox.position = player.global_position
