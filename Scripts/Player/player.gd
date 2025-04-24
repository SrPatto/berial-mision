extends CharacterBody3D

@export_group("Combat")
@export var health = 100
@export var max_health = 100
@export_group("Movement")
@export var SPEED = 10.0
@export var JUMP_VELOCITY = 6
@export var sens := .1
@export var stamina = 100.0
@export var dodge_strength := 12.0
@export var dodge_duration := 0.4
@export var dodge_stamina_cost := 20.0

@onready var cam:  = $pivot
@onready var animation_player: AnimationPlayer = $player_OnlySkeleton/AnimationPlayer

const AIM_OFFSET := Vector3(1, 1.5, 0.5) # Mueve la cámara medio metro hacia adelante
const NORMAL_OFFSET := Vector3(1, 2, 2)

var speedWalk = 6.0
var speedSprint = 12.0
var lastStaminaBlock := -1
var maxStamina := 100.0
var staminaRegenRate := 10.0
var staminaDrainRate := 25
var dodge_timer := 0.0
var dodge_direction: Vector3 = Vector3.ZERO

var canSprint := true
var is_dodging := false
var is_shooting = false
var is_takin_damage = false
var is_aiming := false
var is_sprinting := false

"""Variables de curación"""
@export var max_heals := 3 #¿Cuántas curas puede tener como máximo?
var current_heals := max_heals #curas que tiene actualmente
var is_healing := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #Desaparece el mouse de la pantalla
	animation_player.play("player_IdleWithWeapon/Armature|mixamo_com|Layer0")

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()	

func _physics_process(delta: float) -> void:
	handle_stamina(delta)
	
	if Input.is_action_pressed("sprint") and canSprint:
		is_sprinting = true
		SPEED = speedSprint
	else:
		is_sprinting = false
		SPEED = speedWalk
	
	if Input.is_action_just_pressed("dodge") and not is_dodging and stamina >= dodge_stamina_cost:
		dodge()
		
	if is_dodging:
		velocity.x = dodge_direction.x
		velocity.z = dodge_direction.z
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
	else:
		movement(delta)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #Al detectar movimiento en el mouse
		rotate_y(deg_to_rad(-event.relative.x * sens)) #Rota el personaje según el movimiento horizontal del mouse
		cam.rotate_x(deg_to_rad(-event.relative.y * sens)) #Rota la cámara en su eje x según el movimiento vertical
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(45)) #Establece los límites de la rotación en el eje x de la cámara
		
	if event is InputEventMouseButton && event.pressed && Input.is_action_just_pressed("shoot"):
		print("fire")
		
		if not is_takin_damage and not is_shooting:
			is_shooting = true
			animation_player.play("player_Shoot/Armature|mixamo_com|Layer0")
			await animation_player.animation_finished
			is_shooting = false
		
		var cam: Camera3D = $pivot/SpringArm3D/Camera3D
		var origin = cam.project_ray_origin(event.position)
		var cam_mouse_ray_project = cam.project_ray_normal(event.position)
		
		$GunFireRayCast.fire_shot(origin, cam_mouse_ray_project)
	
	if event.is_action_pressed("aim"): #Si se presiona botón de aim, apunta
		start_aim()
	
	if event.is_action_released("aim"): #Deja de apuntar si se libera botón de aim
		stop_aim()
		
	if event.is_action_pressed("heal"):
		heal()

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
		
		if not is_takin_damage and not is_shooting:
			if is_aiming:
				animation_player.play("player_WalkWithWapon/Armature|mixamo_com|Layer0")  
			else:
				animation_player.play("player_Walk/Armature|mixamo_com|Layer0")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if not is_takin_damage and not is_shooting:
			if is_aiming:
				animation_player.play("player_Apuntar/Armature|mixamo_com|Layer0")
			else:
				animation_player.play("player_IdleWithWeapon/Armature|mixamo_com|Layer0")

func handle_stamina(delta: float) -> void:
	if is_sprinting and is_on_floor():
		stamina -= staminaDrainRate * delta
		if stamina <= 0:
			stamina = 0
			canSprint = false
	else:
		if is_on_floor() and not is_sprinting:
			stamina += staminaRegenRate * delta
			if stamina > maxStamina:
				stamina = maxStamina
				
	if stamina > 50.0:
		canSprint = true
	
	var currentBlock := int(stamina / 10)
	if currentBlock != lastStaminaBlock:
		print("Stamina: ", stamina, "| Can sprint: ", canSprint)
		lastStaminaBlock = currentBlock

"""Suma de curas al inventario"""
func apply_heal(amount: int) -> void:
	if current_heals < max_heals:
		current_heals += 1
		print("Recogiste una cura. Curas actuales: ", current_heals)
	else:
		print("No puedes recoger más curas, inventario lleno")

func dodge() -> void:
	stamina -= dodge_stamina_cost
	is_dodging = true
	dodge_timer = dodge_duration
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction == Vector3.ZERO:
		direction = -transform.basis.z.normalized()
		
	dodge_direction = direction * dodge_strength

func receive_attack(damage:float) -> void:
	health -= damage
	print("Recibiste daño, amigo. Vida restante:", health)
	
	if is_takin_damage:
		return
		
	is_takin_damage = true
	animation_player.play("player_DamageWithWeapon/Armature|mixamo_com|Layer0")
	await animation_player.animation_finished
	is_takin_damage = false

func start_aim() -> void: #Comenzar a apuntar
	is_aiming = true
	var tween = create_tween()
	tween.tween_property(cam, "transform:origin", AIM_OFFSET, 0.2)
	animation_player.play("player_Apuntar/Armature|mixamo_com|Layer0")

func stop_aim() -> void: #Dejar de apuntar
	is_aiming = false
	var tween = create_tween()
	tween.tween_property(cam, "transform:origin", NORMAL_OFFSET, 0.2)
	animation_player.play("player_IdleWithWeapon/Armature|mixamo_com|Layer0")

func heal():
	if current_heals <= 0 or is_healing or is_takin_damage or is_dodging or is_shooting:
		print("No puedes curarte. Curas disponibles: ", current_heals)
		return
	
	if health >= max_health:
		print("Ya tienes la vida al máximo, no puedes curarte")
		return
	
	is_healing = true
	current_heals -= 1 #Se comsume una cura
	
	health = min(health + 50, 100)
	print("Te curaste, vida actual: ", health, " | Curas restantes: ", current_heals)
	is_healing = false
