extends Label

func add_debug_text(data):
	if(data.payload.has("data") && !(data.payload.data is String)):
		if (typeof(data.payload.data) != TYPE_DICTIONARY  ):
			return
		if(data.payload.data.has("input_state")):
			text = "%s | %s" % [data.payload.data.name, data.payload.data.input_state];
