extends State
class_name ItemPlacingState

@onready var player_manager = $"../../PlayerManager"
@onready var tile_map = $"../../TileMap"
@onready var item_manager = $"../../ItemManager"
@onready var game_manager = $".."

var placeholder_map_pos:Vector2i
var has_selected_pos:bool = false

func enter():
	has_selected_pos = false

func input(event):
	print(has_selected_pos)
	if has_selected_pos:
		return
	var map_pos = tile_map.local_to_map(get_local_mouse_position())
	#if mouse is not over tilemap with course	
	if tile_map.get_cell_atlas_coords(2, map_pos) == Vector2i(-1,-1):
		return
	#if already a tile in cell
	if tile_map.get_cell_alternative_tile(0, map_pos) > 0:
		return
	if event is InputEventMouseMotion:
		if map_pos == placeholder_map_pos:
			return
		
		if placeholder_map_pos:
			remove_placeholder_item.rpc(placeholder_map_pos)
		
		placeholder_map_pos = map_pos
		display_placeholder_item.rpc(map_pos)
	if event.is_action_pressed("click"):
		has_selected_pos = true
		print("clicked")

@rpc("any_peer","call_local","reliable")
func display_placeholder_item(map_pos:Vector2i):
	var item_to_display = item_manager.selected_items[game_manager.current_round][multiplayer.get_remote_sender_id()]
	var scene_tile_id = item_manager.possible_items.find_key(item_to_display)
	tile_map.set_cell(0,map_pos,1,Vector2i.ZERO, scene_tile_id)
	
@rpc("any_peer","call_local","reliable")
func remove_placeholder_item(map_pos:Vector2i):
	tile_map.erase_cell(0,map_pos)
