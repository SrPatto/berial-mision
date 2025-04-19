extends CharacterBody3D

var isFlying = false

func _physics_process(delta: float) -> void:
	if !isFlying:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	
	move_and_slide()
