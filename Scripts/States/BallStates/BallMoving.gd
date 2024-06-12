extends State
class_name BallMoving

var mouse_clicked_position
@onready var ball = $"../.."

func update(_delta):
	if(ball.linear_velocity.length() < 1):
		transitioned.emit(self,"idle")
