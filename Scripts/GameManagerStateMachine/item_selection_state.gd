extends State
class_name ItemSelectionState

@onready var ui_manager = $"../../UIManager"

func enter():
	ui_manager.change_visibility_item_selection_ui(true)
	
func exit():
	ui_manager.change_visibility_item_selection_ui(false)

