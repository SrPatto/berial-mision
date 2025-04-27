extends CharacterBody3D

@export_group("Combat")
@export var health = 100
@export var max_health = 100
@export var max_heals := 3 #¿Cuántas curas puede tener como máximo?

@export_group("Movement")
@export var SPEED = 10.0
@export var JUMP_VELOCITY = 6
@export var sens := .1
@export var stamina = 100.0
@export var dodge_strength := 15.0
@export var dodge_duration := 1.2
@export var dodge_stamina_cost := 30.0

@export_group("Ammo")
@export var magazine_size := 100

@onready var cam:  = $pivot
@onready var animation_player: AnimationPlayer = $player_OnlySkeleton/AnimationPlayer

const AIM_OFFSET := Vector3(1, 1.5, 0.5) # Mueve la cámara medio metro hacia adelante
const NORMAL_OFFSET := Vector3(1, 2, 2)

var speedWalk = 6.0
var speedSprint = 12.0
var lastStaminaBlock := -1
var maxStamina := 100.0
var reserve_ammo := 100 #Balas que no están en el cargador
var staminaRegenRate := 10.0
var staminaDrainRate := 25
var fire_rate = 0.2 #Sengundos entre disparos 
var dodge_timer := 0.0
var time_since_last_shot = 0.0
var ammo := magazine_size
var current_heals := max_heals #curas que tiene actualmente
var dodge_direction: Vector3 = Vector3.ZERO

var canSprint := true
var is_dodging := false
var is_shooting = false
var is_shooting_auto = false
var is_reloading = false
var is_takin_damage = false
var is_healing := false
var is_aiming := false
var is_sprinting := false
var is_starting_to_jump = false
var is_in_air = false
var is_landing = false
var is_frozen = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #Desaparece el mouse de la pantalla
	animation_player.play("player/Idle")
	animation_player.connect("animation_finished", Callable(self, "_on_animation finished"))

func _process(delta: float) -> void:
	if health <= 0:
		die()
		return

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
		
	if is_shooting_auto and  not is_shooting:
		time_since_last_shot += delta
		if time_since_last_shot >= fire_rate:
			fire()
			time_since_last_shot = 0.0
		
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
	if is_frozen:
		return
	
	if event is InputEventMouseMotion: #Al detectar movimiento en el mouse
		rotate_y(deg_to_rad(-event.relative.x * sens)) #Rota el personaje según el movimiento horizontal del mouse
		cam.rotate_x(deg_to_rad(-event.relative.y * sens)) #Rota la cámara en su eje x según el movimiento vertical
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(45)) #Establece los límites de la rotación en el eje x de la cámara
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_shooting_auto = true
				if ammo > 0:
					fire()
					time_since_last_shot = 0.0
			else:
				is_shooting_auto = false
		
	if event.is_action_pressed("aim"): #Si se presiona botón de aim, apunta
		start_aim()
		
	if event.is_action_released("aim"): #Deja de apuntar si se libera botón de aim
		stop_aim()
		
	if event.is_action_pressed("heal"):
		heal()
		
	if event.is_action_pressed("reload"):
		reload()

func movement(delta:float) -> void: #Movimiento del personaje
	if is_frozen:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if is_starting_to_jump or is_in_air:
			is_starting_to_jump = false
			is_in_air = false
			is_landing = true
			animation_player.play("player/Jump3")
			return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_starting_to_jump = true
		is_in_air = false
		is_landing = false
		animation_player.play("player/Jump1")
		return
	
	if is_starting_to_jump and not is_on_floor():
		is_starting_to_jump = false
		is_in_air = true
		animation_player.play("player/Jump2")
		return

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if not is_takin_damage and not is_shooting and not is_reloading and not (is_starting_to_jump or is_in_air or is_landing):
			if is_sprinting:
				animation_player.play("player/Sprint")
			elif is_aiming:
				animation_player.play("player/AimWalk")
			else:
				animation_player.play("player/Walk")

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if not is_takin_damage and not is_shooting and not is_reloading and not (is_starting_to_jump or is_in_air or is_landing):
			if is_aiming:
				animation_player.play("player/Apuntar")
			else:
				animation_player.play("player/Idle")

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

func apply_heal(amount: int) -> void:
	if current_heals < max_heals:
		current_heals += 1
		print("Recogiste una cura. Curas actuales: ", current_heals)
	else:
		print("No puedes recoger más curas, inventario lleno")

func collect_cartridge(ammount: int):
	reserve_ammo += ammount
	print("Cartucho recogido. Munición en reserva: ", reserve_ammo)

func dodge() -> void:
	stamina -= dodge_stamina_cost
	is_dodging = true
	dodge_timer = dodge_duration
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction == Vector3.ZERO:
		direction = -transform.basis.z.normalized()
	
	dodge_direction = direction * dodge_strength
	animation_player.play("player/Dodge")
	velocity.x = dodge_direction.x
	velocity.z = dodge_direction.z
	is_sprinting = false
	await animation_player.animation_finished
	is_dodging = false

func receive_attack(damage:float) -> void:
	if not is_frozen:
		health -= damage
		print("Recibiste daño, amigo. Vida restante:", health)
	
		if is_takin_damage:
			return
		
		is_takin_damage = true
		animation_player.play("player/Damage")
		await animation_player.animation_finished
		is_takin_damage = false

func start_aim() -> void: #Comenzar a apuntar
	is_aiming = true
	var tween = create_tween()
	tween.tween_property(cam, "transform:origin", AIM_OFFSET, 0.2)
	animation_player.play("player/Apuntar")

func stop_aim() -> void: #Dejar de apuntar
	is_aiming = false
	var tween = create_tween()
	tween.tween_property(cam, "transform:origin", NORMAL_OFFSET, 0.2)
	animation_player.play("player/Idle")

func heal():
	if current_heals <= 0 or is_healing or is_takin_damage or is_dodging or is_shooting:
		print("No puedes curarte. Curas disponibles: ", current_heals)
		return
	
	if health >= max_health:
		print("Ya tienes la vida al máximo, no puedes curarte")
		return
	
	is_healing = true
	current_heals -= 1 #Se comsume una cura
	
	health = min(health + 50, max_health)
	print("Te curaste, vida actual: ", health, " | Curas restantes: ", current_heals)
	is_healing = false

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	velocity =Vector3.ZERO
	animation_player.play("player/Die") 
	
	is_frozen = true
	
	set_process(false)
	await animation_player.animation_finished
	print("Has muerto, amigazo, reiniciando escena")

func fire():
	if ammo <= 0:
		print("¡Sin balas! Recarga")
		return
	
	is_shooting = true
	animation_player.play("player/Shoot")
	await animation_player.animation_finished
	is_shooting = false
	
	ammo -= 1
	print("Bang! balas restantes: ", ammo)
	
	var cam: Camera3D = $pivot/SpringArm3D/Camera3D
	var origin = cam.project_ray_origin(get_viewport().get_mouse_position())
	var cam_mouse_ray_project = cam.project_ray_normal(get_viewport().get_mouse_position())
	
	$GunFireRayCast.fire_shot(origin, cam_mouse_ray_project)

func reload():
	if ammo == magazine_size:
		print("Ya tienes el cargador lleno, mamahuevo")
		return
	
	var needed = magazine_size - ammo
	var to_reload = min(needed, reserve_ammo)
	
	if to_reload > 0:
		ammo += to_reload
		reserve_ammo -= to_reload
		is_reloading = true
		
		if is_moving():
			print("Me muevo")
			animation_player.play("player/ReloadWalk")
		else:
			print("No me muevo")
			animation_player.play("player/Reload")
			
		print("Recargando... Balas en cargador: ", ammo, " | En reserva: ", reserve_ammo)
		
		animation_player.connect("animation_finished", Callable(self, "_on_reload_animation_finished"))
	else:
		print("¡Se nos acabaron las balas!")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "player/Jump3":
		is_landing = false
	if anim_name == "player/Reload" or anim_name == "player/ReloadWalk":
		is_reloading = false	
		animation_player.disconnect("animation_finished", Callable(self, "_on_reload_animation_finished"))

func is_moving() -> bool:
	return velocity.length() != 0
