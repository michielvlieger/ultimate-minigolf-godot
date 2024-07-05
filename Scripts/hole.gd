extends Area2D

var ballsInArea = {}
const Ball = preload("res://Scripts/ball.gd")

func _on_body_entered(body):
	if body is Ball:
		ballsInArea[body.name] = body
		body.get_node("StateMachine").on_child_transition("scoring")

func _on_body_exited(body):
	if body is Ball:
		ballsInArea.erase(body.name)
		body.get_node("StateMachine").on_child_transition("moving")

func _physics_process(_delta):
	for key in ballsInArea:
		var ball = ballsInArea[key]
		if ball.get_node("StateMachine").current_state.name == "scoring":
			ball.apply_central_force((self.global_position - ball.global_position) * 20)
