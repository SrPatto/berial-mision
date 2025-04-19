extends State_Dragon

const MAX_HEIGHT = 20

var next_attack
var isMaxHeigth = false

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	fly_pause_timer = $"../../FlyPause_Timer"
	
	isMaxHeigth = false
	dragon.velocity = Vector3.ZERO
	dragon.isFlying = true
	
	next_attack = randi_range(1,2)

func Exit():
	pass
	
func Update(_delta: float):
	dragon.look_at_from_position(dragon.global_position, Vector3(player.global_position.x, dragon.global_position.y, player.global_position.z), Vector3.UP, true)
	
	if isMaxHeigth && fly_pause_timer.is_stopped():
		match next_attack:
			1:
				print("FUUUUUUUU fire tst tsts")
				Transitioned.emit(self, "FireBreathState")
			2:
				print("YO SOY LA GUERRAAAAAAAAAAAAAA!!!")
				Transitioned.emit(self, "ChargeState")
	pass
	
func Physics_Update(_delta: float):
	if dragon.global_position.y <= MAX_HEIGHT:
		fly(_delta)
	elif isMaxHeigth == false:
		dragon.velocity = Vector3.ZERO
		isMaxHeigth = true
		fly_pause_timer.start()
	pass

func fly(_delta):
	dragon.velocity.y = flight_speed * _delta
