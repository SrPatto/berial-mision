extends State_Dragon

var timer= 5

func Enter():
	get_variables()
	
	dragon_sfx.change_sound(dragon_sfx.SFX_DICTIONARY["DEFEATED"])
	
func Exit():
	pass
	
func Update(_delta: float):
	timer -= _delta
	
	if timer <= 0:
		dragon.queue_free()
	else:
		$"../../VFX_Level_UP/AnimationPlayer".play()
