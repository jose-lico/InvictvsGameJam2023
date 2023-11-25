extends Label

@onready var viewport1 = get_node("../Cameras/SubViewport")
@onready var viewport2 = get_node("../Cameras/SubViewport")

func _ready():
	RenderingServer.viewport_set_measure_render_time(viewport1.get_viewport_rid(), true)
	RenderingServer.viewport_set_measure_render_time(viewport2.get_viewport_rid(), true)
	Genisys.sig_on_debug.connect(add_debug_text)

func add_debug_text(data):
	if(data.payload.has("data") && !(data.payload.data is String)):
		if (typeof(data.payload.data) != TYPE_DICTIONARY  ):
			return
		if(data.payload.data.has("input_state")):
			text = "%s | %s" % [data.payload.data.name, data.payload.data.input_state];
