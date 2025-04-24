extends Area3D

@export var heal_amount := 30 #¿Cuánta vida restaura?

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(body):
	if body.has_method("apply_heal"):  # Verifica que el cuerpo tenga un método para curarse
		var before_heals = body.current_heals
		body.apply_heal(heal_amount)
		
		if body.current_heals > before_heals:
			queue_free()  # Elimina el objeto de la escena
		else:
			return
