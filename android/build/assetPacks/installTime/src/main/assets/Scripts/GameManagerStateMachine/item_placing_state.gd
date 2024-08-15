extends State
class_name ItemPlacingState

@export var player_manager:PlayerManager
@export var tile_map:TileMap
@export var item_manager:ItemManager
@export var ui_manager: UIManager
@export var tile_map_visible_grid: Node2D

var placeholder_map_pos:Vector2i
var has_placed:bool = false
var users_placed = []

func _ready():
	ui_manager.submit_button.pressed.connect(submit_placement)

func enter():
	has_placed = false
	add_user_to_users_placed.rpc()
	tile_map_visible_grid.visible = true

func exit():
	resetting_player.rpc()
	tile_map_visible_grid.visible = false

@rpc("any_peer","call_local","reliable")
func resetting_player():
	for player in player_manager.get_children():
		if player.name == str(multiplayer.get_unique_id()):
			player.reset.emit(player_manager.position)
			player.set_camera_to_player(player)

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
	#if spawn or hole in cell
	if tile_map.get_cell_alternative_tile(2, map_pos) > 0:
		return
	
	if OS.get_name() in ["Android", "iOS"] and event.is_action_pressed("click"):
		if map_pos == placeholder_map_pos:
			return
			
		if placeholder_map_pos:
			remove_item.rpc(placeholder_map_pos,1)
		
		placeholder_map_pos = map_pos
		place_item.rpc(map_pos,1)
		
		#show submit button
		ui_manager.submit_button.visible = true
	else:
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
			check_start_round.rpc()

@rpc("any_peer","call_local","reliable")
func place_item(map_pos:Vector2i, layer_id: int):
	var item_to_display = item_manager.selected_items[LobbyManager.lobby_info["current_round"]][multiplayer.get_remote_sender_id()]
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

func submit_placement():
	remove_item.rpc(placeholder_map_pos,1)
	place_item.rpc(placeholder_map_pos,0)
	has_placed = true
	check_start_round.rpc()
	ui_manager.submit_button.visible = false
