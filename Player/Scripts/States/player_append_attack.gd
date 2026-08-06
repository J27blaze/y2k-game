class_name AppendAttackState
extends PlayerState

var parent_state: PlayerState
var state: String = ""
@onready var anim_timer := $anim_timeout 
@onready var input_timer := $input_timeout
@onready var combo_timer := $combo_timer #started after attack

var max_combo: int = 1 #, 0, 1
var previous_anim: String = ""

func _ready() -> void:
	combo_timer.wait_time = 0.25

func attack(appended_state: String):
	var anim_con := player.animation_controller
	var cur_anim := player.attack_anim_speeds[player.attack_stage]
	var cur_input := player.attack_input_speeds[player.attack_stage]
	
	state = appended_state
	player.is_attacking = true
	
	anim_timer.wait_time = cur_anim
	input_timer.wait_time = cur_input
	
	combo_timer.stop()
	anim_timer.start()
	input_timer.start()
	#player.play_anim("air_attack_1", 2)
	#timer.start()
	match state:
		"run", "idle":
			var anim: String = str("parameters/" +state+"/attack_" + str(player.attack_stage +1)+ "_oneshot/request")			
			anim_con.animation_tree.set(previous_anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			
			previous_anim = anim
			
			anim_con.animation_tree.set(anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			#anim_con.animation_tree.set(str("parameters/run/attack_" + str(player.attack_stage +1)+ "_oneshot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			
			anim_con.start_blend_t(cur_anim + 0.2, anim_con.f2f(anim_con.animations_frames[state].duringF))
			anim_con.start_t(anim_con.f2f(1.5))
			anim_con.skeleton_animplayer.advance(0)
			anim_con.copy_skeleton_pose()
		_:
			print("parent state start assigned not valid")
	
	if player.attack_stage >= max_combo:
		player.attack_stage = 0
		return
	player.attack_stage += 1

func exit_attack():
	if player.is_attacking:
		# all end attackig code here
		match state:
			"run", "idle":
				pass
				#player.animation_controller.animation_tree.set("parameters/run/blend/blend_amount", 0.0)
			_:
				print("parent state end assigned not valid")
	input_timer.stop()
	anim_timer.stop()

func _on_timeout_timeout() -> void:
	exit_attack()
func _on_input_timeout_timeout() -> void:
	player.is_attacking = false
	combo_timer.start()
func _on_combo_timer_timeout() -> void:
	player.attack_stage = 0
