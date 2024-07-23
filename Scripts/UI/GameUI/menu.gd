extends PanelContainer

@onready var ui_manager = $".."

func _on_leave_lobby_button_pressed():
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer)
	SceneManager.goto_scene("res://Scenes/UI/main_menu.tscn")
