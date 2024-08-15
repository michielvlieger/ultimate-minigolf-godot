extends CanvasLayer
class_name UIManager

@onready var score_board = $ScoreBoard
@onready var item_selection_ui = $ItemSelectionUI
@export var submit_button: Button
@export var spectating_control: PanelContainer

var panel_was_open = null

func _input(event):
	if event.is_action_pressed("open_scoreboard"):
		interchange_visibility(score_board,true)
	if event.is_action_released("open_scoreboard"):
		interchange_visibility(score_board,false)

@rpc("any_peer","call_local","reliable")
func change_visibility_item_selection_ui(fis_visible:bool):
	item_selection_ui.visible=fis_visible
	spectating_control.visible = false

func interchange_visibility(panel:PanelContainer, to_bool:bool):
	if to_bool:
		panel.visible = true
		if item_selection_ui.visible:
			item_selection_ui.visible = false
			panel_was_open = item_selection_ui
	else:
		panel.visible = false
		if panel_was_open:
			panel_was_open.visible=true

func _on_menu_button_pressed():
	interchange_visibility(score_board,!score_board.visible)
