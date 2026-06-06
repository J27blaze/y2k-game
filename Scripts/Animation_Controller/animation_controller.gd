extends Node
class_name AnimationController

## Still has anim bug where current step is inccorrect in some blend_anims

@export var parent: Node
@export var delete_skeleton: bool = true

@onready var skeleton_animplayer : AnimationPlayer = parent.find_child("AnimationPlayer", false)
var current_anim: String
@onready var skeleton : Skeleton3D = parent.find_child("Skeleton3D", true)
@onready var mesh_skeleton : Skeleton3D = skeleton.duplicate()

var bone_count: int = 0

func _ready() -> void:
	parent.add_child(mesh_skeleton)
	#print(skeleton.get_children())
	
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
	current_anim = str(skeleton_animplayer.current_animation)
	t += delta
	
	#print(step_time)
	
	if t >= step_time:
		copy_skeleton_pose()
		t = 0
	
	if blend_step_t > 0:
		if blend_t <= blend_step_t:
			blend_t += delta
		else:
			start_t(await_anim_step)
			blend_t = 0
			blend_step_t = 0
			return
	
func copy_skeleton_pose() -> void:
	for bone_idx in range(bone_count):
		if bone_idx != -1:
			var pose = skeleton.get_bone_pose(bone_idx)
			mesh_skeleton.set_bone_pose(bone_idx, pose)
			
func play_anim_blend(anim_name: String, step_frame_length: int, blend_frames: int, blend_frame_length: int, fb: int = 24) -> void:
	if current_anim != anim_name:
		skeleton_animplayer.play(anim_name, f2f(blend_frames, fb))
		
		start_t(f2f(blend_frame_length, fb))
		start_blend_t(f2f(blend_frames, fb), f2f(step_frame_length, fb))
		
		skeleton_animplayer.advance(0)
		copy_skeleton_pose()

func play_anim(anim_name: String, step_frame_length: int, fb: int = 24) -> void:
	if current_anim != anim_name:
		skeleton_animplayer.play(anim_name, 0.0)
		start_t(f2f(step_frame_length, fb))
		
		skeleton_animplayer.advance(0)
		copy_skeleton_pose()

func start_t(length: float) -> void:
	step_time = length
	blend_step_t = 0
	t = 0
	
func start_blend_t(length: float, end_length) -> void:
	blend_step_t = length + 0.01
	blend_t = 0
	await_anim_step = end_length
	#print("#####START"+ str(length) +"######")
	
func f2f(frame_length, frame_base) -> float:
	return float(frame_length)/float(frame_base)
