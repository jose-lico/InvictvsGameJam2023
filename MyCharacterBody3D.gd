extends CharacterBody3D

@export var playerCam : Camera3D  
@export var enemyCam : Camera3D

@export var enemyChar : CharacterBody3D

@export var Foward : String
@export var Left : String
@export var Right : String
var DISPARAR = "play"

var canPlay = 1

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

func _ready():
	Genisys.bind_input_to_callback(Foward, Callable(self, "_on_genisys_input"));
	Genisys.bind_input_to_callback(Left, Callable(self, "_on_genisys_input"));
	Genisys.bind_input_to_callback(Right, Callable(self, "_on_genisys_input"));

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


func _on_genisys_input(payload):
	_my_input(payload.data.name, true if payload.data.input_state == "active" else false);

func _input(event):
	if( event is InputEventKey):
		_my_input(event.as_text(), event.pressed);

func _my_input(name, pressed : bool):
	if canPlay == 1:
		if name == DISPARAR :
			if (pressed):
				shootInput = 1
			else:
				shootInput = 0
			
		
		if name == Foward:
			if pressed:
				moveInput = 1
			else: 
				moveInput = 0

		if name == Left:
			if pressed:
				camdirection.x = 1
			else:
				camdirection.x = 0 
					
		if name  == Right:
			if pressed:
				camdirection.y = -1
			else:
				camdirection.y = 0
						
		cameraInput = camdirection.x + camdirection.y
		
	else:
		print("cant move")

func rotateCamera():
	self.rotate_y(deg_to_rad( camSpeed * cameraInput)) 
	
	
func shoot():
	
	var space = get_world_3d().direct_space_state

	if (playerCam ==null || enemyCam == null):
		print("rip pointers")
	else:
		#time for the pointers :) 
		
		var one_bound = 0
		var getenemybody = enemyChar.get_child(0)
		var his_kids = getenemybody.get_children()

		
		
		
		for kid in his_kids:
		
			if (kid.is_in_group('bounds')):
			
				var query = PhysicsRayQueryParameters3D.create(playerCam.global_position,
				kid.global_position)
				var collision = space.intersect_ray(query)
				print(collision)
				
				
				if collision.collider.is_in_group('Player'):
				
					
					var angulodogajo = self.transform.basis.z * -1
					angulodogajo.y = 0
					
					var vectorinimigo = (kid.global_transform.origin - playerCam.global_transform.origin)
					vectorinimigo.y = 0
					vectorinimigo = vectorinimigo.normalized()
					
					
					
					var angulomerdoso = angulodogajo.angle_to(vectorinimigo)
				
					
					if (rad_to_deg(angulomerdoso)  < 30):
						one_bound += 1
				
		if (one_bound > 0):
			one_bound = 0
			get_node('.').calcwinner(1)
		else:
			get_node('.').calcwinner(0)

func _on_game_sig_stopmoving():
	canPlay = 0
	


func _on_game_sig_light():
	canPlay = 1
