extends State
class_name ItemSelectionState

@export var ui_manager: UIManager
@export var item_manager: ItemManager

func enter():
	ui_manager.change_visibility_item_selection_ui(true)
	item_manager.reset_item_list_selection.rpc()
	
func exit():
	ui_manager.change_visibility_item_selection_ui(false)
