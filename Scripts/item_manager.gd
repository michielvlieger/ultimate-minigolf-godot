extends Node2D
class_name ItemManager

const ITEM_SELECT = preload("res://Scenes/item_select.tscn")

@onready var tile_map = $"../TileMap"
@onready var item_list_select = $ItemSelectionUI/Panel/MarginContainer/VBoxContainer/ItemList

var item_list:Array
# dictionary to safe the users selected items
#	{ 
#	round_number : {
#		 player_name : selected_item
#		}
#	}
var selectedItems: Dictionary

func _ready():
	var itemscene_collection = tile_map.tile_set.get_source(1) as TileSetScenesCollectionSource
	for i in itemscene_collection.get_scene_tiles_count():
		var item_scene_tile_id = itemscene_collection.get_scene_tile_id(i)
		var item_scene = itemscene_collection.get_scene_tile_scene(item_scene_tile_id).instantiate()
		item_list.append(item_scene)
		add_item_to_selection_ui(item_scene)

func spawn_selected_items():
	pass

func add_item_to_selection_ui(item):
	#var item_select = ITEM_SELECT.instantiate()
	var thumb_nail_texture = item.get_node("ThumbNail").texture
	print(thumb_nail_texture)
	print(item.name)
	#item_select.set_data.rpc(thumb_nail_image,item.name)
	item_list_select.add_item(item.name,thumb_nail_texture)
