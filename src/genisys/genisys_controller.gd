extends GenisysCenter


# ==================== ====================
# Public
# ==================== ====================

func _enter_tree():
	led_pattern_json_path="res://src/genisys/test_pattern.json"
	blink_pattern_json_path = "res://src/genisys/patterns/btn_patterns.json"

	server_address = "192.168.220.109"
	_boot_controller();


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called before connect to the socket
func register():
	bind_id_to_callback("core/settings/get_active_capabilities", Callable(self, "_on_get_active_capabilities"));

	bind_id_to_callback("hardware/led_strips/add_patterns", Callable(self, "_print_payload"));
	bind_id_to_callback("hardware/outputs/add_blink_patterns", Callable(self, "_print_payload"));


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called after connection established
func connection_established():
	send_data("core/settings/get_active_capabilities");


# ==================== ====================
# Private
# ==================== ====================

# - - - - - - - - - - - - - - - - - - - - -
# func _on_get_configuration(payload: Dictionary):
# 	print(JSON.print(payload, "\t"));

func _on_led_strips_get_info(payload: Dictionary):
	print(JSON.stringify(payload, "\t"));

func _print_payload(payload: Dictionary):
	print(JSON.stringify(payload, "\t"));


func _on_get_active_capabilities(payload: Dictionary):
	_print_payload(payload);
	
	if(!payload.data.has("hardware")):
		send_data("core/settings/add_capability", {payload="hardware"});

	if(!_ledpatterns_data.is_empty()):
		send_data("hardware/led_strips/add_patterns", {payload=_ledpatterns_data.patterns});
		# send_data("hardware/led_strips/set_pattern", {payload="first_example"});


	if(!_blinkpatterns_data.is_empty()):
		send_data("hardware/outputs/add_blink_patterns", {payload=_blinkpatterns_data.patterns});

		#! To Remove
		send_data("hardware/outputs/start_blink_pattern", {payload={"group": "tower_light", "id": "tower_blink"}});
		send_data("hardware/outputs/start_blink_pattern", {payload={"group": "buttons", "id": "initial_set"}});


# - - - - - - - - - - - - - - - - - - - - -
func _on_play_state_change(payload: Dictionary):
	print(JSON.stringify(payload, "\t"));
