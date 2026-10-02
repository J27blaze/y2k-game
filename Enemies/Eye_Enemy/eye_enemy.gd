extends Enemy

@onready var anim_controller : AnimationController = $animation_controller

func _ready():
	anim_controller.play_anim("idle")

func damage(damage: int) -> void:
	return

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_forward"):
		anim_controller.play_anim_blend("charge_attack")
	if Input.is_action_just_pressed("move_back"):
		anim_controller.play_anim_blend("idle")
