extends Node
class_name CostumeController

var parts = [
	"body",
	"feet",
	"hands",
	"head",
	"lower_arm_l",
	"lower_arm_r",
	"upper_arm_l",
	"upper_arm_r",
	"neck",
	"shin_l",
	"shin_r",
	"thigh_l",
	"thigh_r"
]

@export var player_scene: Node
@onready var meshes = get_all_meshes(player_scene)
@onready var player_skeleton := player_scene.find_child("Skeleton3D", true)

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

@export var deform_attachables: Dictionary[String, DeformClothing]

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
		
@export var skin_colour: Color = Color.GRAY
@export var iris_colour: Color = Color.RED

func color2vec(color: Color) -> Vector3:
	return Vector3(color.r, color.b, color.g)

func set_materials():
	#skin colour
	for mesh in meshes:
		mesh.get_active_material(0).set_shader_parameter("skin_colour", color2vec(skin_colour))
	var head = get_all_meshes(player_scene, "head")
	for mesh in head:
		mesh.get_active_material(0).set_shader_parameter("iris_colour", color2vec(iris_colour))

func set_attachables():
	for scene in attachables:
		attach_mesh(scene)

func attach_deform(attach: String):
	var resource = deform_attachables[attach]
	var deform_attach = resource.scene.instantiate()
	#set skeleton
	for mesh in get_all_meshes(deform_attach):
		mesh.skeleton = player_skeleton.get_path()
	player_skeleton.add_child(deform_attach)
	#print(player_skeleton)
	
	for part in parts:
		if resource.get(part):
			print("HIDDEN")
			#hides the corridpsoning mesh
	#remove mesh

func set_deform_attachables():
	for scene in deform_attachables:
		attach_deform(scene)
		
func _ready() -> void:
	set_materials()
	
	#attachebles
	get_attach_points()
	set_attachables()
	set_deform_attachables()
