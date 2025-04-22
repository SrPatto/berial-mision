extends State_Dragon

var initial_cd = 4

func Enter():
	dragon = $"../.."
	
	dragon.velocity = Vector3.ZERO
	print("ZZZ...")

func Update(_delta: float):
	if !dragon.isSleeping:
		initial_cd -= _delta
		if initial_cd <= 0:
			print("ya desperte del sueño")
			Transitioned.emit(self, "ChaseState")
