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
# Called before exiting the tree
# func on_destroy():
# 	if(is_connected):
# 		send_data("core/settings/remove_capability", {payload="hardware"});
# 		send_data("hardware/jackpot_display/set_text", {payload={"alignment": "right", "text": "00"}});


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called before connect to the socket
func register():
	bind_input_to_callback("play", Callable(self, "_on_play_state_change"))
	bind_input_to_callback("bet_more", Callable(self, "_on_bet_more_state_change"));
	bind_input_to_callback("autoplay", Callable(self, "_on_auto_state_change"));

	bind_id_to_callback("hardware/led_strips/add_patterns", Callable(self, "_print_payload"));
	bind_id_to_callback("hardware/outputs/add_blink_patterns", Callable(self, "_print_payload"));


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called after connection established
func connection_established():
	send_data("core/settings/remove_capability", {payload="hardware"});
	send_data("hardware/led_strips/get_info");
	
	# send_data("core/settings/add_capability", {payload="hardware"});

	# send_data("core/settings/update_configuration", {payload={
	# 	"hardware/cabinet_type":2, "hardware/io_type": "quixant", "hardware/io_light_tower_enable": false}});
	
	# send_data("core/settings/get_configuration");
	# send_data("hardware/led_strips/get_info");

	# if(!_ledpatterns_data.is_empty()):
	# 	send_data("hardware/led_strips/add_patterns", {payload=_ledpatterns_data.patterns});
	# 	send_data("hardware/led_strips/set_pattern", {payload="first_example"});


	if(!_blinkpatterns_data.is_empty()):
		send_data("hardware/outputs/add_blink_patterns", {payload=_blinkpatterns_data.patterns});
		# send_data("hardware/outputs/start_blink_pattern", {payload={"group": "tower_light", "id": "tower_blink"}});
		# send_data("hardware/outputs/start_blink_pattern", {payload={"group": "buttons", "id": "initial_set"}});


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

# - - - - - - - - - - - - - - -
# Callback on enter state
func _on_enter_state(_current_state):
	if(_current_state == null):
		return;
	

	match _current_state:
		"idle", "end_game":
			send_data("hardware/outputs/stop_blink_pattern", {payload={group="draw_group"}});
			send_data("hardware/outputs/start_blink_pattern", {payload={"group": "idle_group", "id": "test_pattern"}});


		"draw_balls":
			send_data("hardware/outputs/stop_blink_pattern", {payload={group="idle_group"}});
			send_data("hardware/outputs/start_blink_pattern", {payload={"group": "draw_group", "id": "test_pattern"}});


# - - - - - - - - - - - - - - - - - - - - -
# Callback funtion to check the availability of jackpot
# func _on_jackpot_data_set(jackpot_data):
# 	if(jackpot_data.size() == 0):
# 		return;
	
# 	ReduxCenter.unsubscribe(self, "_on_jackpot_data_set");
# 	_rdx_jackpot_data = jackpot_data;
# 	_jackpot_target_id = jackpot_data.keys().front();

# 	ReduxCenter.subscribe(self, "_on_jackpot_state_change",
# 		"gamelogic.jackpot.jackpot_state.%s" % _jackpot_target_id, self);


# # - - - - - - - - - - - - - - - - - - - - -
# # Callback function for the redux subscription jackpot_state
# func _on_jackpot_state_change(jackpot_state):
# 	send_data("hardware/jackpot_display/set_text", {payload={
# 		"alignment": "right",
# 		"text": jp_value.insert(jp_value.length() - 2, '.')
# 	}});


# - - - - - - - - - - - - - - -
# # On Jackpot start callback event
# func _on_feature_jackpot_start(_evt=null):
# 	send_data("hardware/outputs/stop_blink_pattern", {payload={group="draw_group"}});
# 	send_data("hardware/outputs/start_blink_pattern", {payload={"group": "jackpot_group", "id": "test_pattern"}});


# - - - - - - - - - - - - - - -
# On Jackpot end callback event
# func _on_feature_jackpot_end(_evt=null):
# 	send_data("hardware/outputs/stop_blink_pattern", {payload={group="jackpot_group"}});
# 	send_data("hardware/outputs/start_blink_pattern", {payload={"group": "draw_group", "id": "test_pattern"}});


# # - - - - - - - - - - - - - - - - - - - - -
# func _on_animate_last_prizes(_evt=null):
# 	send_data("hardware/led_strips/set_pattern", {payload="second_example"});

# 	send_data("hardware/outputs/stop_blink_pattern", {payload={group="idle_group"}});
# 	send_data("hardware/outputs/start_blink_pattern", {payload={
# 		"group": "draw_group", "id": "test_pattern" }});


# # - - - - - - - - - - - - - - - - - - - - -
# func _on_prize_animation_completed(_evt=null):
# 	send_data("hardware/led_strips/set_pattern", {payload="first_example"});

# 	match (_rdx_gamelogic.state.current):
# 		"draw_balls":
# 			send_data("hardware/outputs/start_blink_pattern", {payload={"group": "idle_group",	"id": "test_pattern" }});

# 		_:
# 			send_data("hardware/outputs/stop_blink_pattern", {payload={group="draw_group"}});


# - - - - - - - - - - - - - - - - - - - - -
# Callback function for the play button
func _on_play_state_change(payload: Dictionary):

	print(JSON.stringify(payload, "\t"));
# 	if(payload.data.input_state == "active"):
# 		EventCenter.emit("evt_key_space", self);


# - - - - - - - - - - - - - - - - - - - - -
# Callback function for the betmore button
# func _on_bet_more_state_change(payload: Dictionary):
# 	if(payload.data.input_state == "active"):
# 		if(["end_game", "idle"].has(_rdx_gamelogic.state.current)):
# 			EventCenter.emit("evt_btn_increase_bet_level", self);


# - - - - - - - - - - - - - - - - - - - - -
# Callback function for the autoplay button
# func _on_auto_state_change(payload: Dictionary):
# 	if(payload.data.input_state == "active"):
# 		var current_panel_state = _rdx_gamelogic.menus.stacked.values().back();
# 		if ([StackedMenuController.State.OPEN].has(current_panel_state.state)):
# 			EventCenter.emit("evt_btn_stacked_menu_trigger", self,
# 				{"menu": current_panel_state.panel, "state": StackedMenuController.State.REQUEST_CLOSE});
# 		elif([StackedMenuController.State.CLOSED].has(current_panel_state.state)):
# 			EventCenter.emit("evt_btn_stacked_menu_trigger", self,
# 				{"menu": current_panel_state.panel, "state": StackedMenuController.State.REQUEST_OPEN});
