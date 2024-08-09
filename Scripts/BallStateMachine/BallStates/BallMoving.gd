extends State
class_name BallMoving

@onready var ball = $"../.."

func physics_update(_delta):
	if(ball.linear_velocity.length() < 2):
		print("moving too slow")
		transitioned.emit("idle")
