class_name AppendAttackState
extends PlayerState

var parent_state: PlayerState
@onready var timer := $timeout

func attack(state: String):
	player.is_attacking = true
	player.play_anim("air_attack_1", 2)
	timer.start()

func exit_attack():
	if player.is_attacking:
		player.play_anim_blend(player.animation_controller.previous_anim, 2, 4, 2)
	player.is_attacking = false
	timer.stop()

func _on_timeout_timeout() -> void:
	exit_attack()
