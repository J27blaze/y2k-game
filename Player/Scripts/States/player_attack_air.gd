extends PlayerState

var accel: float = 0.0

@onready var anim_timer := $anim_timeout 
@onready var input_timer := $input_timeout
@onready var combo_timer := $combo_timer #started after attack

func start():
	print("attack_air")
	
	var cur_anim := player.attack_anim_speeds[player.attack_stage]
	var cur_input := player.attack_input_speeds[player.attack_stage]
	
	player.is_attacking = true
	
	anim_timer.wait_time = cur_anim
	input_timer.wait_time = cur_input
	
	player.gravity = player.fall_gravity
	accel = player.fall_accel
	#print(previous_state())
	
	#calc state before playing anim
	play_anim_blend("air_attack_1")

func exit():
	player.is_attacking = false
	player.append_attack_state.exit_attack()

func process_physics(delta: float) -> void:
	
	player.calc_wall_slide()
	if player.state_wall_slide_check():
		return
	if player.state_landing_check():
		return
	
	player.hit_check()
	if player.state_tumble_check():
		return
	
	if !data:
		if player.state_dodge_check():
			return
	
	var move_dir = player.target_speed * player.direction
	player.vel_move_toward(move_dir, accel, delta)
	#player.vel_accel_speed(player.run_speed, player.run_max_speed, player.jump_speed_accel, player.jump_speed_accel, delta)
	
	player.lerp_target_speed(player.air_target_speed_margin, player.air_target_speed_accel, delta)
	
	#debug
	DebugDraw3D.draw_line(player.centre, player.centre + player.direction * player.target_speed * 0.5, Color.YELLOW)
	DebugDraw3D.draw_line(player.centre, player.centre + player.hor_velocity *0.5, Color.PURPLE)
	
	return
	
func process_input(event: InputEvent):
	return
