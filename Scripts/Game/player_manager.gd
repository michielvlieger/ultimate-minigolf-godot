extends Node2D
class_name PlayerManager

@onready var game_state_machine = $"../GameStateMachine"
@onready var main = $".."
@onready var ui_manager = $"../UIManager"

const BALL = preload("res://Scenes/ball.tscn")

var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnect)
	main.set_multiplayer_authority(LobbyManager.lobby_info["host_id"])
	game_state_machine.set_multiplayer_authority(multiplayer.get_unique_id())
	if multiplayer.get_unique_id() == LobbyManager.lobby_info["host_id"]:
		for player_id in LobbyManager.players:
			call_deferred("_add_player",int(player_id))

func _add_player(id):
	var player = BALL.instantiate()
	player.set_multiplayer_authority(id)
	var player_name = LobbyManager.players[str(id)]["username"]
	player.set_data(id, player_name, LobbyManager.lobby_info["number_of_rounds"], position)
	player.name = str(id)
	player.scored.connect(_on_player_scored.bind())
	player.score_change.connect(_on_player_score_change.bind(player))
	player.shot.connect(_on_player_shot.bind(player))
	call_deferred("add_child", player)
	ui_manager.score_board.add_player.rpc(player_name, id)	

func _on_player_score_change(player):
	ui_manager.score_board.change_score.rpc(player)

func _on_player_shot(player):
	var new_scores = player.scores
	new_scores[LobbyManager.lobby_info["current_round"]-1] += 1
	player.set_scores.rpc(new_scores)
	
func _on_player_scored():
	if game_state_machine.current_state.name.to_lower() == "playingstate":
		game_state_machine.states["playingstate"].player_scored()

func _on_player_disconnect(peer_id):
	get_node(str(peer_id)).queue_free()
	ui_manager.score_board.remove_player.rpc(peer_id)	
