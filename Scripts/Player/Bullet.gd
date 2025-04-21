extends Area3D

var direction: Vector3
var speed: float = 100
var damage: float = 1
var isAlive: bool

func _ready() -> void:
	#isAlive = true
	#await get_tree().create_timer(1).timeout
	#queue_free() if isAlive else null
	pass

func _physics_process(delta: float) -> void:
	position += direction * speed * delta #+= produce movimiento acelerado

func _on_body_entered(body: Node3D) -> void:
	if body is BaseEnemy:
		body.receive_attack(damage)
		queue_free()
