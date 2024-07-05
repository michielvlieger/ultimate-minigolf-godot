extends State
class_name WaitingForPlayersState

func _process(_delta):
	#check if all players are ready and loaded
	start_game.rpc()

@rpc("any_peer","call_local","reliable")
func start_game():
	transitioned.emit("itemselectionstate")
