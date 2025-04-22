extends Area3D

@onready var dragon: CharacterBody3D = $"../NavigationRegion3D/Dragon"
@onready var player: CharacterBody3D = $"../Player"

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		print(body)
		print("un loco ha entrado")
		dragon.isSleeping = false
