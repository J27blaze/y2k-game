extends Node
class_name AnimationController

## Still has anim bug where current step is inccorrect in some blend_anims

@export var parent: Node
@export var delete_skeleton: bool = true
@export var animation_tree: AnimationTree

@onready var skeleton_animplayer : AnimationPlayer = parent.find_child("AnimationPlayer", false)
var current_anim: String
var previous_anim: String
@onready var skeleton : Skeleton3D = parent.find_child("Skeleton3D", true) # orignial
@onready var mesh_skeleton : Skeleton3D = skeleton.duplicate() # copy

var bone_count: int = 0

var debug_status: String = ""
var costume_controller = CostumeController.new()

@export_category("Animation Parameters")
@export_range(0, 240, 1) var FB := 30

func _init() -> void:
	pass
func _ready() -> void:
	mesh_skeleton.name = "MeshSkeleton3D"
	parent.add_child(mesh_skeleton)
	
	#animation_tree.set_animation_player(get_path_to(skeleton_animplayer))
	animation_tree.active = true
	#skeleton_animplayer.play("idle")
	#print(mesh_skeleton.name)
	
	#mesh_skeleton.get_children()
	for mesh in costume_controller.get_all_meshes(mesh_skeleton):
		mesh.skeleton = mesh_skeleton.get_path()
	
	#delete acess mesh
	if delete_skeleton:
		var children : Array[Node] = skeleton.get_children()
		for i in range(children.size()):
			children[i].queue_free()
	else:
		skeleton.position.x = 1
	
	bone_count = skeleton.get_bone_count()
	start_t(1)

var t: float = 0
var step_time: float = 0

var blend_t: float = 0
var blend_step_t: float = 0

var await_anim_step : float = 0.4

func _process(delta: float) -> void:
	#current_anim = str(skeleton_animplayer.current_animation)
	t += delta
	
	if t >= step_time:
		copy_skeleton_pose()
		t = 0
	
	if blend_step_t > 0:
		if blend_t < blend_step_t:
			blend_t += delta
		else:
			blend_t = 0
			blend_step_t = 0
			
			start_t(await_anim_step)
			return
	
func copy_skeleton_pose() -> void:
	for bone_idx in range(bone_count):
		if bone_idx != -1:
			var pose = skeleton.get_bone_pose(bone_idx)
			mesh_skeleton.set_bone_pose(bone_idx, pose)
			
func play_anim_blend(anim_name: String, step_frame_length: int, blend_frames: int, blend_frame_length: int, fb: int = 24) -> void:
	previous_anim = current_anim
	#if current_anim != anim_name:
	current_anim = anim_name
	if blend_t > 0:
		#fix blend studd, ALL THIS WILL BE PERPICATED SOON
		#skeleton_animplayer.play(skeleton_animplayer.current_animation, 0.0)
		pass
	
	start_blend_t(f2f(blend_frames, fb), f2f(step_frame_length, fb))
	start_t(f2f(blend_frame_length, fb))
	
	#skeleton_animplayer.pause()
	#skeleton_animplayer.play(anim_name, f2f(blend_frames, fb))
	
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()

func play_anim(anim_name: String, step_frame_length: int, fb: int = 24) -> void:
	previous_anim = current_anim
	#if current_anim != anim_name:
	current_anim = anim_name
	
	#skeleton_animplayer.stop() 
	
	blend_step_t = 0
	blend_t = 0
	start_t(f2f(step_frame_length, fb))
	
	#skeleton_animplayer.pause()
	#skeleton_animplayer.play(anim_name, 0.0)
	
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()

func start_t(length: float) -> void:
	step_time = length
	t = 0
	#debug
	skeleton_animplayer.advance(0)
	debug_status = (str(length) + " : " + current_anim + ", blend length : " + str(blend_step_t))
	
	#print(debug_status)
	
func start_blend_t(length: float, end_length) -> void:
	blend_step_t = length + 0.017
	blend_t = 0
	await_anim_step = end_length
	#print(blend_step_t)
	#print("#####START"+ str(length) +"######")
	
func f2f(frame_length, frame_base) -> float:
	return float(frame_length)/float(frame_base)

func set_bone_position(bone_name: String, pos: Vector3):
	var bone := skeleton.find_bone(bone_name)
	print(bone)
	skeleton.set_bone_pose_position(bone, pos)
