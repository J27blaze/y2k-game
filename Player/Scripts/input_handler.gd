class_name InputHandler
var camera_controller_sensitivity = 0.04
var camera_mouse_sensitivity = 0.001

var buffered_inputs: Dictionary[String, int]

func process_physics(delta: float):
	#print(buffered_inputs)
	
	if !buffered_inputs.is_empty():
		for input in buffered_inputs:
			
			if buffered_inputs[input] > 0:
				buffered_inputs[input] -= 1
	
func process_input(event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#idk how else to program this to be scalable for menus and different buffer windows
	#but for now the buffered inputs are hard coded EW
	
	if Input.is_action_just_pressed("jump"):
		buffered_inputs["jump"] = 7
	
	if Input.is_action_just_pressed("dodge"):
		buffered_inputs["dodge"] = 7
		
	if Input.is_action_just_pressed("slide"):
		# perfect slide
		buffered_inputs["slide"] = 4
		
	if Input.is_action_just_pressed("weapon_dash"):
		# perfect slide
		buffered_inputs["weapon_dash"] = 10
		
	#if Input.is_action_just_pressed("kick"):
	#	buffered_inputs["kick"] = buffer_length

#function can only work in process_phyisics, and not process_input
func is_action_buffered(input: String):
	if buffered_inputs.has(input):
		if buffered_inputs[input] > 0:
			#buffered_inputs[input] = 0
			return true
		else:
			return false
	else:
		return false

func clear_action_buffer(input: String):
	buffered_inputs[input] = 0

# camera
func get_raw_controller_camera_dir():
	return Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")

func get_controller_camera_dir():
	return Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") * camera_controller_sensitivity

func get_raw_mouse_camera_dir(event: InputEventMouseMotion):
	return event.relative
	
func get_mouse_camera_dir(event: InputEventMouseMotion):
	return event.relative * camera_mouse_sensitivity
	
#running and stuff
func get_input_dir():
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input.length() > 0.8:
		if Vector2.UP.dot(input.normalized()) > 0.995:
			return Vector2.UP
		else:
			return input.normalized()
	else:
		return input
		
func get_raw_input_dir():
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")
