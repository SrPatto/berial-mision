extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var sprint_bar: TextureProgressBar = $SprintBar
@onready var ammo_bar: TextureProgressBar = $AmmoBar

@export var max_health = 100
@export var max_sprint = 100
@export var max_ammo = 100

var current_health = max_health
var current_sprint = max_sprint
var current_ammo = max_ammo

# Para actualizar las barras
func _process(delta: float) -> void:
	update_health_bar()
	update_sprint_bar()
	update_ammo_bar()

# Actualiza la barra de salud
func update_health_bar() -> void:
	health_bar.value = current_health / max_health * 100.0

# Actualiza la barra de sprint
func update_sprint_bar() -> void:
	sprint_bar.value = current_sprint / max_sprint * 100.0

# Actualiza la barra de munición
func update_ammo_bar() -> void:
	ammo_bar.value = current_ammo / max_ammo * 100.0

# Métodos para modificar las barras
func take_damage(damage: float) -> void:
	current_health -= damage
	if current_health < 0:
		current_health = 0
	update_health_bar()

func use_sprint(amount: float) -> void:
	current_sprint -= amount
	if current_sprint < 0:
		current_sprint = 0
	update_sprint_bar()

func reload_ammo(amount: int) -> void:
	current_ammo = amount
	update_ammo_bar()
