extends WorldEnvironment

var tweens = {} 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# trans & ease types: https://docs.godotengine.org/en/stable/classes/class_tween.html#enum-tween-transitiontype
func tween_prop(prop, value, time, trans, ease):
	tweens[prop] = get_tree().create_tween()
	tweens[prop].tween_property(environment, prop, value, time).set_trans(trans)
	# default, no ease in or out
	if(ease != -1): 
		tweens[prop].set_ease(ease)
