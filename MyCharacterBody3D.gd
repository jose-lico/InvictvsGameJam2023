extends CharacterBody3D

@onready var steps_audio_player = $"../Audio/Footstep"

@export var playerCam : Camera3D  
@export var enemyCam : Camera3D
@export var footsteps : Array[AudioStreamWAV]

@export var enemyChar : CharacterBody3D

@export var player_hand : TextureRect

@export var forward : String
@export var left : String
@export var right : String

@export var editor_forward : Key
@export var editor_left : Key
@export var editor_right : Key

const MOVE_SPEED = 7.5
const CAM_SPEED = 90
const TILT_MAX_AMOUNT = 7.5
const TILT_SPEED = 30
const TILT_RESET = 1
const RAY_LENGTH = 9999

var animator : AnimationPlayer
var remote_transform : RemoteTransform3D
var player_hand_original_pos = Vector2(0,0)
var cam_direction = Vector2(0,0)
var camera_input = 0
var tilt = 0
var moveInput = 0
var can_move : bool = true
var shootInput = 0
var zoomed_in : bool = false
var current_step : int = 0


@export var anim_tree : AnimationTree;
var animation_state_machine;

func _ready():
		Genisys.bind_input_to_callback(forward, Callable(self, "_on_genisys_input"));
		Genisys.bind_input_to_callback(left, Callable(self, "_on_genisys_input"));
		Genisys.bind_input_to_callback(right, Callable(self, "_on_genisys_input"));		
		
		player_hand_original_pos = player_hand.position
		remote_transform = get_node("RemoteTransform3D")
		animator = playerCam.get_node("AnimationPlayer")

		anim_tree.active = true;
		animation_state_machine = anim_tree["parameters/playback"]

		
func _exit_tree():
		Genisys.unbind_input_to_callback(forward, Callable(self, "_on_genisys_input"));
		Genisys.unbind_input_to_callback(left, Callable(self, "_on_genisys_input"));
		Genisys.unbind_input_to_callback(right, Callable(self, "_on_genisys_input"));

func _physics_process(delta):
	#check shoot
	# if (shootInput == 1):
	# 	shoot()

	velocity = Vector3.ZERO

	if(Input.is_key_pressed(editor_forward) && can_move):
		animation_state_machine.travel("walking");
		moveInput = 1
		var direction = (transform.basis * Vector3.FORWARD).normalized()
		velocity.x = direction.x * MOVE_SPEED 
		velocity.z = direction.z * MOVE_SPEED
	
	if(Input.is_key_pressed(editor_left)):
		camera_input += 1
	
	if(Input.is_key_pressed(editor_right)):
		camera_input -= 1
		
	rotateCamera(delta)

	if(moveInput == 1):
		var direction = (transform.basis * Vector3.FORWARD).normalized()
		velocity.x = direction.x * MOVE_SPEED 
		velocity.z = direction.z * MOVE_SPEED
		moveInput = 0;
	
	move_and_slide()

func _on_genisys_input(payload):
	_handle_genisys_input(payload.data.name, true if payload.data.input_state == "active" else false);

func _handle_genisys_input(name, pressed : bool):
	if can_move:
		if name == forward:
			if pressed:
				moveInput = 1
				animation_state_machine.travel("walking");
			else:
				moveInput = 0
				animation_state_machine.travel("Idle");
		if name == left:
			if pressed:
				cam_direction.x = 1
			else:
				cam_direction.x = 0 
		if name == right:
			if pressed:
				cam_direction.y = -1
			else:
				cam_direction.y = 0
				
		camera_input = cam_direction.x + cam_direction.y

func rotateCamera(delta):
	if can_move:
		self.rotate_y(deg_to_rad(CAM_SPEED * camera_input * delta))

	if(velocity.length() > 2 && zoomed_in == false):
		zoomed_in = true
		animator.play("ZoomIn")
	elif(velocity.length() < 0.5 && zoomed_in == true):
		zoomed_in = false
		animator.play("ZoomOut")

	tilt_hand(delta)

	# COMMENT THIS FOR DEPLOYMENT ON MACHINE
	camera_input = 0

func tilt_hand(delta):
	# tilt tends towards the middle
	if(camera_input == 0 || !can_move):
			tilt = lerpf(tilt, 0, TILT_SPEED * TILT_RESET * delta);
			player_hand.position = lerp(player_hand.position, player_hand_original_pos, TILT_SPEED * TILT_RESET * delta);
	else:
		var compensate = 1
		if(camera_input == 1 && tilt < 0):
			compensate = 3.5
		elif(camera_input == -1 && tilt > 0):
			compensate = 3.5
			
		tilt += camera_input * delta * TILT_SPEED * compensate
		#tilt += (cam_direction.x + cam_direction.y) * delta * TILT_SPEED
	
	tilt = clamp(tilt, -TILT_MAX_AMOUNT, TILT_MAX_AMOUNT);			
		
	player_hand.rotation_degrees = 0 - tilt
	var hand_tilt = Vector2(tilt * 1.25, -abs(tilt) * 0.25) * 5.0
	var hand_bobble_y = sin(Time.get_ticks_msec() * delta * (0.33 + velocity.length() * 0.05)) * (3 + velocity.length() * 0.7)
	var hand_bobble_x = cos((Time.get_ticks_msec() * delta * (0.33 + velocity.length() * 0.05)) * 0.5)  * (2 + velocity.length() * 0.5);
	
	# play steps audio
	if(hand_bobble_y < -2.5 && moveInput == 1):
		current_step+=1;
		if(current_step == footsteps.size()):
			current_step = 0;
				
		if(!steps_audio_player.playing):				
			steps_audio_player.stream = footsteps[current_step];
			steps_audio_player.play();				
	
	player_hand.position = player_hand_original_pos + Vector2(hand_bobble_x, hand_bobble_y) - hand_tilt
	
	remote_transform.rotation_degrees = Vector3(0, remote_transform.rotation_degrees.y, 0 + tilt * 0.15)
	remote_transform.position += Vector3(hand_bobble_x * 0.0005, hand_bobble_y * 0.0019, 0)

func _on_game_sig_startmoving():
	can_move = true
func _on_game_sig_stopmoving():
	can_move = false

func _on_game_sig_shoot():
	
	
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

					if (rad_to_deg(angulomerdoso)  < 10):
						one_bound += 1
				
		if (one_bound > 0):
			one_bound = 0
			get_tree().root.get_node('Game').calcwinner(1)
		else:
			get_tree().root.get_node('Game').calcwinner(0)
