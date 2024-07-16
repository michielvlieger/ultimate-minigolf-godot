extends Node

enum Message {
	id,
	join,
	user_connected,
	user_disconnected,
	lobby,
	candidate,
	offer,
	answer,
	check_in
}

var peer = WebSocketMultiplayerPeer.new()


func _ready():
	pass # Replace with function body.


func _process(delta):
	pass

func connect_to_server(ip):
	peer.create_client("ws://127.0.0.1:8915")
	print("started_client")


func _on_start_client_pressed():
	connect_to_server("ws://127.0.0.1:8915")


func _on_button_pressed():
	var message = {
		"message": Message.join,
		"data": "test"
	}
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes)
