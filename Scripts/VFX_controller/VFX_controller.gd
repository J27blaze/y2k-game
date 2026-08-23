extends Node
class_name VFXController

@export var particles : Dictionary[String, PackedScene]

func spawn_particle(particle_name: String, top_level: bool, position: Vector3, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE):
	if particles[particle_name]:
		var instance := particles[particle_name].instantiate()
		instance.position = position
		instance.rotation = rotation
		instance.scale = scale
		instance.top_level = top_level
		
		add_child(instance)
		
		instance.emit()
		
		#print(instance.rotation)

func clear_all_particles():
	for child in get_children():
		child.queue_free()
