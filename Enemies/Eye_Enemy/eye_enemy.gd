extends Enemy

@onready var anim_controller : AnimationController = $animation_controller

func _ready():
	anim_controller.play_anim_blend("idle")
