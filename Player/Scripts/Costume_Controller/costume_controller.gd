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

@export var attachables: Dictionary[String, PackedScene]
@export var attachable_offset: Dictionary[String, Vector3]
var attachable_points: Dictionary[String, Node]

func get_attach_points():
	for scene in attachables:
		attachable_points[scene] = player_scene.find_child(scene, true)
		#print(scene)
	#print(attachable_points)
		
func attach_mesh(bone_name: String):
	if attachables.has(bone_name) && attachables.has(bone_name):
		var attach = attachables[bone_name].instantiate()
		attach.position += attachable_offset[bone_name]
		attachable_points[bone_name].add_child(attach)
		
var skin_colour: Vector3 = Vector3(1,0,1)
var iris_colour: Vector3 = Vector3(1,0,0)

func set_materials():
	#skin colour
	for mesh in meshes:
		mesh.get_active_material(0).set_shader_parameter("skin_colour", skin_colour)
	var head = get_all_meshes(player_scene, "head")
	for mesh in head:
		mesh.get_active_material(0).set_shader_parameter("iris_colour", iris_colour)

func set_attachables():
	for scene in attachables:
		attach_mesh(scene)

func _ready() -> void:
	set_materials()
	
	#attachebles
	get_attach_points()
	set_attachables()
