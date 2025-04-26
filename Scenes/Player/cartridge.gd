extends Area3D

@export var ammo_amount: int = 100

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.has_method("collect_cartridge"):
		body.collect_cartridge(ammo_amount)
		queue_free()
