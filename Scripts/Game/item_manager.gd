extends Node2D
class_name ItemManager

@onready var tile_map = $"../TileMap"
@onready var player_manager = $"../PlayerManager"
@onready var game_state_machine = $"../GameStateMachine"
@onready var ui_manager = $"../UIManager" as UIManager

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
		print(ui_manager)
		ui_manager.item_selection_ui.add_item_to_selection_ui(item_scene)
	ui_manager.item_selection_ui.item_list.item_selected.connect(_on_item_selected)

func _on_item_selected(index:int):
	add_item_to_selected_items.rpc(index)
	#if all players have selected go to item placing state
	var all_players_have_selected = true
	for player in player_manager.get_children():
		if !selected_items[LobbyManager.lobby_info["current_round"]].has(int(str(player.name))):
			all_players_have_selected = false
	if all_players_have_selected:
		game_state_machine.on_child_transition.rpc("itemplacingstate")
	
	#make item disabled in other players item list select (maybe display who chose what)

@rpc("any_peer","call_local","reliable")
func add_item_to_selected_items(index):
	var selected_item_text = ui_manager.item_selection_ui.item_list.get_item_text(index)
	var selected_item = null
	for item in possible_items.values():
		if item.name == selected_item_text:
			selected_item = item
	
	if !selected_item:
		return
	
	if !selected_items.has(LobbyManager.lobby_info["current_round"]):
		selected_items[LobbyManager.lobby_info["current_round"]] = {}
	selected_items[LobbyManager.lobby_info["current_round"]][multiplayer.get_remote_sender_id()] = selected_item
