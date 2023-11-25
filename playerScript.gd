extends Node3D
@export var playerCam : Camera3D  
@export var enemyCam : Camera3D



func _input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE:
		shoot()
		
	if event is InputEventKey:
		if event.keycode == KEY_Q:
			cameraInput = -1
			rotateCamera()
		elif event.keycode == KEY_E:
			cameraInput = 1
			rotateCamera()
		else:
			cameraInput = 0
		

const RAY_LENGTH = 9999


var cameraInput = 0

func rotateCamera():
	self.rotate_y(0.05 * cameraInput) 
	print("waaaa")
	print(transform.basis)
	
func shoot():
	var space = get_world_3d().direct_space_state

	if (playerCam ==null || enemyCam == null):
		print("rip pointers")
	else:
		var query = PhysicsRayQueryParameters3D.create(playerCam.global_position,
		enemyCam.global_position - playerCam.global_transform.basis.z * 100)
		var collision = space.intersect_ray(query)
		
		
		if collision:
			print("zzzzz")
			print(query)
			print( collision.collider.name)
		else:
			print("nadinha")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerCam.position = self.position
	playerCam.rotation = self.rotation
