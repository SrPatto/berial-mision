extends State_Dragon

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	navigation_agent_3d = $"../../NavigationAgent3D"
	cd_fire_breath = $"../../CD_FireBreath"
	
	dragon.isFlying = false
	pass
	
func Exit():
	pass

func Update(_delta: float):
	Make_Path(player.global_position, _delta)
	if player_distant() < MELEE_RANGE:
		print("SAPE")
	elif player_distant() > MELEE_RANGE && player_distant() < MAX_DISTANCE && cd_fire_breath.is_stopped():
		Transitioned.emit(self, "FireBreathState")
	elif player_distant() > MAX_DISTANCE:
		Transitioned.emit(self, "FlyState")

func Physics_Update(_delta: float):
	pass

func player_distant(): 
	return dragon.global_position.distance_to(player.global_position)

func Make_Path(target_position: Vector3, _delta):
	navigation_agent_3d.set_target_position(target_position)
	var current_agent_position = dragon.global_position
	var next_path_position = navigation_agent_3d.get_next_path_position() 
	var direction = (next_path_position - current_agent_position).normalized()
	dragon.velocity = direction * move_speed
	
	# Smooth look_at
	var current_rotation = dragon.rotation.y
	var target_rotation = atan2(direction.x, direction.z)
	dragon.rotation.y = lerp_angle(current_rotation, target_rotation, 0.1)
	
	if navigation_agent_3d.avoidance_enabled:
		dragon.set_velocity(direction * move_speed)
	else:
		_on_navigation_agent_3d_velocity_computed(direction)

func _on_navigation_agent_3d_velocity_computed(safe_position: Vector3):
	dragon.velocity = safe_position * move_speed
