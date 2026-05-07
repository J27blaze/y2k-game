extends Node
class_name CostumeController

@export var player_scene: Node
@onready var meshes = get_all_meshes(player_scene)

func get_all_meshes(node):
	var meshes = []
	
	if node is MeshInstance3D:
		meshes.append(node)
	for child in node.get_children():
		meshes += get_all_meshes(child)
	
	return meshes

var skin_colour: Vector3 = Vector3(1,0,1)

func _ready() -> void:
	#skin colour
	for mesh in meshes:
		mesh.get_active_material(0).set_shader_parameter("skin_colour", skin_colour)
