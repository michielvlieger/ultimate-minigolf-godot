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
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	peer.poll()

func start_server():
	peer.create_server(8915)
	print("started server")


func _on_start_server_pressed():
	start_server()
