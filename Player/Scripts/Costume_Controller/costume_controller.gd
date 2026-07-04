extends Node
class_name CostumeController

# MAKE SURE THIS IS IN ORDER TO THE PLAYER_FINAL FILE
# AS SORTING THRU JUST USES INDEX, NOTHING ELSE
var parts = [
	"body",
	"body_lower",
	"clavicles",
	"feet",
	"hands",
	"head",
	"lower_arm_l",
	"lower_arm_r",
	"neck",
	"shin_l",
	"shin_r",
	"thigh_l",
	"thigh_r",
	"upper_arm_l",
	"upper_arm_r"
]

@export var anim_controller: Node
@onready var player_scene = anim_controller.mesh_skeleton
@onready var meshes = get_all_meshes(player_scene)
#@onready var player_skeleton = player_scene.find_child("MeshSkeleton3D", true)

func get_all_meshes(node, filter=null) :
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

@export var attachables: Dictionary[String, AttachClothing]
var attachable_points: Dictionary[String, Node]

@export var deform_attachables: Dictionary[String, DeformClothing]

func get_attach_points():
	for scene in attachables:
		attachable_points[scene] = player_scene.find_child(scene, true, false)
		#print(scene)
		#print(player_scene.get_tree_string())
		
func attach_mesh(bone_name: String):
	if attachables.has(bone_name):
		var attach = attachables[bone_name].scene.instantiate()
		attach.position += attachables[bone_name].offset
		attachable_points[bone_name].add_child(attach)
		
		#hair
		if bone_name == "hair":
			hair_scene = attach
		
@export var skin_colour: Color = Color.GRAY
@export var iris_colour: Color = Color.RED
@export var hair_colour: Color = Color.BROWN
var hair_scene

func set_materials():
	#skin colour
	for mesh in meshes:
		mesh.get_active_material(0).set_shader_parameter("skin_colour", skin_colour)
	var head = get_all_meshes(player_scene, "head")
	for mesh in head:
		mesh.get_active_material(0).set_shader_parameter("iris_colour", iris_colour)
		
	#hair
	#print(get_all_meshes(hair_scene))
	get_all_meshes(hair_scene)[0].get_active_material(0).set_shader_parameter("hair_colour", hair_colour)

func set_attachables():
	for scene in attachables:
		attach_mesh(scene)

func attach_deform(attach: String):
	var resource = deform_attachables[attach]
	var deform_attach = resource.scene.instantiate()
	#set skeleton
	for mesh in get_all_meshes(deform_attach):
		mesh.skeleton = player_scene.get_path()
	player_scene.add_child(deform_attach)
	#print(player_skeleton)
	
	for i in parts.size():
		if resource.get(parts[i]):
			meshes.get(i).visible = false
			#print(meshes.get(i).name)
	
	#remove mesh

func set_deform_attachables():
	for scene in deform_attachables:
		attach_deform(scene)
		
func _ready() -> void:
	#print(player_scene.name)
	get_attach_points()
	
	update_costume()

func update_costume():
	#print(meshes)
	#attaches
	set_attachables()
	set_deform_attachables()
	# meow
	set_materials()

func _process(delta: float) -> void:
	# DEBUG
	if Input.is_key_pressed(KEY_P):
		update_costume()
