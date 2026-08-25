extends Node3D

var emitting: bool = false

func emit():
	for child in get_children():
		child.emitting = true

func stop_emit():
	for child in get_children():
		child.emitting = false
