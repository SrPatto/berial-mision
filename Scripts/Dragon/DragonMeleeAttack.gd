extends State_Dragon

@onready var melee_attack_hitbox: Area3D = $"../../MeleeAttack_Hitbox"

var cd_attack_time = 2 # TEMPORAL
var isAttacking 

func Enter():
	print("SAPE")
	get_variables()
	
	dragon.velocity = Vector3.ZERO
	isAttacking = true
	dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["ATTACK"])
	if isAttacking:
		attack()
	cd_attack_time = 2 # TEMPORAL
	pass
	
func Exit():
	pass
	
func Update(_delta: float):
	# Smooth look_at
	var pos2D : Vector2 = Vector2(dragon.global_position.x, dragon.global_position.z)
	var targetPos2d : Vector2 = Vector2(player.global_position.x, player.global_position.z)
	var direction = -(pos2D - targetPos2d)
	dragon.rotation.y = lerp_angle(dragon.rotation.y, atan2(direction.x, direction.y), _delta * 4)
	
	cd_attack_time -= _delta
	
	if cd_attack_time <= 0 && !isAttacking:
		Transitioned.emit(self,"ChaseState")
	
func Physics_Update(_delta: float):
	
	pass
	
func attack():
	if melee_attack_hitbox.overlaps_body(player):
		player.health -= MELEE_DAMAGE
		print("melee hit! player life: ", player.health)
	isAttacking = false
