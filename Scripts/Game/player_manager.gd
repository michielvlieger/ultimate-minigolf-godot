extends Node2D
class_name PlayerManager

@onready var score_board = $"../ScoreBoard"
@onready var game_manager = $"../GameManager"

const BALL = preload("res://Scenes/ball.tscn")

var peer = ENetMultiplayerPeer.new()

func _ready():
	print(multiplayer.get_unique_id())
	call_deferred("_add_player",multiplayer.get_unique_id())
	#_add_player(multiplayer.get_unique_id())

func _add_player(id = 1):
	var player = BALL.instantiate()
	player.set_data(id, str(id), game_manager.number_of_rounds, position)
	player.name = str(id)
	player.scored.connect(_on_player_scored.bind())
	player.score_change.connect(_on_player_score_change.bind(player))
	player.shot.connect(_on_player_shot.bind(player))
	call_deferred("add_child", player)
	for fplayer in get_children():
		score_board.add_player.rpc(fplayer.name)
	score_board.add_player.rpc(str(id))	

func _on_player_score_change(player):
	score_board.change_score.rpc(player)

func _on_player_shot(player):
	var new_scores = player.scores
	new_scores[game_manager.current_round-1] += 1
	player.set_scores.rpc(new_scores)
	
func _on_player_scored():
	if game_manager.current_state.name.to_lower() == "playingstate":
		game_manager.states["playingstate"].player_scored()
