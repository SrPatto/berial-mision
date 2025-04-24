extends BaseEnemy

@onready var player: CharacterBody3D = $"../Player" #Se obtiene variable player del arbol de nodos
var isAttacking: bool

func _process(delta: float) -> void:
	if hp <= 0:
		die()

func _physics_process(delta: float) -> void:
	if player != null && !isAttacking:
		movement(delta)
		return

func die() -> void:
	queue_free()

func attack(body) -> void:
	isAttacking = true
	body.receive_attack(damage)

func movement(delta: float) -> void:
	
	var directionTo = player.global_position - global_position #¿Hacia qué se mueve? Al player
	var direction = (transform.basis * Vector3(directionTo.x, 0, directionTo.z)).normalized() #Aplica vector de movimiento
	
	if direction:
		velocity = direction * delta * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player = null

func _on_area_attack_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		attack(body)
		$Timer.start()

func _on_area_attack_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		isAttacking = false
		$Timer.stop()

func _on_timer_timeout() -> void:
	if isAttacking:
		attack(player)
