extends State_Dragon

@onready var fire_particles: GPUParticles3D = $"../../FireParticles"
@onready var fire_breath_timer = $"../../FireBreath_Timer"
@onready var fire_breath_hitbox = $"../../FireParticles/FireBreath_Hitbox"
@onready var fire_damage_timer = $"../../FireDamage_Timer"

var direction
var isAttacking 
var currentSFX

func Enter():
	get_variables()
	
	isAttacking = true
	fire_particles.emitting = true
	fire_damage_timer.start()
	
	if dragon.isFlying:
		dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["WINGS"])
		animation_player.play("Dragon/Fly")
		player_lastPosition = player.global_position
		direction = get_direction()
		dragon.look_at_from_position(dragon.global_position, Vector3(player_lastPosition.x, dragon.global_position.y, player_lastPosition.z), Vector3.UP, true)
		fire_particles.position.y = 9.8
		fire_particles.rotation.x = 0.0
		fly_pause_timer.start()
		currentSFX = dragon_sfx.get_currentClip()
	else:
		dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["FIREBREATH"])
		# todo: animation firebreath
		fire_breath_timer.start()
		fire_particles.position.y = 3
		fire_particles.rotation.x = 55.01 
	
func Exit():
	pass
	
func Update(_delta: float):
	
	if dragon.isFlying && !isAttacking :
		Transitioned.emit(self, "ChargeState")
	
	if dragon.LIFE <= 0:
		Transitioned.emit(self, "DeathState")
	
func Physics_Update(_delta: float):
	if dragon.isFlying:
		if fly_pause_timer.is_stopped():
			stop_fireBreath()
			dragon.velocity = Vector3.ZERO
		else:
			if currentSFX != dragon_sfx.SFX_DICTIONARY["FIREBREATH"]:
				dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["FIREBREATH"])
				currentSFX = dragon_sfx.SFX_DICTIONARY["FIREBREATH"]
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
			player.receive_attack(FIRE_DAMAGE)
			#player.health -= FIRE_DAMAGE
		print(player.health)
	else:
		if fire_breath_hitbox.overlaps_body(player) && fire_ray_cast.get_collider() == player:
			player.receive_attack(FIRE_DAMAGE)
			print(player.health)
