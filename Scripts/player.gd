extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var sens := .1
var hp: float = 10

@export var bullet: PackedScene
@onready var cam = $pivot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #Desaparece el mouse de la pantalla

func _process(delta: float) -> void:
	if hp <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	movement(delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #Al detectar movimiento en el mouse
		rotate_y(deg_to_rad(-event.relative.x * sens)) #Rota el personaje según el movimiento horizontal del mouse
		cam.rotate_x(deg_to_rad(-event.relative.y * sens)) #Rota la cámara en su eje x según el movimiento vertical
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(45)) #Establece los límites de la rotación en el eje x de la cámara
		
	if event.is_action_pressed("shoot"):
		shoot()

func movement(delta:float) -> void: #Movimiento del personaje
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func shoot() -> void:
	var _bullet = bullet.instantiate()
	_bullet.global_position = $gun.global_position
	_bullet.direction = (-transform.basis.z).normalized()
	get_parent().add_child(_bullet)

func receive_attack(damage:float) -> void:
	hp -= damage
