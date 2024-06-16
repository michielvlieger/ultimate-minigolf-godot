extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var player_spawn: Node2D

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player_spawn.call_deferred("add_child", player)

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()


func _on_join_pressed():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
