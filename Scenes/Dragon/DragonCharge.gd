extends State_Dragon

var isCharging

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	fly_pause_timer = $"../../FlyPause_Timer"
	
	fly_pause_timer.wait_time = 1
	isCharging = false
	player_lastPosition = player.global_position
	dragon.look_at_from_position(dragon.global_position, Vector3(player_lastPosition.x, dragon.global_position.y, player_lastPosition.z), Vector3.UP, true)
	player_lastPosition += Vector3(17, 0, 0)
	fly_pause_timer.start()
	print("COBARDEEEEEEEEEEEES!!")
	
func Exit():
	pass
	
func Update(_delta: float):
	
	if fly_pause_timer.is_stopped() && !isCharging:
		isCharging = true
		var charge_tween = get_tree().create_tween()
		charge_tween.tween_property(dragon, "position", player_lastPosition, .5)
		charge_tween.tween_callback(func (): 
			fly_pause_timer.wait_time = 3
			Transitioned.emit(self, "ChaseState"))
	pass
	
func Physics_Update(_delta: float):
	pass
