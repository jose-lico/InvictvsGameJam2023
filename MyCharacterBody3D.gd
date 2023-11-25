extends CharacterBody3D

@export var playerCam : Camera3D  
@export var enemyCam : Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
		
var camdirection = Vector2(0,0)
const camSpeed = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var cameraInput = 0
var moveInput = 0
const RAY_LENGTH = 9999
var shootInput = 0

func _physics_process(delta):
	#check shoot
	if (shootInput == 1):
		shoot()
	
	# Add the gravity.


	
	if (moveInput == 1):
		var direction = (transform.basis * Vector3(0,0,-1)).normalized() 
		
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED 
		
	else:	
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if (cameraInput != 0):
		rotateCamera()

	move_and_slide()






func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			if (event.pressed):
				shootInput = 1
			else:
				shootInput = 0
		
	
		if event.keycode == KEY_W:
			if event.pressed:
				moveInput = 1
			else: 
				moveInput = 0

		if event.keycode == KEY_Q:
			if event.pressed:
				camdirection.x = 1
			elif !event.pressed:
				camdirection.x = 0 
				
		if event.keycode == KEY_E:
			if event.pressed:
				camdirection.y = -1
			elif !event.pressed:
				camdirection.y = 0
					
		cameraInput = camdirection.x + camdirection.y

func rotateCamera():
	self.rotate_y(deg_to_rad( camSpeed * cameraInput)) 
	
	
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




