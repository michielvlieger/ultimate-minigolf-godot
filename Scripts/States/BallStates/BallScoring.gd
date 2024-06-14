extends State
class_name BallScoring

@onready var ball = $"../.."

func enter():
	print("entered scoring")

func physics_update(_delta):
	if(ball.linear_velocity.length() < 5):
		transitioned.emit(self,"scored")
