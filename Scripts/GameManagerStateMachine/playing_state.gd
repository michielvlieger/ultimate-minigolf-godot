extends State
class_name PlayingState

@export var game_manager:GameManager
@export var player_manager:PlayerManager
@export var level_camera:Camera2D
@export var tile_map: TileMap

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
	var players = player_manager.get_children()
	for player in players:
		if !player.is_finished:
			all_players_finished = false
	
	if all_players_finished:
		all_players_scored()

@rpc("any_peer","call_local","reliable")
func next_round():
	game_manager.current_round += 1
	transitioned.emit("itemselectionstate")
	level_camera.make_current()
	deactivate_items.rpc()

@rpc("any_peer","call_local","reliable")
func finish_game():
	pass

func all_players_scored():
	if game_manager.current_round == game_manager.number_of_rounds:
		finish_game.rpc()
	else:
		next_round.rpc()
