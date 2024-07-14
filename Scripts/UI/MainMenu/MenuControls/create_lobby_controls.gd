extends MenuControl

@export var user_name_edit:LineEdit

func _on_create_lobby_pressed():
	if user_name_edit.text.is_empty():
		#give feedback that username has to be filled
		return
	LobbyManager.player_info["username"] = user_name_edit.text
	LobbyManager.create_game()
	SceneManager.goto_scene("res://Scenes/lobby.tscn")
