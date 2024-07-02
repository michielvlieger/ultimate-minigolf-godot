extends Node2D

@onready var score_board = $"../ScoreBoard"
@onready var multiplayer_synchronizer = $"../MultiplayerSynchronizer"
const BALL = preload("res://Scenes/ball.tscn")

var peer = ENetMultiplayerPeer.new()

@export var player_spawn: Node2D
@export var current_round: int = 1
@export var number_of_rounds: int = 18

func _add_player(id = 1):
	var player = BALL.instantiate()
	player.set_data(id, str(id), number_of_rounds)
	player.name = str(id)
	player.scored.connect(_on_player_scored.bind())
	player.score_change.connect(_on_player_score_change.bind(player))
	player.shot.connect(_on_player_shot.bind(player))
	player_spawn.call_deferred("add_child", player)
	for fplayer in player_spawn.get_children():
		score_board.add_player.rpc(fplayer.name)
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

func _on_player_scored():
	var all_players_finished = true
	var players = player_spawn.get_children()
	for player in players:
		if !player.is_finished:
			all_players_finished = false
	
	if all_players_finished:
		for player in players:
			player.reset.emit(Vector2(0,0))

func _on_player_score_change(player):
	score_board.change_score.rpc(player)

func _on_player_shot(player):
	var new_scores = player.scores
	new_scores[current_round-1] += 1
	player.set_scores.rpc(new_scores)
