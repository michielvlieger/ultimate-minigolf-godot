extends State
class_name ItemPlacingState

@export var player_manager:PlayerManager
@export var tile_map:TileMap
@export var item_manager:ItemManager
@export var game_manager:GameManager

var placeholder_map_pos:Vector2i
var has_placed:bool = false
var users_placed = []

func enter():
	has_placed = false
	add_user_to_users_placed.rpc_id(1)

func exit():
	multiplayer.get_unique_id()
	for player in player_manager.get_children():
		if player.name == str(multiplayer.get_unique_id()):
			player.reset.emit(player_manager.position)

func resetting_players():
	pass

func input(event):
	if has_placed:
		return
	var map_pos = tile_map.local_to_map(get_local_mouse_position())
	#if mouse is not over tilemap with course	
	if tile_map.get_cell_atlas_coords(3, map_pos) == Vector2i(-1,-1):
		return
	#if already a tile in cell
	if tile_map.get_cell_alternative_tile(0, map_pos) > 0:
		return
	if event is InputEventMouseMotion:
		if map_pos == placeholder_map_pos:
			return
		
		if placeholder_map_pos:
			remove_item.rpc(placeholder_map_pos,1)
		
		placeholder_map_pos = map_pos
		place_item.rpc(map_pos,1)
	if event.is_action_pressed("click"):
		remove_item.rpc(map_pos,1)
		place_item.rpc(map_pos,0)
		has_placed = true
		check_start_round.rpc_id(1)

@rpc("any_peer","call_local","reliable")
func place_item(map_pos:Vector2i, layer_id: int):
	var item_to_display = item_manager.selected_items[game_manager.current_round][multiplayer.get_remote_sender_id()]
	var scene_tile_id = item_manager.possible_items.find_key(item_to_display)
	tile_map.set_cell(layer_id,map_pos,1,Vector2i.ZERO, scene_tile_id)
	
@rpc("any_peer","call_local","reliable")
func remove_item(map_pos:Vector2i, layer_id: int):
	tile_map.erase_cell(layer_id,map_pos)

@rpc("any_peer","call_local","reliable")
func check_start_round():
	users_placed.erase(multiplayer.get_remote_sender_id())
	if users_placed.is_empty():
		transitioned.emit("playingstate")

@rpc("any_peer","call_local","reliable")
func add_user_to_users_placed():
	users_placed.append(multiplayer.get_remote_sender_id())
