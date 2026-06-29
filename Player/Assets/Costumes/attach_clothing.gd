class_name AttachClothing
extends Resource

#list of every body part thats hidden when wearing this clothing
@export var display_name: String = "Test Display Name"
@export var scene: PackedScene
@export var connected_bone: String
@export var offset: Vector3 = Vector3.ZERO
