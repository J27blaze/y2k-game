class_name Enemy
extends CharacterBody3D

#IMPORTANT NOT TO CHANGE THE NODE TREE DIRECTORY
@onready var visibility_notif: Node = $VisibleOnScreenEnabler3D

var health: float = 10
var is_players_target: bool = false

func is_on_screen() -> bool:
	return visibility_notif.is_on_screen()

func set_player_target(input: bool):
	is_players_target = input

func is_player_target() -> bool:
	return is_players_target
