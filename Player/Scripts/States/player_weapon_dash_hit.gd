extends PlayerState

@onready var dodge_length := $dodge_length

var initial_vel: Vector3 = Vector3.ZERO
var initial_dir: Vector3 = Vector3.ZERO
var move_dir: Vector3 = Vector3.ZERO

func start():
	print("weapon_dash_hit")
	play_anim("dodge_old")
	
	player.can_jump = false
	
	player.gravity = player.weapon_dash_hit_gravity
	initial_vel = data
	initial_dir = initial_vel.normalized()
	
	player.velocity.y = clampf(player.velocity.y, player.weapon_dash_hit_vel_pulse, 999999)
	
	print(data)
	
func exit():
	player.gravity = player.fall_gravity
	return

func process_physics(delta: float):
	if player.state_landing_check():
		return
	if player.velocity.y < 0:
		change_state("fall", false)
		return
	if player.state_dodge_check():
		return
	
	player.calc_wall_slide()
	
	move_dir = player.direction * player.target_speed
	
	player.vel_move_toward(move_dir, player.weapon_dash_hit_speed_aceel, delta)
	return
