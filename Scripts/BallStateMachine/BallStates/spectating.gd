extends State
class_name Spectating

@onready var ball = $"../.."

var player_cameras = {}
var spectating_id
var spectating_index = 0
var spectating_control
var username_label

func _ready():
	#SpectatingControl.cycle_spectating.connect(cycle_players)
	for node in ball.get_parent().get_parent().get_children():
		if node is UIManager:
			spectating_control = node.spectating_control
			username_label = spectating_control.username_label
			spectating_control.cycle_spectating.connect(cycle_players)

func enter():
	player_cameras.clear()
	spectating_id = null
	for player in ball.get_parent().get_children():
		if player != ball and !player.is_finished:
			player_cameras[player.name] = player.camera_2d
	
	if player_cameras.is_empty():
		return
	
	spectating_control.visible = true
	spectating_id = player_cameras.keys()[0]
	spectating_index = 0
	player_cameras[spectating_id].make_current()
	username_label.text = LobbyManager.players[spectating_id]["username"]

func update(_delta):
	print(player_cameras)
	if player_cameras.is_empty() or !spectating_id:
		return
	for player in ball.get_parent().get_children():
		if player_cameras.has(player.name) and player.is_finished:
			player_cameras.erase(player.name)
			if spectating_id == player.name and !player_cameras.is_empty():
				spectating_id = player_cameras.keys()[0]
				spectating_index = 0
				player_cameras[spectating_id].make_current()
				username_label.text = LobbyManager.players[spectating_id]["username"]

func cycle_players(is_next: bool):
	if is_next:
		spectating_index += 1
	else:
		spectating_index -= 1

	if player_cameras.size() == 0:
		return
	var dictionary_index = spectating_index % player_cameras.size()
	spectating_id = player_cameras.keys()[dictionary_index]
	player_cameras[spectating_id].make_current()
	username_label.text = LobbyManager.players[spectating_id]["username"]

func exit():
	spectating_control.visible = false
