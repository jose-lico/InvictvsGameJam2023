extends Node

# - - - - - - - - - - - - - - - - - - - - -
enum STATES {INTRO, MENU, INTROGAME, GAME, ENDGAME}

# - - - - - - - - - - - - - - - - - - - - -
signal state_changed(state: STATES)

# - - - - - - - - - - - - - - - - - - - - -

var current_state: STATES;
var previous_state: STATES;


# - - - - - - - - - - - - - - - - - - - - -
func _enter_tree():
	current_state = STATES.INTRO;
	previous_state = current_state;



# ==================== ====================
# Public
# ==================== ====================


# - - - - - - - - - - - - - - - - - - - - -
func change_state(target_state: STATES):
	previous_state = current_state;
	current_state = target_state;

	print(" GM -> Change state to %s" % STATES.keys()[current_state]);
	state_changed.emit(current_state);
