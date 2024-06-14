extends State
class_name BallMoving

@onready var ball = $"../.."

func physics_update(_delta):
	if(ball.linear_velocity.length() < 2):
		transitioned.emit(self,"idle")

func enter():
	print("entered moving")
