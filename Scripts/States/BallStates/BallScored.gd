extends State
class_name BallScored

@onready var ball = $"../.."

func enter():
	emit_scored.rpc()

@rpc("any_peer","call_local","reliable")
func emit_scored():
	ball.scored.emit()
