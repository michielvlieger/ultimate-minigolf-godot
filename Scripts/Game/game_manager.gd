extends StateMachine
class_name GameManager

@onready var player_manager = $"../PlayerManager"

var current_round: int = 1
@export var number_of_rounds: int = 18

func _ready():
	if !is_multiplayer_authority():
		return
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	
	LobbyManager.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

func start_game():
	print("starting game")
