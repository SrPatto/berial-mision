extends CharacterBody3D

@export
var LIFE: int = 1000

var isFlying = false
var isSleeping = true

func _physics_process(delta: float) -> void:
	if !isFlying:
		if not is_on_floor():
			velocity += get_gravity() * delta
	move_and_slide()
