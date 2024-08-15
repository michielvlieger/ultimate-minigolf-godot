extends State
class_name PlayingState

@export var player_manager:PlayerManager
@export var level_camera:Camera2D
@export var tile_map: TileMap
@export var ui_manager: UIManager

func enter():
	await get_tree().create_timer(1).timeout
	activate_items.rpc()

@rpc("any_peer","call_local","reliable")
func activate_items():
	for child in tile_map.get_children():
		if child is Item:
			child.activate_item()

@rpc("any_peer","call_local","reliable")
func deactivate_items():
	for child in tile_map.get_children():
		if child is Item:
			child.deactivate_item()

func player_scored():
	var all_players_finished = true
	for player in player_manager.get_children():
		if !player.is_finished:
			all_players_finished = false
	
	if all_players_finished:
		all_players_scored()

@rpc("any_peer","call_local","reliable")
func next_round():
	LobbyManager.lobby_info["current_round"] += 1
	transitioned.emit("itemselectionstate")
	level_camera.make_current()
	deactivate_items.rpc()

@rpc("any_peer","call_local","reliable")
func finish_game():
	ui_manager.score_board.visible = true
	await get_tree().create_timer(10.0).timeout
	SceneManager.goto_scene("res://Scenes/UI/lobby.tscn")
	queue_free()

func all_players_scored():
	if LobbyManager.lobby_info["current_round"] == LobbyManager.lobby_info["number_of_rounds"]:
		finish_game.rpc()
	else:
		next_round.rpc()
