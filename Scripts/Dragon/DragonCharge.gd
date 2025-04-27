extends State_Dragon

@onready var impact_zone_hitbox: Area3D = $"../../ImpactZone_Hitbox"
var isCharging
var timerFlag = false
var timer = 1.5

func Enter():
	get_variables()
	
	fly_pause_timer.wait_time = 1
	isCharging = false
	timerFlag = false
	player_lastPosition = player.global_position
	player_lastPosition += Vector3(0, -0.8, 0)
	fly_pause_timer.start()
	dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["WINGS"])
	animation_player.play("Dragon/Fly")
	
func Exit():
	pass
	
func Update(_delta: float):
	if fly_pause_timer.is_stopped() && !isCharging:
		isCharging = true
		dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["QUICK-ROAR"])
		var charge_tween = get_tree().create_tween()
		charge_tween.tween_property(dragon, "position", player_lastPosition, .5)
		charge_tween.tween_callback(func (): 
			$"../../HIT VFX/AnimationPlayer".play()
			dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["QUICK-ROAR"])
			if impact_zone_hitbox.overlaps_body(player):
				player.receive_attack(CHARGE_DAMAGE)
				print("IMPACT! player: ", player.health)
			fly_pause_timer.wait_time = 3
			dragon.isFlying = false
			dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["GROUND-IMPACT"]))
		charge_tween.tween_callback(func (): timerFlag = true )
			
	if timerFlag:
		timer -= _delta
		if timer <= 0:
			timer = 1.5
			Transitioned.emit(self, "ChaseState")
	
	if dragon.LIFE <= 0:
		Transitioned.emit(self, "DeathState")

func Physics_Update(_delta: float):
	if !isCharging:
		# Smooth look_at
		var pos2D : Vector2 = Vector2(dragon.global_position.x, dragon.global_position.z)
		var targetPos2d : Vector2 = Vector2(player_lastPosition.x - 17, player_lastPosition.z)
		var direction = -(pos2D - targetPos2d)
		dragon.rotation.y = lerp_angle(dragon.rotation.y, atan2(direction.x, direction.y), _delta * 4)
	
