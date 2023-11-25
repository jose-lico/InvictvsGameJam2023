extends Node3D

# - - - - - - - - - - - - - - - - - - - - -
# Signal
signal sig_clock_tick(tick: int)
signal sig_light();
signal sig_blackout();
signal sig_flash();
signal sig_stopmoving();

const TIME_HOLD_AFTER_FLASH : float = 1.5;

@export var tick_audio: AudioStreamPlayer;

@export var animation_player_p1: AnimationPlayer;
@export var animation_player_p2: AnimationPlayer;

@export_range(1, 20, 0.2) var tickVolumeIncreaseRate: float


# - - - - - - - - - - - - - - - - - - - - -
# Values
const KTOTAL_TICKS : int = 13;

# Time between ticks
var time_between_ticks: float;
# Total tickks
var total_ticks: int;
# Refers the timer object
var ref_timer: Timer = null;
# Internal counter
var current_tick_count: int;

# ==================== ====================
# Public
# ==================== ====================

# - - - - - - - - - - - - - - - - - - - - -
#
func start_new_timer(interval: float):
	__clear_current_timer__();

	self.time_between_ticks = interval;

	ref_timer.start(time_between_ticks);

	Genisys.send_data("hardware/outputs/start_blink_pattern",
		{payload={"group": "buttons", "id": "ingame_set"}});


# ==================== ====================
# Private
# ==================== ====================

# - - - - - - - - - - - - - - - - - - - - -
# Godot API Override
func _enter_tree():
	GameManager.state_changed.connect(_on_state_change);

	ref_timer = Timer.new();
	add_child(ref_timer);

	ref_timer.set_owner(self);
	ref_timer.set_one_shot(true);
	ref_timer.timeout.connect(__on_timer_timeout__);

	_on_state_change(GameManager.current_state);
	# start_new_timer(1.0);

func _exit_tree():
	GameManager.state_changed.disconnect(_on_state_change);
	queue_free()

func _on_state_change(state: GameManager.STATES):
	match state:
		GameManager.STATES.INTROGAME:
			GameManager.change_state(GameManager.STATES.GAME);


		GameManager.STATES.GAME:
			Genisys.send_data("hardware/outputs/start_blink_pattern",
				{payload={"group": "buttons", "id": "ingame_set"}});
			start_new_timer(1.0);


# - - - - - - - - - - - - - - - - - - - - -
# Clear the timer state
func __clear_current_timer__():
	if(!ref_timer.is_stopped()):
		ref_timer.stop();

	total_ticks = KTOTAL_TICKS;
	time_between_ticks = 0.0;
	current_tick_count = 0;


# - - - - - - - - - - - - - - - - - - - - -
#
func __on_timer_timeout__():
	current_tick_count += 1;
	# print(current_tick_count);

	sig_clock_tick.emit(current_tick_count);

	if(tick_audio != null):
		print(current_tick_count / 11.0)
		tick_audio.set_volume_db(linear_to_db((current_tick_count / 11.0) * tickVolumeIncreaseRate));
		if(current_tick_count < 12):
			tick_audio.play();

	match current_tick_count:
		2: sig_light.emit();
		8: sig_blackout.emit();
		12: sig_stopmoving.emit();
		13: sig_flash.emit();

	if(current_tick_count < total_ticks):
		ref_timer.start(time_between_ticks);
	# else:
	# 	start_new_timer(1.0);


var winnerArray = []
func calcwinner(value):
	winnerArray.push_front(value)

	if (winnerArray.size() == 2 ):
		await get_tree().create_timer(TIME_HOLD_AFTER_FLASH).timeout;

		var totalwinner = winnerArray[0] + winnerArray[1]
		#winner calc!!
		if totalwinner == 2:
			#TIE!
			print("TIE")
			animation_player_p1.play("tie");
			animation_player_p2.play("tie");
			
			GameManager.Go_To_Menu()
			GameManager.state_changed.disconnect(_on_state_change)
			queue_free()
			
		elif totalwinner == 0:
			#MISSED!
			print("BOTH MISSED")
			animation_player_p1.play("miss");
			animation_player_p2.play("miss");
			
			start_new_timer(1.0);
			
		elif winnerArray[0] == 1:
			print("Player 1 won!")
			
			GameManager.Go_To_Menu()
			GameManager.state_changed.disconnect(_on_state_change)
			queue_free()
			
		elif winnerArray[1] == 1:
			print("Player 2 won!")

			GameManager.Go_To_Menu()
			GameManager.state_changed.disconnect(_on_state_change)
			queue_free()

		winnerArray.clear()






func flash():
	Genisys.send_data("hardware/led_strips/set_pattern", {payload="flash"});
	Genisys.send_data("hardware/outputs/start_blink_pattern", {payload={"group": "buttons", "id": "flash"}});
