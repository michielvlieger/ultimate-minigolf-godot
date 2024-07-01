extends CanvasLayer

@onready var grid_container = $Panel/MarginContainer/VBoxContainer/GridContainer
@onready var game_manager = $"../GameManager"

func _ready():
	grid_container.columns = game_manager.game_data.number_of_rounds+1
	add_label_to_grid_container("Games")
	for game_number in game_manager.game_data.number_of_rounds:
		add_label_to_grid_container(str(game_number+1))

@rpc("any_peer", "call_local", "reliable")
func add_player(player_name = 'test'):
	if get_tree().get_nodes_in_group(player_name).size() > 0:
		return
	add_label_to_grid_container(player_name)
	for game_number in game_manager.game_data.number_of_rounds:
		add_label_to_grid_container(str(0), player_name)
		
func add_label_to_grid_container(label_text:String, group= null):
	var label = Label.new()
	label.set_text(label_text)
	if group:
		label.add_to_group(group)
	grid_container.add_child(label)

@rpc("any_peer", "call_local", "reliable")
func change_score(player:Ball, to_amount: int):
	print(player)
	print(to_amount)
	var score_nodes = get_tree().get_nodes_in_group(player.player_data.name)
	var score_node = score_nodes[game_manager.game_data.current_round-1] as Label
	score_node.set_text(str(to_amount))
