extends Node3D

@onready var dragon: Dragon = $NavigationRegion3D/Dragon
@onready var player: CharacterBody3D = $Player
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 5.0
@onready var camera_3d: Camera3D = $Player/pivot/SpringArm3D/Camera3D
@onready var rand = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()

func _process(delta: float) -> void:
	if player.is_frozen:
		$CanvasLayer/GameOver.visible = true
	if dragon == null:
		SceneTransition.change_scene("res://Scenes/UI/win_screen.tscn")
		
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	camera_3d.h_offset = get_random_offset()
	camera_3d.v_offset = get_random_offset()

func apply_shake(strength) -> void:
	shake_strength = strength

func get_random_offset():
	return rand.randf_range(-shake_strength, shake_strength)
