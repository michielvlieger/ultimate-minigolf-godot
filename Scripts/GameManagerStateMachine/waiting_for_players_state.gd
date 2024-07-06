extends State
class_name WaitingForPlayersState

func update(_delta):
	#check if all players are ready and loaded
	print("starting game")
	start_game.rpc()

@rpc("any_peer","call_local","reliable")
func start_game():
	transitioned.emit("ItemSelectionState")
