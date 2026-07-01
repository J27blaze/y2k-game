class_name DeformClothing
extends Resource

#list of every body part thats hidden when wearing this clothing
@export var display_name: String = "Test Display Name"
@export var scene: PackedScene

@export_group("Hidden Body Parts")
@export var body: bool = false
@export var body_lower: bool = false
@export var calvicles: bool = false
@export var feet: bool = false
@export var hands: bool = false
@export var head: bool = false
@export var lower_arm_l: bool = false
@export var lower_arm_r: bool = false
@export var upper_arm_l: bool = false
@export var upper_arm_r: bool = false
@export var neck: bool = false
@export var shin_l: bool = false
@export var shin_r: bool = false
@export var thigh_l: bool = false
@export var thigh_r: bool = false
