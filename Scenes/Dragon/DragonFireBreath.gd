extends State_Dragon

@onready var fire_particles: GPUParticles3D = $"../../FireParticles"

var direction
var isAttacking 

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	
	isAttacking = true
	fire_particles.emitting = true
	player_lastPosition = player.global_position
	direction = get_direction()
	
	if dragon.isFlying:
		fire_particles.rotation.x = 0.0
	else:
		fire_particles.rotation.x = 75.0 
	
func Exit():
	pass
	
func Update(_delta: float):
	dragon.look_at_from_position(dragon.global_position, Vector3(player_lastPosition.x, dragon.global_position.y, player_lastPosition.z), Vector3.UP, true)
	
	if dragon.isFlying && !isAttacking :
		Transitioned.emit(self, "ChargeState")
	pass
	
func Physics_Update(_delta: float):
	if dragon.isFlying:
		if target_reached():
			isAttacking = false
			fire_particles.emitting = false
			dragon.velocity = Vector3.ZERO
		else:
			dragon.velocity = direction * fly_speed * _delta
		
	else:
		# floor
		pass
	pass

func get_direction():
	var direction_x = player_lastPosition.x - dragon.global_position.x
	var direction_z = player_lastPosition.z - dragon.global_position.z
	return Vector3(direction_x, 0, direction_z)

func target_reached():
	return dragon.global_position.distance_to(player_lastPosition) <= 20
