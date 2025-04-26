extends State_Dragon

func Enter():
	get_variables()
	
	dragon.isFlying = false
	dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["FOOTSTEPS"])
	animation_player.play("Dragon/Walk")
	pass
	
func Exit():
	pass

func Update(_delta: float):
	Make_Path(player.global_position, _delta)
	if player_distant() < MELEE_RANGE:
		Transitioned.emit(self, "MeleeAttackState")
	elif player_distant() >= FIRE_BREATH_RANGE && player_distant() < MAX_DISTANCE && cd_fire_breath.is_stopped():
		Transitioned.emit(self, "FireBreathState")
	elif player_distant() > MAX_DISTANCE:
		Transitioned.emit(self, "FlyState")
	
	if dragon.LIFE <= 0:
		Transitioned.emit(self, "DeathState")

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
