extends State
class_name BallScoring

@onready var ball = $"../.."
@onready var state_machine = $".."

func physics_update(_delta):
	if ball.linear_velocity.length() < 2:
		if state_machine.current_state.name == "Scoring":
			transitioned.emit("scored")
