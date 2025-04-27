extends CanvasLayer

func _process(delta: float) -> void:
	$Healthbar.value = get_parent().health
	$StaminaBar.value = get_parent().stamina
	$BulletsBar.value = get_parent().ammo
	$BulletsLabel.text = str(get_parent().reserve_ammo) + " balas en reserva"
	$HealsLabel.text = str(get_parent().current_heals) + "/3"
