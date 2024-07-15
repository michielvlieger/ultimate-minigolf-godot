extends Control

@onready var players_grid_container = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var start_game_button = $PanelContainer/MarginContainer/VBoxContainer/StartGameButton

@onready var username_label = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/UsernameLabel
@onready var ball_color = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorRect
@onready var ball_color_button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorPickerButton
@onready var remove_player_button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/TextureButton
@onready var is_ready_check_box = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/CheckBox
@onready var column_name_4 = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColumnName4

func _ready():
	LobbyManager.player_connected.connect(_on_player_connect)
	LobbyManager.player_info_changed.connect(_on_player_info_changed)
	for peer_id in LobbyManager.players:
		var player_info = LobbyManager.players[peer_id]
		add_player_to_grid(peer_id, player_info)
	
	if multiplayer.get_unique_id() == 1:
		start_game_button.visible=true
	else:
		players_grid_container.columns = 3
		column_name_4.visible = false

func add_player_to_grid(peer_id, player_info):
	var new_ball_color
	var new_is_ready_check_box = is_ready_check_box.duplicate() as CheckBox
	var new_label = username_label.duplicate() as Label
	
	new_label.text = player_info["username"]

	if peer_id == multiplayer.get_unique_id():
		new_ball_color = get_dup_ball_color_button()
		new_ball_color.color_changed.connect(_on_change_color)
		new_ball_color.color = player_info["ball_color"]
		
		new_is_ready_check_box.disabled = false
		new_is_ready_check_box.button_pressed = player_info["is_ready"]
		new_is_ready_check_box.toggled.connect(_on_toggle_is_ready)
	else:
		new_ball_color = ball_color.duplicate()
		new_ball_color.color = player_info["ball_color"]
	
	new_label.visible = true
	new_ball_color.visible = true
	new_is_ready_check_box.visible = true
	
	new_label.add_to_group(str(peer_id))
	new_ball_color.add_to_group(str(peer_id))
	new_is_ready_check_box.add_to_group(str(peer_id))
	
	players_grid_container.add_child(new_label)
	players_grid_container.add_child(new_ball_color)
	players_grid_container.add_child(new_is_ready_check_box)
	
	if multiplayer.get_unique_id() == 1:
		start_game_button.visible=true
		var new_remove_player_button = remove_player_button.duplicate()
		new_remove_player_button.visible = true
		new_remove_player_button.add_to_group(str(peer_id))
		players_grid_container.add_child(new_remove_player_button)

func update_player_info(peer_id):
	var player_info = LobbyManager.players[peer_id]
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
	for player_info in LobbyManager.players:
		if !player_info["is_ready"]:
			all_players_ready = false
	
	if all_players_ready:
		pass

func _on_player_info_changed(peer_id):
	update_player_info(peer_id)

func _on_player_connect(peer_id, player_info):
	add_player_to_grid(peer_id, player_info)

func _on_toggle_is_ready(toggled_on:bool):
	LobbyManager.player_info["is_ready"] = toggled_on
	LobbyManager._update_player_info.rpc(LobbyManager.player_info)

func _on_change_color(color: Color):
	LobbyManager.player_info["ball_color"] = color
	LobbyManager._update_player_info.rpc(LobbyManager.player_info)
