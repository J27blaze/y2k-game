extends Enemy

@onready var anim_controller : AnimationController = $animation_controller

func _ready():
	anim_controller.play_anim("idle")

func damage(damage: int) -> void:
	anim_controller.play_anim_blend("charge_attack")
	return
