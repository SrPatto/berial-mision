extends CharacterBody3D

var direction: Vector3
var speed: float = 100
var damage: float = 1
var isAlive: bool

func _ready() -> void:
	isAlive = true
	await get_tree().create_timer(1).timeout
	queue_free() if isAlive else null

func _physics_process(delta: float) -> void:
	velocity += direction * speed * delta #+= produce movimiento acelerado
	move_and_slide() 


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is BaseEnemy:
		body.receive_attack(damage)
		queue_free()
