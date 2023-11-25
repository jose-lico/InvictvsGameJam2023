extends Node

var inp = 0;


func _input(event):
	if(event is InputEventKey && event.pressed):
		if(event.keycode == KEY_SPACE):
			print(inp)
			inp += 1;
			if(inp > 13):
				inp = 0;
			Genisys.send_data("hardware/led_strips/set_pattern", {payload="%s" % inp});
		elif(event.keycode == KEY_F):
			Genisys.send_data("hardware/led_strips/set_pattern", {payload="flash"});
	
