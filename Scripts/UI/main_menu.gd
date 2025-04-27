extends Control

@onready var btn_sfx: AudioStreamPlayer = $btn_sfx

const MAIN_SCENE = "res://Scenes/Levels/main_level.tscn" 

func _on_btn_play_pressed() -> void:
	btn_sfx.play(.25)
	SceneTransition.change_scene(MAIN_SCENE)

func _on_btn_options_pressed() -> void:
	btn_sfx.play(.25)
	$SettingsMenu.visible = true

func _on_btn_exit_pressed() -> void:
	btn_sfx.play(.25)
	get_tree().quit()
