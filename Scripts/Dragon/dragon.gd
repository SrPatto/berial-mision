extends CharacterBody3D

class_name Dragon

@export
var LIFE: int = 1000

var isFlying = false
var isSleeping = true

func _physics_process(delta: float) -> void:
	if !isFlying:
		if not is_on_floor():
			velocity += get_gravity() * delta
	move_and_slide()

func receive_attack(damage: float) -> void:
	LIFE -= damage
	print("dragon life: ", LIFE)
	
