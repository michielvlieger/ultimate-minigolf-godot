extends Node

var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}
var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
@export var host_port = 8915


func _ready():
	if "--server" in OS.get_cmdline_args():
		print("hosting on " + str(host_port))
		peer.create_server(host_port)
		
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)


func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			
			if data.message ==  Utilities.Message.lobby:
				join_lobby(data)
				
			if data.message ==  Utilities.Message.offer || data.message ==  Utilities.Message.answer || data.message ==  Utilities.Message.candidate:
				send_to_player(data.peer, data)
				
			if data.message ==  Utilities.Message.remove_lobby:
				if lobbies.has(data.lobby_id):
					lobbies.erase(data.lobby_id)
			
			if data.message == Utilities.Message.update_player_info:
				update_player_info(data["lobby_id"],data["id"],data["is_ready"],data["ball_color"])
				
func update_player_info(lobby_id, player_id, is_ready, ball_color):
	lobbies[lobby_id].players[player_id]["is_ready"] = is_ready
	lobbies[lobby_id].players[player_id]["ball_color"] = ball_color
	for p in lobbies[lobby_id].players:
		var message = {
			"message" :  Utilities.Message.update_player_info,
			"id" : player_id,
			"is_ready": is_ready,
			"ball_color": ball_color
		}
		send_to_player(p, message)

func peer_connected(id):
	users[id] = {
		"id" : id,
		"message" :  Utilities.Message.id
	}
	peer.get_peer(id).put_packet(JSON.stringify(users[id]).to_utf8_buffer())
	
func peer_disconnected(id):
	users.erase(id)

func join_lobby(user):
	if user.lobby_id == "":
		user.lobby_id = generate_random_string()
		lobbies[user.lobby_id] = Lobby.new(user.id)
	lobbies[user.lobby_id].AddPlayer(user.id, user.username)
	
	for p in lobbies[user.lobby_id].players:
		var message = {
			"message" :  Utilities.Message.user_connected,
			"id" : user.id
		}
		send_to_player(p, message)
		
		var message2 = {
			"message" :  Utilities.Message.user_connected,
			"id" : p
		}
		send_to_player(user.id, message2)
		
		var lobby_info = {
			"message" :  Utilities.Message.lobby,
			"players" : JSON.stringify(lobbies[user.lobby_id].players),
			"host_id" : lobbies[user.lobby_id].host_id,
			"lobby_id" : user.lobby_id,
			"joined_player" : user.id
		}
		send_to_player(p, lobby_info)
	
	
	var data = {
		"message" :  Utilities.Message.user_connected,
		"id" : user.id,
		"host_id" : lobbies[user.lobby_id].host_id,
		"player" : lobbies[user.lobby_id].players[user.id],
		"lobby_id" : user.lobby_id
	}
	
	send_to_player(user.id, data)

func send_to_player(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf8_buffer())
	
func generate_random_string():
	var result = ""
	for i in range(4):
		var index = randi() % characters.length()
		result += characters[index]
	return result

func start_server():
	peer.create_server(8915)

func _on_start_server_button_down():
	start_server()
