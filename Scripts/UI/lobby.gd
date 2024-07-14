extends Control

@onready var players_grid_container = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var start_game_button = $PanelContainer/MarginContainer/VBoxContainer/StartGameButton

@onready var username_label = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/UsernameLabel
@onready var color_rect = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorRect
@onready var color_picker_button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ColorPickerButton

func _ready():
	var picker = color_picker_button.get_picker() as ColorPicker
	picker.edit_alpha = false
	picker.can_add_swatches = false
	picker.color_modes_visible = false
	picker.hex_visible = false
	picker.presets_visible = false
	picker.sampler_visible = false
	picker.sliders_visible = false
	picker.picker_shape = ColorPicker.SHAPE_VHS_CIRCLE

	
	LobbyManager.player_connected.connect(_on_player_connect)
	for peer_id in LobbyManager.players:
		var player_info = LobbyManager.players[peer_id]
		add_player_to_grid(peer_id, player_info)
	
	if multiplayer.get_unique_id() == 1:
		start_game_button.visible=true

func _on_player_connect(peer_id, player_info):
	add_player_to_grid(peer_id, player_info)
	
func add_player_to_grid(peer_id, player_info):
	var label = username_label.duplicate()
	label.visible = true
	label.text = player_info["username"]
	players_grid_container.add_child(label)
	
	var color_picker
	if peer_id == multiplayer.get_unique_id():
		color_picker = color_picker_button.duplicate()
	else:
		color_picker = color_rect.duplicate()
	
	color_picker.visible = true
	players_grid_container.add_child(color_picker)


func _on_start_game_button_pressed():
	pass # Replace with function body.
