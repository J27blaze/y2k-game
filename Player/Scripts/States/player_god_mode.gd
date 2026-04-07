extends PlayerState

const speed: float = 20

func start():
	print("god_mode")
	player.target_speed = 0
	player.gravity = 0
	player.velocity.y = 0
	
	player.standing_collider.set_disabled(true)

func exit():
	player.gravity = player.fall_gravity
	player.standing_collider.set_disabled(false)

func process_physics(delta: float):
	var move_dir: Vector3
	move_dir += player.direction * speed
	player.target_speed = move_dir.length()
	player.vel_move_toward(move_dir, 999999, delta)
	player.velocity.y = Input.get_axis("slide", "jump") * speed

func process_input(event: InputEvent):
	if !player.god_mode:
		change_state("fall")
		return
