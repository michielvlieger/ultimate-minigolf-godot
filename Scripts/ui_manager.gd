extends Node2D
class_name UIManager

@onready var score_board = $"../ScoreBoard"
@export var item_selection_ui:CanvasLayer

func _input(event):
	if event.is_action_pressed("open_scoreboard"):
		score_board.visible = true

	if event.is_action_released("open_scoreboard"):
		score_board.visible = false

@rpc("any_peer","call_local","reliable")
func change_visibility_item_selection_ui(is_visible:bool):
	item_selection_ui.visible=is_visible
