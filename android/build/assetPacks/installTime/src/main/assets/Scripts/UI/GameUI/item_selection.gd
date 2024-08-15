extends Control

@onready var item_list = $MarginContainer/VBoxContainer/MarginContainer/ItemList

func add_item_to_selection_ui(item):
	#var item_select = ITEM_SELECT.instantiate()
	#item_select.set_data.rpc(thumb_nail_image,item.name)
	var thumb_nail_texture = item.get_node("ThumbNail").texture
	item_list.add_item(item.name,thumb_nail_texture)

@rpc("any_peer","call_local","reliable")
func reset_item_list_selection():
	item_list.deselect_all()
