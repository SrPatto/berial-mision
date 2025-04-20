extends State_Dragon

var isCharging

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	fly_pause_timer = $"../../FlyPause_Timer"
	
	fly_pause_timer.wait_time = 1
	isCharging = false
	player_lastPosition = player.global_position
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
			dragon.isFlying = false
			Transitioned.emit(self, "ChaseState"))
	pass
	
func Physics_Update(_delta: float):
	if !isCharging:
		# Smooth look_at
		var pos2D : Vector2 = Vector2(dragon.global_position.x, dragon.global_position.z)
		var targetPos2d : Vector2 = Vector2(player_lastPosition.x - 17, player_lastPosition.z)
		var direction = -(pos2D - targetPos2d)
		dragon.rotation.y = lerp_angle(dragon.rotation.y, atan2(direction.x, direction.y), _delta * 4)
	
