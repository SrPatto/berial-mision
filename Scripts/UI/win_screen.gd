extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_exit_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/UI/main_menu.tscn")
