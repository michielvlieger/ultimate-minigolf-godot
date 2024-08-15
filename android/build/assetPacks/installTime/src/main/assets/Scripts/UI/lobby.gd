extends Control

@onready var players_grid_container = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var start_game_button = $PanelContainer/MarginContainer/VBoxContainer/StartGameButton
@onready var lobby_label = $PanelContainer/MarginContainer/VBoxContainer/Label

@onready var username_label = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/UsernameLabel
@onready var ball_color = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorRect
@onready var ball_color_button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorPickerButton
@onready var remove_player_button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/TextureButton
@onready var is_ready_check_box = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/CheckBox
@onready var column_name_4 = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColumnName4

func _ready():
	LobbyManager.player_connected.connect(_on_player_connect)
	LobbyManager.player_disconnected.connect(_on_player_disconnected)
	LobbyManager.player_info_changed.connect(_on_player_info_changed)
	if multiplayer.get_unique_id() == LobbyManager.lobby_info["host_id"]:
		start_game_button.visible=true
	else:
		players_grid_container.columns = 3
		column_name_4.visible = false
	
	for player in LobbyManager.players.values():
		add_player_to_grid(player)
	
	lobby_label.text = "Lobby: " + LobbyManager.lobby_info["lobby_id"]

func add_player_to_grid(player):
	var new_ball_color
	var new_is_ready_check_box = is_ready_check_box.duplicate() as CheckBox
	var new_label = username_label.duplicate() as Label
	
	new_label.text = player["username"]

	if player["id"] == multiplayer.get_unique_id():
		new_ball_color = get_dup_ball_color_button()
		new_ball_color.popup_closed.connect(_on_change_color.bind(new_ball_color))
		new_ball_color.color = player["ball_color"]
		
		new_is_ready_check_box.disabled = false
		new_is_ready_check_box.button_pressed = player["is_ready"]
		new_is_ready_check_box.toggled.connect(_on_toggle_is_ready)
	else:
		new_ball_color = ball_color.duplicate()
		new_ball_color.color = player["ball_color"]
	
	new_label.visible = true
	new_ball_color.visible = true
	new_is_ready_check_box.visible = true
	
	new_label.add_to_group(str(player["id"]))
	new_ball_color.add_to_group(str(player["id"]))
	new_is_ready_check_box.add_to_group(str(player["id"]))
	
	players_grid_container.add_child(new_label)
	players_grid_container.add_child(new_ball_color)
	players_grid_container.add_child(new_is_ready_check_box)
	
	if multiplayer.get_unique_id() == LobbyManager.lobby_info["host_id"]:
		start_game_button.visible=true
		var new_remove_player_button = remove_player_button.duplicate()
		new_remove_player_button.visible = true
		new_remove_player_button.add_to_group(str(player["id"]))
		new_remove_player_button.pressed.connect(_on_remove_player_button_pressed.bind(player["id"]))
		if player["id"] == LobbyManager.lobby_info["host_id"]:
			new_remove_player_button.disabled = true
		players_grid_container.add_child(new_remove_player_button)

func update_player_info(peer_id):
	var player_info = LobbyManager.players[str(peer_id)]
	for child in players_grid_container.get_children():
		if child.is_in_group(str(peer_id)):
			if child is ColorRect:
				child.color = player_info["ball_color"]
			if child is CheckBox:
				child.button_pressed = player_info["is_ready"]

func get_dup_ball_color_button() -> ColorPickerButton:
	var dup_ball_color_button = ball_color_button.duplicate()
	var picker = dup_ball_color_button.get_picker() as ColorPicker
	picker.edit_alpha = false
	picker.can_add_swatches = false
	picker.color_modes_visible = false
	picker.hex_visible = false
	picker.presets_visible = false
	picker.sampler_visible = false
	picker.sliders_visible = false
	#picker.picker_shape = ColorPicker.SHAPE_VHS_CIRCLE
	return dup_ball_color_button

func _on_start_game_button_pressed():
	var all_players_ready = true
	for player_info in LobbyManager.players.values():
		if !player_info["is_ready"]:
			all_players_ready = false
	
	if all_players_ready:
		print("starting game")
		LobbyManager.start_game.rpc()

func _on_player_info_changed(peer_id):
	update_player_info(peer_id)

func _on_player_connect(player):
	add_player_to_grid(player)

func _on_toggle_is_ready(toggled_on:bool):
	LobbyManager.player_info["is_ready"] = toggled_on
	LobbyManager.update_player_info()

func _on_change_color(color_picker: ColorPickerButton):
	LobbyManager.player_info["ball_color"] = color_picker.color.to_html(false)
	LobbyManager.update_player_info()

func _on_exit_lobby_button_pressed():
	LobbyManager.leave_lobby()
	SceneManager.goto_scene("res://Scenes/UI/main_menu.tscn")

func _on_player_disconnected(id):
	if id == LobbyManager.lobby_info["host_id"]:
		LobbyManager.leave_lobby()
		SceneManager.goto_scene("res://Scenes/UI/main_menu.tscn")
	var nodes = get_tree().get_nodes_in_group(str(id))
	for node in nodes:
		node.queue_free()

func _on_remove_player_button_pressed(id):
	kick_player.rpc_id(int(id))

@rpc("any_peer", "call_remote")
func kick_player():
	LobbyManager.leave_lobby()
	SceneManager.goto_scene("res://Scenes/UI/main_menu.tscn")
