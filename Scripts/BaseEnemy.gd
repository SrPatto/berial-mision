class_name BaseEnemy
extends CharacterBody3D

@export_category("Attributes")
@export var hp: float
@export var damage: float
@export var speed: float


func movement(delta:float) -> void: 
	pass
	
func die() -> void:
	pass
	
func attack(body: CharacterBody3D) -> void:
	pass

func receive_attack(damage: float) -> void:
	hp -= damage
