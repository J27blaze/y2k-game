extends Node
class_name AnimationController

@export var parent: Node
@export var delete_skeleton: bool = true

@onready var skeleton_animplayer : AnimationPlayer = parent.find_child("AnimationPlayer", false)
@onready var skeleton : Skeleton3D = parent.find_child("Skeleton3D", true)
@onready var mesh_skeleton : Skeleton3D = skeleton.duplicate()

var bone_count: int = 0

@onready var timer_step := $timer_step

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
			
func play_anim_blend(anim_name: String, step_frame_length: int, blend_frames: int, fb: int = 24) -> void:
	skeleton_animplayer.play(anim_name, f2f(blend_frames, fb))
	set_step_length(f2f(step_frame_length, fb))

	timer_step.start()
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()

func play_anim(anim_name: String, step_frame_length: int, fb: int = 24) -> void:
	skeleton_animplayer.play(anim_name, 0.0)
	set_step_length(f2f(step_frame_length, fb))
	
	timer_step.start()
	skeleton_animplayer.advance(0)
	copy_skeleton_pose()
	
func set_step_length(length: float) -> void:
	timer_step.wait_time = length
func f2f(frame_length, frame_base) -> float:
	return float(frame_length)/float(frame_base)
	
func _on_timer_step_timeout() -> void:
	copy_skeleton_pose()
