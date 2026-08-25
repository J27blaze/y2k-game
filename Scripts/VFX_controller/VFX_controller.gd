extends Node
class_name VFXController

@export var particles : Dictionary[String, PackedScene]

var loop_particle_store : Dictionary[String, Node]

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
	else:
		return

func spawn_looping_particle(particle_name: String, top_level: bool, position: Vector3, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE):
	if particles[particle_name]:
		var loop_instance := particles[particle_name].instantiate()
		loop_instance.position = position
		loop_instance.rotation = rotation
		loop_instance.scale = scale
		loop_instance.top_level = top_level
		
		add_child(loop_instance)
		
		loop_particle_store[particle_name] = loop_instance
		
		loop_instance.emit()
	else:
		return

func stop_looping_particle(particle_name: String):
	var instance = loop_particle_store[particle_name]
	if instance:
		instance.stop_emit()
	else:
		return

func clear_all_particles():
	for child in get_children():
		child.queue_free()
	loop_particle_store.clear()
