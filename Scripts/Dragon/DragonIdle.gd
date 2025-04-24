extends State_Dragon

var initial_cd = 10
var currentSFX

func Enter():
	get_variables()
	
	dragon.velocity = Vector3.ZERO
	currentSFX = dragon_sfx.get_currentClip()
	print("ZZZ...")

func Update(_delta: float):
	if !dragon.isSleeping:
		initial_cd -= _delta
		if currentSFX != dragon_sfx.SFX_DICTIONARY["ROAR"]:
			dragon_sfx.change_sound(1)
			currentSFX = dragon_sfx.SFX_DICTIONARY["ROAR"]
		if initial_cd <= 0:
			print("ya desperte del sueño")
			Transitioned.emit(self, "ChaseState")
