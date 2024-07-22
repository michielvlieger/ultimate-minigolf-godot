extends Node2D
class_name PlayerManager

@onready var score_board = $"../ScoreBoard"
@onready var game_manager = $"../GameManager"
@onready var main = $".."

const BALL = preload("res://Scenes/ball.tscn")

var peer = ENetMultiplayerPeer.new()

func _ready():
	main.set_multiplayer_authority(LobbyManager.lobby_info["host_id"])
	game_manager.set_multiplayer_authority(multiplayer.get_unique_id())
	if multiplayer.get_unique_id() == LobbyManager.lobby_info["host_id"]:
		for player_id in LobbyManager.players:
			call_deferred("_add_player",int(player_id))

func _add_player(id = 1):
	var player = BALL.instantiate()
	player.set_multiplayer_authority(id)
	var player_name = LobbyManager.players[str(id)]["username"]
	player.set_data(id, player_name, game_manager.number_of_rounds, position)
	player.name = str(id)
	player.scored.connect(_on_player_scored.bind())
	player.score_change.connect(_on_player_score_change.bind(player))
	player.shot.connect(_on_player_shot.bind(player))
	#player.set_multiplayer_authority(id)
	call_deferred("add_child", player)
	score_board.add_player.rpc(player_name)	

func _on_player_score_change(player):
	score_board.change_score.rpc(player)

func _on_player_shot(player):
	var new_scores = player.scores
	new_scores[game_manager.current_round-1] += 1
	player.set_scores.rpc(new_scores)
	
func _on_player_scored():
	if game_manager.current_state.name.to_lower() == "playingstate":
		game_manager.states["playingstate"].player_scored()

func _exit_tree():
	pass
