extends MenuControl

@export var user_name_edit:LineEdit
@onready var lobby_line_edit = $CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/LobbyLineEdit

func _on_join_lobby_pressed():
	if user_name_edit.text.is_empty():
		#give feedback that username has to be filled
		return
	LobbyManager.player_info["username"] = user_name_edit.text
	LobbyManager.join_game(lobby_line_edit.text)
	SceneManager.goto_scene("res://Scenes/lobby.tscn")
