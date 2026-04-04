class_name PlayerStateMachine
extends Node

@export var states: Dictionary[String, PlayerState]
@onready var all_states: Array[Node]

var current_state: PlayerState
var prev_state: PlayerState

func init(player: Player):
	all_states = get_children()
	
	for child in all_states:
		child.player = player
		child.input_handler = player.input_handler
	
	prev_state = states["idle"]
	change_state("idle")

func change_state(new_state: String):
	if current_state:
		current_state.exit()
		prev_state = current_state
	#else:
	#	push_error(new_state + " does not exist.")
	current_state = states[new_state]
	current_state.start()

func process_input(event: InputEvent):
	current_state.process_input(event)

func process_frame(delta: float):
	current_state.process_frame(delta)
	
func process_physics(delta: float):
	current_state.process_physics(delta)

func always_physics_update(delta: float):
	for child in all_states:
		child.always_process_physics(delta)
