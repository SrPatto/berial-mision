extends Node3D

const RAY_LENGHT = 1000
const COLLISION_LAYER_ID = pow(2, 4) + pow(2, 3) + pow (2, 1)
var check_hit = false
var origin
var cam_mouse_ray_project

func fire_shot(origin_in, cam_mouse_ray_project_in):
	print("fire_shot")
	origin = origin_in
	cam_mouse_ray_project = cam_mouse_ray_project_in
	check_hit = true

func _check_hit():
	print("_check_hit")
	
	var end = origin + cam_mouse_ray_project * RAY_LENGHT
	print("Ray end position: ", end)  # Verificar la longitud y dirección del rayo
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, COLLISION_LAYER_ID, [$".."])
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result and result.collider:
		var collider = result.collider
		print("Collider: ", collider)
		print("Hit! Collider: ", result.collider.name)  # Verificar qué objeto se está golpeando
		if collider.is_in_group("Dragon") :
			print("DRAGON hit!")
			collider.get_parent().get_parent().get_parent().get_parent().get_parent().receive_attack(10.0)
	
func _physics_process(delta: float) -> void:
	if check_hit:
		check_hit = false
		_check_hit() 
