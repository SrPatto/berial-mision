extends Control

var mouse_captured : bool = false

func _ready() -> void:
	pause()

func pause():
	get_tree().paused = true
	$".".visible = true
	release_mouse()
	
func resume():
	get_tree().paused = false
	$".".visible = false
	capture_mouse()

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _on_btn_continue_pressed() -> void:
	resume()
