class_name Enemy
extends CharacterBody3D

#IMPORTANT NOT TO CHANGE THE NODE TREE DIRECTORY
@export var visibility_notif: Node

@export_range(0, 10, 1) var start_health: float = 10
var health: float = 10

@export_range(0, 20, 0.05) var gravity: float = 10.
const fall_terminal_vel: float = 35.0

var is_players_target: bool = false

func is_on_screen() -> bool:
	return visibility_notif.is_on_screen()

func set_player_target(input: bool):
	is_players_target = input

func is_player_target() -> bool:
	return is_players_target

func _ready() -> void:
	health = start_health

func _physics_process(delta: float) -> void:
	if is_players_target:
		DebugDraw3D.draw_square(position, 1, Color.BLUE)
	
	if !is_on_floor():
		velocity.y = clampf(velocity.y - gravity * delta, -fall_terminal_vel, 999999)
	
	move_and_slide()
