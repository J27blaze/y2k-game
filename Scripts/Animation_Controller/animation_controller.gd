extends Node
class_name AnimationController

## Still has anim bug where current step is inccorrect in some blend_anims

@export var parent: Node
@export var delete_skeleton: bool = true
@export var animation_tree: AnimationTree
@onready var animation_play_back: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var animation_state_machine: AnimationNodeStateMachine = animation_tree.tree_root

var transition_lookup: Dictionary[String, AnimationNodeStateMachineTransition]

@onready var skeleton_animplayer : AnimationPlayer = parent.find_child("AnimationPlayer", false)
var current_anim: String = "Start"
var previous_anim: String = "idle"
@onready var skeleton : Skeleton3D = parent.find_child("Skeleton3D", true) # orignial
@onready var mesh_skeleton : Skeleton3D = skeleton.duplicate() # copy

var bone_count: int = 0

var debug_status: String = ""
var costume_controller = CostumeController.new()

@export_category("Animation Parameters")
@export_range(0, 240, 1) var FB: int = 30
@export var animations_frames: Dictionary[String, AnimationFrame]

func _init() -> void:
	pass
func _ready() -> void:
	mesh_skeleton.name = "MeshSkeleton3D"
	parent.add_child(mesh_skeleton)
	
	#animation_tree.set_animation_player(get_path_to(skeleton_animplayer))
	animation_tree.active = true
	#skeleton_animplayer.play("idle")
	#print(mesh_skeleton.name)
	
	#set lookup table for transitions
	var tran_count: int = animation_state_machine.get_transition_count()
	for i in range(tran_count):
		var from: String = animation_state_machine.get_transition_from(i)
		var to: String = animation_state_machine.get_transition_to(i)
		var key : String = from + to
		
		if animations_frames.has(to):
			animation_state_machine.get_transition(i).xfade_time = f2f(animations_frames[to].startL, FB)
		
		transition_lookup[key] = animation_state_machine.get_transition(i)
		print(key + "" + str(i))
	
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
			
func play_anim_blend(anim_name: String, step_frame_length: int, blend_frames: int, blend_frame_length: int, fb: int = FB) -> void:
	previous_anim = current_anim
	#if current_anim != anim_name:
	current_anim = anim_name
	
	animation_play_back.travel(anim_name, false)
	if blend_t > 0:
		#fix blend studd, ALL THIS WILL BE PERPICATED SOON
		animation_play_back.next()
		pass
	#f2f(blend_frames, fb)
	start_blend_t(f2f(animations_frames[anim_name].startL), f2f(animations_frames[anim_name].duringF))
	start_t(f2f(animations_frames[anim_name].startF))
	
	#skeleton_animplayer.pause()
	#skeleton_animplayer.play(anim_name, f2f(blend_frames, fb))
	
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()

func play_anim(anim_name: String, step_frame_length: int, fb: int = FB) -> void:
	previous_anim = current_anim
	current_anim = anim_name
	
	animation_play_back.start(anim_name)
	
	blend_step_t = 0
	blend_t = 0
	start_t(f2f(animations_frames[anim_name].duringF))
	
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
	
#frames to float
func f2f(frame_length: float, frame_base: int = FB) -> float:
	return float(frame_length)/float(frame_base)

# depricated??????
func set_bone_position(bone_name: String, pos: Vector3):
	var bone := skeleton.find_bone(bone_name)
	print(bone)
	skeleton.set_bone_pose_position(bone, pos)
