extends State_Dragon

@onready var fire_particles: GPUParticles3D = $"../../FireParticles"
@onready var fire_breath_timer = $"../../FireBreath_Timer"
@onready var fire_breath_hitbox = $"../../FireParticles/FireBreath_Hitbox"
@onready var fire_damage_timer = $"../../FireDamage_Timer"

var direction
var isAttacking 

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	cd_fire_breath = $"../../CD_FireBreath"
	fly_pause_timer = $"../../FlyPause_Timer"
	fire_ray_cast = $"../../Fire_RayCast"
	
	isAttacking = true
	fire_particles.emitting = true
	fire_damage_timer.start()
	
	if dragon.isFlying:
		player_lastPosition = player.global_position
		direction = get_direction()
		dragon.look_at_from_position(dragon.global_position, Vector3(player_lastPosition.x, dragon.global_position.y, player_lastPosition.z), Vector3.UP, true)
		fire_particles.position.y = 9.8
		fire_particles.rotation.x = 0.0
		fly_pause_timer.start()
	else:
		fire_breath_timer.start()
		fire_particles.position.y = 3
		fire_particles.rotation.x = 55.01 
	
func Exit():
	pass
	
func Update(_delta: float):
	
	if dragon.isFlying && !isAttacking :
		Transitioned.emit(self, "ChargeState")
	pass
	
func Physics_Update(_delta: float):
	if dragon.isFlying:
		if fly_pause_timer.is_stopped():
			stop_fireBreath()
			dragon.velocity = Vector3.ZERO
		else:
			dragon.velocity = direction * fly_speed * _delta
	else:
		dragon.velocity = Vector3.ZERO
		# Smooth look_at
		var pos2D : Vector2 = Vector2(dragon.global_position.x, dragon.global_position.z)
		var targetPos2d : Vector2 = Vector2(player.global_position.x, player.global_position.z)
		direction = -(pos2D - targetPos2d)
		dragon.rotation.y = lerp_angle(dragon.rotation.y, atan2(direction.x, direction.y), _delta * 2)
		# raycast
		fire_ray_cast.target_position = fire_ray_cast.to_local(player.global_position)
		
		
	

func get_direction():
	var direction_x = player_lastPosition.x - dragon.global_position.x
	var direction_z = player_lastPosition.z - dragon.global_position.z
	return Vector3(direction_x, 0, direction_z)

func target_reached():
	return dragon.global_position.distance_to(player_lastPosition) <= 20

func stop_fireBreath():
	isAttacking = false
	fire_particles.emitting = false
	fire_damage_timer.stop()

func _on_fire_breath_timer_timeout():
	stop_fireBreath()
	cd_fire_breath.start()
	Transitioned.emit(self, "ChaseState")

# Damage per second
func _on_fire_damage_timer_timeout():
	if dragon.isFlying:
		if fire_breath_hitbox.overlaps_body(player):
			player.health -= FIRE_DAMAGE
		print(player.health)
	else:
		if fire_breath_hitbox.overlaps_body(player) && fire_ray_cast.get_collider() == player:
			player.health -= FIRE_DAMAGE
			print(player.health)
