class_name PlayerState
extends Node

var player: Player
#var cur_speed = Player.cur_speed
	# Used for having a target speed, or reference speed of the player, the actualy CURRENT speed is player.speed
var input_handler: InputHandler

@onready var state_machine = get_parent()

# enter state
func start():
	pass

# exit state
func exit():
	pass

func change_state(state: String):
	player.state_machine.change_state(state)

# process_input
func process_input(event: InputEvent):
	return null

# process_frame
func process_frame(delta: float):
	return null

# process_physics
func process_physics(delta: float):
	#Write state changing code here
	
	#Write player velocity changing code here.
	return null
