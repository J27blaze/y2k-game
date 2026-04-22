class_name Enemy
extends CharacterBody3D

#IMPORTANT NOT TO CHANGE THE NODE TREE DIRECTORY
@onready var visibility_notif: Node = $VisibleOnScreenEnabler3D

var health: float = 10

func is_on_screen() -> bool:
	return visibility_notif.is_on_screen()
