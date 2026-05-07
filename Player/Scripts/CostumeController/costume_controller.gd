extends Node
class_name CostumeController

@export var player_scene: Node
@onready var meshes = get_all_meshes(player_scene)

func get_all_meshes(node, filter=null):
	var meshes = []
	if filter == null:
		
		if node is MeshInstance3D:
			meshes.append(node)
		for child in node.get_children():
			meshes += get_all_meshes(child)
	else:
		if node is MeshInstance3D:
			if node.name.contains(filter):	meshes.append(node)
		for child in node.get_children():
			meshes += get_all_meshes(child, filter)
		
	return meshes
	
var skin_colour: Vector3 = Vector3(1,0,1)
var iris_colour: Vector3 = Vector3(1,0,0)

func _ready() -> void:
	#skin colour
	for mesh in meshes:
		mesh.get_active_material(0).set_shader_parameter("skin_colour", skin_colour)
	var head = get_all_meshes(player_scene, "head")
	for mesh in head:
		mesh.get_active_material(0).set_shader_parameter("iris_colour", iris_colour)
