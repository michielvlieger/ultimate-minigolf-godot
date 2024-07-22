extends CanvasLayer

@onready var grid_container = $Panel/MarginContainer/VBoxContainer/GridContainer

func _ready():
	grid_container.columns = LobbyManager.lobby_info["number_of_rounds"]+1
	add_label_to_grid_container("Games")
	for game_number in LobbyManager.lobby_info["number_of_rounds"]:
		add_label_to_grid_container(str(game_number+1))

@rpc("any_peer", "call_local", "reliable")
func add_player(player_name = 'test'):
	if get_tree().get_nodes_in_group(player_name).size() > 0:
		return
	add_label_to_grid_container(player_name)
	for game_number in LobbyManager.lobby_info["number_of_rounds"]:
		add_label_to_grid_container(str(0), player_name)
		
func add_label_to_grid_container(label_text:String, group= null):
	var label = Label.new()
	label.set_text(label_text)
	if group:
		label.add_to_group(group)
	grid_container.add_child(label)

@rpc("any_peer", "call_local", "reliable")
func change_score(player):
	var score_nodes = get_tree().get_nodes_in_group(player.player_name)
	for i in score_nodes.size():
		score_nodes[i].set_text(str(player.scores[i]))
