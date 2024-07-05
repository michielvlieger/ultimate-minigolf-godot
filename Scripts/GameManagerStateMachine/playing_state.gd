extends State
class_name PlayingState

@onready var game_manager = $".."
@onready var player_manager = $"../../PlayerManager"

func player_scored():
	var all_players_finished = true
	var players = get_children()
	for player in players:
		if !player.is_finished:
			all_players_finished = false
	
	if all_players_finished:
		all_players_scored()

@rpc("any_peer","call_local","reliable")
func next_round():
	game_manager.current_round += 1
	transitioned.emit("itemselectionstate")

@rpc("any_peer","call_local","reliable")
func finish_game():
	pass

func all_players_scored():
	if game_manager.current_round == game_manager.number_of_rounds:
		finish_game.rpc()
	else:
		next_round.rpc()
