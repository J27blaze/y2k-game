extends Node
class_name PlayerUI

@export var player: Node

var cur_speed: float = 0
var cur_lerp_speed: float = 0
var last_speed: float = 0

const speed_ui_text_size: int = 30
const speed_ui_scale_multiplier: float = 0.25
const speed_ui_scale_diff_multiplier: float = 40
const speed_ui_scale_lerp: float = 5
const cur_lerp_speed_amount: float = 20

var speed_ui_size: float = 1
var speed_ui_target_size: float = speed_ui_text_size
@onready var speed_ui : Label = $speed_display/num

func _process(delta: float) -> void:
	speed_ui_target_size = lerpf(speed_ui_target_size, speed_ui_size, speed_ui_scale_lerp * delta)
	#print(cur_lerp_speed)
	speed_ui.add_theme_font_size_override("font_size", speed_ui_target_size)
	
	speed_ui.text = str(roundf(cur_speed)).pad_decimals(0)
	
func _physics_process(delta: float) -> void:
	cur_lerp_speed = lerpf(cur_lerp_speed, cur_speed, cur_lerp_speed_amount*delta)
	var diff = cur_speed-last_speed

	speed_ui_size = speed_ui_text_size + clampf(cur_speed*speed_ui_scale_multiplier + log(clampf(1 + diff*0.5, 1, 999999))*speed_ui_scale_diff_multiplier, 0, 999999)
	
	#print(clampf(1 + diff*0.5, 1, 999999))
