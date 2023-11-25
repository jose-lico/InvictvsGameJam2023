extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		bla()
		
	if event is InputEventKey:
		if event.keycode == KEY_Q:
			cameraInput = -1
		elif event.keycode == KEY_E:
			cameraInput = 1
		else:
			cameraInput = 0
		rotateCamera()

const RAY_LENGTH = 9999

var cameraInput = 0

func rotateCamera():

		
	rotate_y(0.05 * cameraInput) 
	print("waaaa")
	print(transform.basis)

func bla():
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create($Camera3D.global_position,
	$Camera3D.global_position - $Camera3D.global_transform.basis.z * 100)
	var collision = space.intersect_ray(query)
	
	
	if collision:
		print("zzzzz")
		print(query)
		print( collision.collider.name)
	else:
		print("nadinha")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
