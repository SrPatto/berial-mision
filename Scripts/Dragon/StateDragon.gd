extends State

class_name State_Dragon

const MELEE_RANGE = 8
const MAX_DISTANCE = 32

const FIRE_DAMAGE = 2
const CHARGE_DAMAGE = 20
const MELEE_DAMAGE = 10

var collision_base: CollisionShape3D 
var navigation_agent_3d: NavigationAgent3D
var fire_ray_cast: RayCast3D
var fly_pause_timer: Timer
var cd_fire_breath: Timer


var player: CharacterBody3D
var player_direction
var player_lastPosition
var dragon: CharacterBody3D
var move_speed := 8
var fly_speed := 24
var flight_speed := 1000
