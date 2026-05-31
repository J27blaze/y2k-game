class_name PlayerState
extends Node

var player: Player
var data = null
#var cur_speed = Player.cur_speed
	# Used for having a target speed, or reference speed of the player, the actualy CURRENT speed is player.speed
var input_handler: InputHandler

@onready var state_machine = get_parent()

# ready state
func init():
	pass

# enter state
func start():
	pass

# exit state
func exit():
	pass

func change_state(state: String, data = null):
	player.state_machine.change_state(state, data)
func previous_state():
	return player.state_machine.previous_state()
	
func play_anim_blend(animation_name: String, step_frame_length: int, blend_frames: int, blend_frame_length: int, fb: int = player.frame_step_length):
	player.play_anim_blend(animation_name, step_frame_length, blend_frames, blend_frame_length, fb)
func play_anim(animation_name: String, step_frame_length: int, fb: int = player.frame_step_length):
	player.play_anim(animation_name, step_frame_length, fb)

# process_input
func process_input(event: InputEvent):
	#write on input event code here
	return null

# process_frame
func process_frame(delta: float):
	#write visual code here
	return null

# process_physics
func process_physics(delta: float):
	#Write state changing code here
	#Write player velocity changing code here.
	return null

# process physics every frame regaurdless of state. Good for updating global player variables
func always_process_physics(delta: float):
	#write code that needs to change all the time, think wepaon dash
	return null
