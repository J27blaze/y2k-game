extends PlayerState

#raycast pool
@export_range(0, 64, 1) var raycast_pool_size: int = 1 
@onready var area_collider := $enemy_targeting_collider/shape
@onready var ray_node := $base/ray
@onready var base := $base

var rays : Array[Node] = []
var active_rays : Array[Node] = []
var enemies: Array[Node] = []

@export var enemy_pos_targeting_offset: Vector3 = Vector3.ZERO
var target_pos: Vector3 = Vector3.ZERO

func init() -> void:
	var shape = CylinderShape3D.new()
	shape.radius = player.dash_radius
	shape.height = player.dash_radius
	area_collider.shape = shape
	
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
		return

func _on_enemy_targeting_collider_area_entered(area: Area3D) -> void:
	enemies.append(area)
	var new_ray = filter_deactive_rays().front()
	
	if new_ray != null: #check if ray is within ray pool
		new_ray.enabled = true
		
		active_rays.append(new_ray)
		print(active_rays)
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
		
		print(active_rays)

func calc_target():
	var i: int = 0
	for enemy in enemies:
		#gets normals
		var enemy_pos: Vector3 = enemy.global_position + enemy_pos_targeting_offset
		var camera_dir: Vector3 = player.camera_normal
		var enemy_dir: Vector3 = player.centre.direction_to(enemy_pos)
		
		DebugDraw3D.draw_line(enemy_pos, enemy_pos - enemy_dir * 2, Color.CHARTREUSE)
		DebugDraw3D.draw_line(enemy_pos, enemy_pos - camera_dir * 5, Color.CHOCOLATE)
		#print(player.camera_normal)
		
		#get raycast
		var ray_target_pos = enemy_pos - player.centre
		active_rays[i].target_position = ray_target_pos
		
		i += 1
	
func start():
	return

func exit():
	return

func process_physics(delta: float):
	return
