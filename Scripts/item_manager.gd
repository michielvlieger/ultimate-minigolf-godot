extends Node2D
class_name ItemManager

const ITEM_SELECT = preload("res://Scenes/item_select.tscn")

@onready var tile_map = $"../TileMap"
@onready var game_manager = $"../GameManager"
@onready var player_manager = $"../PlayerManager"

@export var item_list_select:ItemList

# dictionary with all possible items with scene tile id
#	{
#	scene_tile_id : item
#	}
var possible_items: Dictionary
# dictionary to safe the users selected items
#	{ 
#	round_number : {
#		 peer_id : selected_item
#		}
#	}
var selected_items: Dictionary

func _ready():
	var itemscene_collection = tile_map.tile_set.get_source(1) as TileSetScenesCollectionSource
	for i in itemscene_collection.get_scene_tiles_count():
		var item_scene_tile_id = itemscene_collection.get_scene_tile_id(i)
		var item_scene = itemscene_collection.get_scene_tile_scene(item_scene_tile_id).instantiate()
		possible_items[item_scene_tile_id] = item_scene
		add_item_to_selection_ui(item_scene)
	
	item_list_select.item_selected.connect(_on_item_selected)

func _on_item_selected(index:int):
	add_item_to_selected_items.rpc(index)
	
	#if all players have selected go to item placing state
	var all_players_have_selected = true
	for player in player_manager.get_children():
		if !selected_items[game_manager.current_round].has(int(str(player.name))):
			all_players_have_selected = false
	if all_players_have_selected:
		game_manager.on_child_transition.rpc("itemplacingstate")
	
	#make item disabled in other players item list select (maybe display who chose what)

@rpc("any_peer","call_local","reliable")
func add_item_to_selected_items(index):
	var selected_item_text = item_list_select.get_item_text(index)
	var selected_item = null
	for item in possible_items.values():
		if item.name == selected_item_text:
			selected_item = item
	
	if !selected_item:
		return
	
	if !selected_items.has(game_manager.current_round):
		selected_items[game_manager.current_round] = {}
	selected_items[game_manager.current_round][multiplayer.get_remote_sender_id()] = selected_item
	
func spawn_selected_items():
	pass

func add_item_to_selection_ui(item):
	#var item_select = ITEM_SELECT.instantiate()
	#item_select.set_data.rpc(thumb_nail_image,item.name)
	var thumb_nail_texture = item.get_node("ThumbNail").texture	
	item_list_select.add_item(item.name,thumb_nail_texture)

@rpc("any_peer","call_local","reliable")
func reset_item_list_selection():
	item_list_select.deselect_all()
