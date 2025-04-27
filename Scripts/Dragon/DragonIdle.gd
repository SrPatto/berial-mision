extends State_Dragon

var initial_cd = 10
var currentSFX

func Enter():
	get_variables()
	
	dragon.velocity = Vector3.ZERO
	currentSFX = dragon_sfx.get_currentClip()
	animation_player.play("Dragon/Idle") # todo : sleep animation 

func Update(_delta: float):
	if !dragon.isSleeping:
		initial_cd -= _delta
		# todo : roar animation 
		if currentSFX != dragon_sfx.SFX_DICTIONARY["ROAR"]:
			dragon_sfx.change_sound(1)
			currentSFX = dragon_sfx.SFX_DICTIONARY["ROAR"]
		if initial_cd <= 0:
			Transitioned.emit(self, "ChaseState")
	
	if dragon.LIFE <= 0:
		Transitioned.emit(self, "DeathState")
