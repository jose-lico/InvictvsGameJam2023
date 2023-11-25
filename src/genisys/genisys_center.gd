extends Node
class_name GenisysCenter


const SERVICE_PREFIX: String = "service::";

# - - - - - - - - - - - - - - - - - - - - -
# Values
var protocol_version: String = "v1"
var use_wss: bool = false;
var server_address: String = "localhost";
var server_port: String = "3333";
var led_pattern_json_path: String = "";
var blink_pattern_json_path: String = "";


var client_websocket: WebSocketPeer = null;
var server_url: String;
var skt_is_connected: bool = false;
var should_ignore_requests: bool = false;

var _id_binds: Dictionary;
# Led pattern dictionary
var _ledpatterns_data: Dictionary;
var _blinkpatterns_data: Dictionary;

# ==================== ====================
# Godot Override
# ==================== ====================


# - - - - - - - - - - - - - - - - - - - - -
func _boot_controller():
	_id_binds =  {all={},input={}};

	set_process(false);
	_generate_url();

	if(!led_pattern_json_path.is_empty()):
		_ledpatterns_data = load_json_data(led_pattern_json_path);

	if(!blink_pattern_json_path.is_empty()):
		_blinkpatterns_data = load_json_data(blink_pattern_json_path);



# - - - - - - - - - - - - - - - - - - - - -
func _ready():
		client_websocket = WebSocketPeer.new();
		# client_websocket.set_supported_protocols(["lws-mirror-protocol "]);
		bind_id_to_callback("hardware/inputs/status_change", Callable(self, "_on_input_change"));
		register();
		_connect_socket();


# - - - - - - - - - - - - - - - - - - - - -
func _process(_delta):
	if( client_websocket != null):
		client_websocket.poll();

		var socket_State = client_websocket.get_ready_state();
		match socket_State:
			# Connecting to
			WebSocketPeer.STATE_CONNECTING:
				print("Connecting to server...");

			# During a connected socket state
			WebSocketPeer.STATE_OPEN:
				if(!self.skt_is_connected):
					_on_connection_established();
				else:
					while (client_websocket.get_available_packet_count()):
						_on_data_received(client_websocket.get_packet());

			# Closing connection
			WebSocketPeer.STATE_CLOSING:
				print("Closing connection...");


			WebSocketPeer.STATE_CLOSED:
				_on_server_close_request(client_websocket.get_close_code(), client_websocket.get_close_reason());
				set_process(false);

# ==================== ====================
# Public
# ==================== ====================


# - - - - - - - - - - - - - - - - - - - - -
# Binds a response id to a callback function
func bind_id_to_callback(id: String, callback: Callable):
	if(_id_binds.all.has(id)):
		_id_binds.all[id].append(callback);
	else:
		_id_binds.all[id] = [callback];


# - - - - - - - - - - - - - - - - - - - - -
func bind_input_to_callback(id:String, callback: Callable):
	if(_id_binds.input.has(id)):
		_id_binds.input[id].append(callback);
	else:
		_id_binds.input[id] = [callback];


# - - - - - - - - - - - - - - - - - - - - -
# 
func send_data(id: String, payload: Dictionary = {}):
	if(skt_is_connected):
		var packed: Dictionary = {"id": "%s/%s" % [protocol_version, id] };
		packed.merge(payload, true);
		
		print("-> %s" % id);
		var error = client_websocket.send_text(JSON.stringify(packed));
		if(error != OK):
			print_debug("Failed to send package. Code [%s]" % error);



# ==================== ====================
# Protected
# ==================== ====================


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called before connect to the socket
func register():
	print_debug("No Implementation Exception");


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called after connection established
func connection_established():
	print_debug("No Implementation Exception");


# - - - - - - - - - - - - - - - - - - - - -
# Override this function
# Called before exiting the tree
func on_destroy():
	print_debug("No Implementation Exception");


# ==================== ====================
# Private
# ==================== ====================

# - - - - - - - - - - - - - - - - - - - - -
# Creates the connection url
func _generate_url():
	server_url = "ws";
	if(use_wss):
		server_url += "s";
	server_url+= "://%s:%s" % [server_address, server_port];


# - - - - - - - - - - - - - - - - - - - - -
# Loads and parses a json file by path
func load_json_data(path)-> Dictionary:
	var data: Dictionary = Dictionary();
	if(FileAccess.file_exists(path)):
		var file = FileAccess.open(path, FileAccess.READ);
		var str_data: String = file.get_as_text();

		var json_file: JSON = JSON.new();
		var er = json_file.parse(str_data);
		if(er == OK):
			data = json_file.data;
	
	return data;



# - - - - - - - - - - - - - - - - - - - - -
# Creates the websocket signal connections and process the connect to url 
func _connect_socket():
	var error = client_websocket.connect_to_url(server_url);
	if(error != OK):
		print_debug("Failed to connect with error %s" % error);
		return;
	
	# is_connected = true;
	set_process(true);


# - - - - - - - - - - - - - - - - - - - - -
# Disconnect the connected socket
func _disconnect_socket():
	if(skt_is_connected):
		client_websocket.close(1002, "closing game");


# - - - - - - - - - - - - - - - - - - - - -
# Emitted when the connection to the server is closed.
# was_clean_close will be true if the connection was shutdown cleanly.
func _on_closed(was_clean_close: bool):
	print("Connection closed. [Clear: %s]" % was_clean_close);
	
	skt_is_connected = false;
	set_process(skt_is_connected);


# - - - - - - - - - - - - - - - - - - - - -
# Emitted when the server requests a clean close. 
# You should keep polling until you get a connection_closed signal to achieve the clean close. 
func _on_server_close_request(code: int, reason: String):
	print("Server requested a close connection with code [%s]\n%s" % [str(code), reason]);


# - - - - - - - - - - - - - - - - - - - - -
# Emitted when the connection to the server fails.
func _on_connection_error():
	print("An error occurred, continuing...");



# - - - - - - - - - - - - - - - - - - - - -
# Emitted when a connection with the server is established, protocol will contain the sub-protocol agreed with the server.
func _on_connection_established():
	print("Connected to [%s:%s]" %  [server_address, server_port]);
	skt_is_connected = true;
	connection_established();


# - - - - - - - - - - - - - - - - - - - - -
# Emitted when a WebSocket message is received.
func _on_data_received(data: PackedByteArray ):
	var parsed_data: Dictionary = JSON.parse_string(data.get_string_from_utf8());
	# print(JSON.stringify(parsed_data, "\t"));

	if(parsed_data.has("id")):
		var data_id: String = parsed_data.id;
		print("<- %s" % data_id);

		if(SERVICE_PREFIX in data_id):
			data_id = data_id.substr(SERVICE_PREFIX.length());
			_dispatch_response(data_id, parsed_data.payload);


# - - - - - - - - - - - - - - - - - - - - -
# Calls the subscription callback function with the recieved payload
func _dispatch_response(id: String, payload: Dictionary):
	if(_id_binds.all.has(id)):
		for callback in _id_binds.all[id]:
			(callback as Callable).call(payload);


# - - - - - - - - - - - - - - - - - - - - -
# Callback for a input status_change response
func _on_input_change(payload:Dictionary):
	if(payload.has("data") && payload.data.has("name")):
		if(_id_binds.input.has(payload.data.name)):
			for callback in _id_binds.input[payload.data.name]:
				(callback as Callable).call(payload);


# - - - - - - - - - - - - - - - - - - - - -
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			on_destroy();
			call_deferred("_disconnect_socket");
