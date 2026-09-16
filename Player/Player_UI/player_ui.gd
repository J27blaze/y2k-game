extends Node
class_name PlayerUI

@export var player: Node

##ADD A UPDATE UI FUNTION,

#player
var cur_speed: float = 0
var cur_lerp_speed: float = 0
var last_speed: float = 0

#xamera
@onready var camera_wobble: Control = $camera_wobble
var camera_dir: Vector2
var mouse_dir: Vector2
var target_ui_offset_pos: Vector2 = Vector2.ZERO
const target_ui_offset_lerp: float = 20
const  target_ui_offset_scaler: float = 180.

const cur_speed_scaler: float = 1.25

#speed
const speed_ui_text_size: int = 30
const speed_ui_scale_multiplier: float = 0.25
const speed_ui_scale_diff_multiplier: float = 40
const speed_ui_scale_lerp: float = 5
const cur_lerp_speed_amount: float = 20

var speed_ui_size: float = 1
var speed_ui_target_size: float = speed_ui_text_size
@onready var speed_ui : Label = $camera_wobble/speed_display/num

#timer
var time_elapsed : float = 0.0
@onready var timer: Label = $camera_wobble/timer_display/timer

func _process(delta: float) -> void:
	speed_ui_target_size = lerpf(speed_ui_target_size, speed_ui_size, speed_ui_scale_lerp * delta)
	#print(cur_lerp_speed)
	speed_ui.add_theme_font_size_override("font_size", speed_ui_target_size)
	
	speed_ui.text = str(roundf(cur_speed * cur_speed_scaler)).pad_decimals(0)
	
	var ui_offset : Vector2 = camera_dir - mouse_dir
	target_ui_offset_pos = lerp(target_ui_offset_pos, ui_offset, target_ui_offset_lerp * delta)
	
	camera_wobble.position = -round((target_ui_offset_pos*target_ui_offset_scaler)/3)*3
	
	#timer
	time_elapsed += delta
	var minutes: int = int(time_elapsed / 60)
	var seconds: int = int(fmod(time_elapsed, 60))
	var milliseconds: int = int(fmod(time_elapsed, 1.0) * 100) # Use 1000 f
	
	#timer.text = "%02d:%02d" % [seconds, milliseconds]
	timer.text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	
func _physics_process(delta: float) -> void:
	cur_lerp_speed = lerpf(cur_lerp_speed, cur_speed, cur_lerp_speed_amount*delta)
	var diff = cur_speed-last_speed

	speed_ui_size = speed_ui_text_size + clampf(cur_speed*speed_ui_scale_multiplier + log(clampf(1 + diff*0.5, 1, 999999))*speed_ui_scale_diff_multiplier, 0, 999999)
	
	#print(clampf(1 + diff*0.5, 1, 999999))
