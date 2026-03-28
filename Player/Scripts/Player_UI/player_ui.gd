extends Control

@export var player: Node
@onready var style_meter := $style_meter

func _process(delta: float) -> void:
	style_meter.get_child(0).text = str(player.style)
