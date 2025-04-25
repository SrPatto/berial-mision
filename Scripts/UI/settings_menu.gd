extends Control

func _on_btn_back_pressed() -> void:
	$".".visible = false
	$btn_sfx.play(.25)
