extends Node

@onready var l = $Bottom_Right/LeftStick
@onready var r = $Bottom_Right/RightStick

@onready var pspeed = $Bottom_Right/PlayerSpeed
@onready var pstate = $Bottom_Right/PkayerState
@onready var prevstate = $Bottom_Right/PkayerPrevState
@onready var othertext = $Bottom_Right/OtherText

@onready var player: Player = self.get_parent()

var l_dot
var l_dot_raw
var r_dot
var l_text
var r_text

var mouse_dir: Vector2
var lerp_mouse_dir: Vector2

var input = InputHandler.new()

func _ready():
	l_text = $Bottom_Right/LeftStick/Label
	l_dot = $Bottom_Right/LeftStick/dot
	l_dot_raw = $Bottom_Right/LeftStick/dot_raw
	
	r_text = r.get_child(0)	
	r_dot = r.get_child(1)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_dir = input.get_raw_mouse_camera_dir(event)

func _process(delta: float):
	
	var raw_input_dir = input.get_raw_input_dir()
	var input_dir = input.get_input_dir()
	var camera_dir = input.get_raw_controller_camera_dir()
	
	lerp_mouse_dir = lerp(lerp_mouse_dir, mouse_dir, 1)
	
	#150 is size of box
	l_dot_raw.position = raw_input_dir * 150/2 + (Vector2.ONE * 150/2 + Vector2.ONE * -3)
	l_dot.position = input_dir * 150/2 + (Vector2.ONE * 150/2 + Vector2.ONE * -3)
	l_text.text = "(" + str(input_dir.x).pad_decimals(2) + "," + str(input_dir.y).pad_decimals(2) + ")"
	
	r_dot.position = camera_dir* 150/2 + lerp_mouse_dir + (Vector2.ONE * 150/2 + Vector2.ONE * -3)
	r_text.text = "(" + str(camera_dir.x).pad_decimals(2) + "," + str(camera_dir.y).pad_decimals(2) + ")"
	
	
	#player stats
	pspeed.text = "speed: " + str(player.speed).pad_decimals(2) + "\n target speed:" + str(player.target_speed).pad_decimals(2)
	pstate.text = "State: " + str(player.state_machine.current_state.name)
	prevstate.text = "Previous State: " + str(player.state_machine.prev_state.name)
	
	#prevstate.text = str(player.state_machine.slide_state.refresh.time_left)
	
	#other
	othertext.text = "FPS: " + str(Engine.get_frames_per_second())
	othertext.text += "\non_wall: " + str(player.on_wall)
	
	#anim
	othertext.text += "\nT: " + str(player.animation_controller.t)
	othertext.text += "\nBLEND T: " + str(player.animation_controller.blend_t)
	
	mouse_dir = Vector2.ZERO
