extends State

class_name State_Dragon

const MELEE_RANGE = 8
const FIRE_BREATH_RANGE = 16
const MAX_DISTANCE = 32

const FIRE_DAMAGE = 2
const CHARGE_DAMAGE = 20
const MELEE_DAMAGE = 10

var collision_base: CollisionShape3D 
var navigation_agent_3d: NavigationAgent3D
var fire_ray_cast: RayCast3D
var fly_pause_timer: Timer
var cd_fire_breath: Timer
var animation_player: AnimationPlayer

var player: CharacterBody3D
var player_direction
var player_lastPosition
var dragon: CharacterBody3D
var dragon_sfx: AudioStreamPlayer3D

var move_speed := 8
var fly_speed := 24
var flight_speed := 1000

func get_variables():
	player = get_tree().get_first_node_in_group("Player")
	dragon = $"../.."
	fly_pause_timer = $"../../FlyPause_Timer"
	dragon_sfx = $"../../AudioStreamPlayer3D"
	navigation_agent_3d = $"../../NavigationAgent3D"
	cd_fire_breath = $"../../CD_FireBreath"
	fire_ray_cast = $"../../Fire_RayCast"
	animation_player = $"../../dragon_Skeleton/AnimationPlayer"
