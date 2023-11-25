extends Node

# - - - - - - - - - - - - - - - - - - - - -
@export var next_scene: PackedScene;
@export_node_path("AnimationPlayer") var anim_player_path;

# - - - - - - - - - - - - - - - - - - - - -
func _ready():
	Genisys.bind_input_to_callback("play", _on_play_pressed);


# - - - - - - - - - - - - - - - - - - - - -

func goto_next_scene():
	if(next_scene != null):
		get_tree().get_root().add_child(next_scene.instantiate());


# - - - - - - - - - - - - - - - - - - - - -
func clear_this():
	self.queue_free()


func _on_play_pressed(_payload: Dictionary):
	Genisys.unbind_input_to_callback("play", _on_play_pressed);
	var animationP: AnimationPlayer = get_node_or_null(anim_player_path);
	if(animationP != null):
		animationP.play("outro");
