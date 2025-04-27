extends Control

@onready var btn_sfx: AudioStreamPlayer = $btn_sfx
var mouse_captured : bool = false

func pause():
	get_tree().paused = true
	$".".visible = true
	release_mouse()
	
func resume():
	get_tree().paused = false
	$".".visible = false
	capture_mouse()

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_btn_resume_pressed() -> void:
	btn_sfx.play(.25)
	resume()

func _on_btn_settings_pressed() -> void:
	btn_sfx.play(.25)
	$SettingsMenu.visible = true

func _on_btn_mainmenu_pressed() -> void:
	btn_sfx.play(.25)
	get_tree().paused = false
	SceneTransition.change_scene("res://Scenes/UI/main_menu.tscn")

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _process(delta: float) -> void:
	testEsc()
