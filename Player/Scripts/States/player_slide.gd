extends PlayerState

var initial_dir: Vector3
var move_dir: Vector3

func start():
	print("slide")
	
	initial_dir = player.hor_velocity.normalized()
	player.target_speed = player.speed
	move_dir = initial_dir * player.target_speed

func process_physics(delta: float):
		
	if input_handler.is_action_buffered("jump") && player.can_jump:
		change_state("jump")
		return
	if Input.is_action_just_released("slide"):
		change_state("run")
		return
		
	player.vel_move_toward(move_dir, 999999, delta)
	
	if !player.is_on_floor():
		change_state("fall")
		return
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
