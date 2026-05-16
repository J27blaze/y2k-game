extends Node
class_name AnimationController

@export var parent: Node
@export var delete_skeleton: bool = true

@onready var skeleton_animplayer : AnimationPlayer = parent.find_child("AnimationPlayer", false)
@onready var skeleton : Skeleton3D = parent.find_child("Skeleton3D", true)
@onready var mesh_skeleton : Skeleton3D = skeleton.duplicate()

var bone_count: int = 0

@onready var timer_step := $timer_step
@onready var blend_step := $blend_step
var await_anim_step : float = 0.4

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
	set_step_length(1)

func copy_skeleton_pose() -> void:
	for bone_idx in range(bone_count):
		if bone_idx != -1:
			var pose = skeleton.get_bone_pose(bone_idx)
			mesh_skeleton.set_bone_pose(bone_idx, pose)
			
func play_anim_blend(anim_name: String, step_frame_length: int, blend_frames: int, blend_frame_length: int, fb: int = 24) -> void:
	blend_step.stop()
	
	skeleton_animplayer.play(anim_name, f2f(blend_frames, fb))
	set_step_length(f2f(blend_frame_length, fb))

	timer_step.start()
	blend_step.wait_time = f2f(blend_frames, fb)
	blend_step.start()
	await_anim_step = f2f(step_frame_length, fb)
	
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()

func play_anim(anim_name: String, step_frame_length: int, fb: int = 24) -> void:
	skeleton_animplayer.play(anim_name, 0.0)
	set_step_length(f2f(step_frame_length, fb))
	
	timer_step.start()
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()

func _process(delta: float) -> void:
	print(timer_step.wait_time)

func set_step_length(length: float) -> void:
	timer_step.wait_time = length
func f2f(frame_length, frame_base) -> float:
	return float(frame_length)/float(frame_base)
	
func _on_timer_step_timeout() -> void:
	copy_skeleton_pose()
func _on_blend_step_timeout() -> void:
	set_step_length(await_anim_step)
