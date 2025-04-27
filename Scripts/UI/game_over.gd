extends Control

func _on_btn_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_btn_exit_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/UI/main_menu.tscn")
