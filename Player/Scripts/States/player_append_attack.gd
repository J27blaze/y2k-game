class_name AppendAttackState
extends PlayerState

var parent_state: PlayerState
var state: String = ""
@onready var timer := $timeout

func attack(appended_state: String):
	var anim_con := player.animation_controller
	
	state = appended_state
	player.is_attacking = true
	#player.play_anim("air_attack_1", 2)
	#timer.start()
	match state:
		"run", "idle":
			anim_con.animation_tree.set(str("parameters/" + state + "/attack_oneshot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			timer.start()
			
			anim_con.start_blend_t(0.52, anim_con.f2f(anim_con.animations_frames[state].duringF))
			anim_con.start_t(anim_con.f2f(1.5))
			anim_con.skeleton_animplayer.advance(0)
			anim_con.copy_skeleton_pose()
		_:
			print("parent state start assigned not valid")

func exit_attack():
	if player.is_attacking:
		# all end attackig code here
		match state:
			"run", "idle":
				pass
				#player.animation_controller.animation_tree.set("parameters/run/blend/blend_amount", 0.0)
			_:
				print("parent state end assigned not valid")
	player.is_attacking = false
	timer.stop()

func _on_timeout_timeout() -> void:
	exit_attack()
