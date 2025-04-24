extends Area3D

var direction: Vector3
var speed: float = 100
var damage: float = 1
var cooldown: float = 1.0

func _ready() -> void:
	#isAlive = true
	#await get_tree().create_timer(1).timeout
	#queue_free() if isAlive else null
	pass

func _physics_process(delta: float) -> void:
	position += direction * speed * delta #+= produce movimiento acelerado
	cooldown -= delta
	if cooldown <= 0:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is BaseEnemy:
		body.receive_attack(damage)
		queue_free()
