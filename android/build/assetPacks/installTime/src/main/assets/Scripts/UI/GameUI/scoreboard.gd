extends Control

@onready var grid_container = $MarginContainer/VBoxContainer/GridContainer
@onready var back_to_lobby_button = $MarginContainer/VBoxContainer/HBoxContainer/BackToLobbyButton

func _ready():
	if multiplayer.get_unique_id() == LobbyManager.lobby_info["host_id"]:
		back_to_lobby_button.visible = true
	grid_container.columns = LobbyManager.lobby_info["number_of_rounds"]+1
	add_label_to_grid_container("Games")
	for game_number in LobbyManager.lobby_info["number_of_rounds"]:
		add_label_to_grid_container(str(game_number+1))

@rpc("any_peer", "call_local", "reliable")
func add_player(player_name, player_id):
	if get_tree().get_nodes_in_group(player_name).size() > 0:
		return
	add_label_to_grid_container(player_name, str(player_id))
	for game_number in LobbyManager.lobby_info["number_of_rounds"]:
		add_label_to_grid_container(str(0), str(player_id))

@rpc("any_peer", "call_local", "reliable")
func remove_player(player_id):
	for label in get_tree().get_nodes_in_group(str(player_id)):
		label.queue_free()

func add_label_to_grid_container(label_text:String, group= null):
	var label = Label.new()
	label.set_text(label_text)
	if group:
		label.add_to_group(group)
	grid_container.add_child(label)

@rpc("any_peer", "call_local", "reliable")
func change_score(new_scores, peer_id):
	var score_nodes = get_tree().get_nodes_in_group(str(peer_id))
	for i in score_nodes.size()-1:
		score_nodes[i+1].set_text(str(new_scores[i]))

func _on_leave_lobby_button_pressed():
	LobbyManager.leave_lobby()
	SceneManager.goto_scene("res://Scenes/UI/main_menu.tscn")

func _on_back_to_lobby_button_pressed():
	send_everyone_to_lobby.rpc()

@rpc("any_peer", "call_local", "reliable")
func send_everyone_to_lobby():
	SceneManager.goto_scene("res://Scenes/UI/lobby.tscn")
