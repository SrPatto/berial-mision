extends Control

@onready var btn_sfx: AudioStreamPlayer = $btn_sfx

const TUTORIAL_SCENE = "res://Scenes/Levels/main_level.tscn" # CAMBIAR

func _on_btn_play_pressed() -> void:
	btn_sfx.play(.25)
	SceneTransition.change_scene(TUTORIAL_SCENE)

func _on_btn_options_pressed() -> void:
	btn_sfx.play(.25)
	$SettingsMenu.visible = true

func _on_btn_exit_pressed() -> void:
	btn_sfx.play(.25)
	get_tree().quit()
