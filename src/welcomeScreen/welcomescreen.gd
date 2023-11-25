extends Node

# - - - - - - - - - - - - - - - - - - - - -
@export var next_scene: PackedScene;
@export_node_path("AnimationPlayer") var anim_player_path;


# - - - - - - - - - - - - - - - - - - - - -
func _enter_tree():
	GameManager.state_changed.connect(_on_state_change);

func _exit_tree():
	GameManager.state_changed.disconnect(_on_state_change)

# - - - - - - - - - - - - - - - - - - - - -
#
func _ready():
	Genisys.bind_input_to_callback("play", _on_play_pressed);
	if(GameManager.previous_state == GameManager.STATES.INTRO):
		GameManager.change_state(GameManager.STATES.INTRO);



func _on_state_change(state: GameManager.STATES):
	match state:
		GameManager.STATES.INTRO:
			var animationP: AnimationPlayer = get_node_or_null(anim_player_path);
			if(animationP != null):
				animationP.play("intro_game");
				

		GameManager.STATES.MENU:
			var animationP: AnimationPlayer = get_node_or_null(anim_player_path);
			if(animationP != null):
				animationP.play("intro");

		GameManager.STATES.INTROGAME:
			if(next_scene != null):
				next_scene = ResourceLoader.load("res://game.tscn")
				get_tree().get_root().add_child(next_scene.instantiate());
				GameManager.state_changed.disconnect(_on_state_change)
				queue_free()
				


# - - - - - - - - - - - - - - - - - - - - -

func goto_menu_state():
	GameManager.change_state(GameManager.STATES.MENU);

func onBangPress():
	Genisys.unbind_input_to_callback("play", _on_play_pressed);
	var animationP: AnimationPlayer = get_node_or_null(anim_player_path);
	if(animationP != null):
		animationP.play("outro");
# - - - - - - - - - - - - - - - - - - - - -
#
func goto_next_scene():
	var blaaa =	GameManager.get_signal_connection_list('state_changed')
	for blo in blaaa:
		print(blo)
	GameManager.change_state(GameManager.STATES.INTROGAME);
	

# - - - - - - - - - - - - - - - - - - - - -
#
func clear_this():
	GameManager.state_changed.disconnect(_on_state_change)
	self.queue_free()


# - - - - - - - - - - - - - - - - - - - - -
#
func _on_play_pressed(_payload: Dictionary):
	Genisys.unbind_input_to_callback("play", _on_play_pressed);
	var animationP: AnimationPlayer = get_node_or_null(anim_player_path);
	if(animationP != null):
		animationP.play("outro");
