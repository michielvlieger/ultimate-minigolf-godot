extends State
class_name BallScored

@onready var ball = $"../.."

func enter():
	ball.scored.emit()
