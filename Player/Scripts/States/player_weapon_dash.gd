extends PlayerState

@onready var area_collider := $enemy_targeting_collider/shape
var enemies: Array[Node] = []
@export var enemy_pos_targeting_offset: Vector3 = Vector3.ZERO
var target_pos: Vector3 = Vector3.ZERO

func init() -> void:
	var shape = CylinderShape3D.new()
	shape.radius = player.dash_radius
	shape.height = player.dash_radius
	area_collider.shape = shape

func always_process_physics(delta: float):
	area_collider.position = player.position
	if !enemies.is_empty():
		calc_target()
	else:
		return

func _on_enemy_targeting_collider_area_entered(area: Area3D) -> void:
	enemies.append(area)
	print(enemies)

func _on_enemy_targeting_collider_area_exited(area: Area3D) -> void:
	enemies.erase(area)
	print(enemies)

func calc_target():
	#gets normals
	for enemy in enemies:
		var enemy_pos: Vector3 = enemy.global_position + enemy_pos_targeting_offset
		var camera_dir: Vector3 = player.camera_normal
		var enemy_dir: Vector3 = player.position.direction_to(enemy_pos)
		
		DebugDraw3D.draw_line(enemy_pos, enemy_pos - enemy_dir * 2, Color.CHARTREUSE)
		DebugDraw3D.draw_line(enemy_pos, enemy_pos - camera_dir * 5, Color.CHOCOLATE)
		#print(player.camera_normal)
	
	#get raycast
	
func start():
	return

func exit():
	return

func process_physics(delta: float):
	return
