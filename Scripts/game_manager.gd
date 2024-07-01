extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_spawn: Node2D
@onready var score_board = $"../ScoreBoard"
const BALL = preload("res://Scenes/ball.tscn")
var game_data = GameData.new(18)


func _add_player(id = 1):
	for player in player_spawn.get_children():
		score_board.add_player.rpc(player.name)
	var player = BALL.instantiate()
	player.set_data(id, str(id), game_data.number_of_rounds)
	player.name = str(id)
	player.scored.connect(_on_player_scored.bind(player))
	player.shot.connect(_on_player_shot.bind(player))
	player_spawn.call_deferred("add_child", player)
	score_board.add_player.rpc(str(id))	

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _on_join_pressed():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer

func _input(event):
	if event.is_action_pressed("open_scoreboard"):
		score_board.visible = true

	if event.is_action_released("open_scoreboard"):
		score_board.visible = false

func _on_player_scored(player:Ball):
	player.visible = false

func _on_player_shot(player:Ball):
	var current_score = player.player_data.scores[game_data.current_round]
	var new_score = current_score+1
	player.player_data.scores[game_data.current_round] = new_score
	score_board.change_score.rpc(player, new_score)
