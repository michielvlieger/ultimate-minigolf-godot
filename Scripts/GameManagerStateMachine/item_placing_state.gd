extends State
class_name ItemPlacingState

@onready var player_manager = $"../../PlayerManager"

func enter():
	pass
	
func exit():
	var players = player_manager.get_children()
	for player in players:
		player.reset.emit(Vector2(0,0))
