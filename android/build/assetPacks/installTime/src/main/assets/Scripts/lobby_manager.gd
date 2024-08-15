extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal player_info_changed(peer_id)

const PORT = 7000
const DEFAULT_SERVER_IP = "ws://174.138.15.75:8915" #droplet ip
const MAX_CONNECTIONS = 20

var peer = WebSocketMultiplayerPeer.new()
var rtc_peer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()

var lobby_info = {
	"host_id": 0,
	"lobby_id":"",
	"current_round": 1,
	"number_of_rounds": 2
	}
# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"username": "Name",
	"ball_color": Color.WHITE_SMOKE.to_html(false),
	"is_ready": false,
	"id":0
	}

func _ready():
	peer.create_client("ws://174.138.15.75:8915")

func _exit_tree():
	var user_disconnect_message = {
		"id" : player_info["id"],
		"message" : Utilities.Message.user_disconnected,
	}
	peer.put_packet(JSON.stringify(user_disconnect_message).to_utf8_buffer())

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			
			#on peer connected to server
			if data.message == Utilities.Message.id:
				player_info["id"] = data.id
				connected(data.id)
			
			#on user handshake??
			if data.message == Utilities.Message.user_connected:
				create_peer(data.id)
			
			#on connection to lobby
			if data.message == Utilities.Message.lobby:
				players = JSON.parse_string(data.players)
				lobby_info["host_id"] = data.host_id
				lobby_info["lobby_id"] = data.lobby_id
				SceneManager.goto_scene("res://Scenes/UI/lobby.tscn")
				player_connected.emit(players[str(data.joined_player)])
				print("connected to lobby: " + lobby_info["lobby_id"])
			
			#on ice candidate created
			if data.message == Utilities.Message.candidate:
				if rtc_peer.has_peer(data.orgPeer):
					rtc_peer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
			
			#on offer
			if data.message == Utilities.Message.offer:
				if rtc_peer.has_peer(data.orgPeer):
					rtc_peer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			
			#on answer
			if data.message == Utilities.Message.answer:
				if rtc_peer.has_peer(data.orgPeer):
					rtc_peer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)
			
			#on player info updated
			if data.message == Utilities.Message.update_player_info:
				players[str(data.id)]["is_ready"] = data["is_ready"]
				players[str(data.id)]["ball_color"] = data["ball_color"]
				player_info_changed.emit(str(data.id))

func connected(id):
	rtc_peer.create_mesh(id)
	multiplayer.multiplayer_peer = rtc_peer

#web rtc connection
func create_peer(id):
	if id != player_info["id"]:
		var newpeer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		newpeer.initialize({
			"iceServers" : [{ "urls": ["stun:stun.l.google.com:19302"] }]
		})
		
		newpeer.session_description_created.connect(offer_created.bind(id))
		newpeer.ice_candidate_created.connect(ice_candidate_created.bind(id))
		rtc_peer.add_peer(newpeer, id)
		
		if id < rtc_peer.get_unique_id():
			newpeer.create_offer()

func offer_created(type, data, id):
	if !rtc_peer.has_peer(id):
		return
		
	rtc_peer.get_peer(id).connection.set_local_description(type, data)
	
	if type == "offer":
		send_offer(id, data)
	else:
		send_answer(id, data)

func send_offer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : player_info["id"],
		"message" :  Utilities.Message.offer,
		"data": data,
		"lobby_id": lobby_info["lobby_id"]
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func send_answer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : player_info["id"],
		"message" : Utilities.Message.answer,
		"data": data,
		"lobby_id": lobby_info["lobby_id"]
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func ice_candidate_created(midName, indexName, sdpName, id):
	var message = {
		"peer" : id,
		"orgPeer" : player_info["id"],
		"message" :  Utilities.Message.candidate,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"lobby_id": lobby_info["lobby_id"]
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

@rpc("any_peer", "call_local")
func start_game():
	SceneManager.goto_scene("res://Scenes/main.tscn")

func join_lobby(username:String, lobby_id:=""):
	var message = {
		"id" : player_info["id"],
		"message" : Utilities.Message.lobby,
		"username" : username,
		"lobby_id" : lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func update_player_info():
	var message = {
		"id" : player_info["id"],
		"message" : Utilities.Message.update_player_info,
		"lobby_id": lobby_info["lobby_id"],
		"ball_color": player_info["ball_color"],
		"is_ready": player_info["is_ready"]
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func leave_lobby():
	disconnect_player.rpc(player_info["id"])
	
	if players.size() == 1:
		var message = {
			"message":  Utilities.Message.remove_lobby,
			"lobby_id" : lobby_info["lobby_id"]
		}
		peer.put_packet(JSON.stringify(message).to_utf8_buffer())

@rpc("any_peer", "call_local")
func disconnect_player(id):
	if player_info["id"] != id:
		players.erase(str(id))
		multiplayer.multiplayer_peer.disconnect_peer(id)
		player_disconnected.emit(id)
