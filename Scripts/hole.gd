extends Area2D

var ballsInArea = {}

func _on_body_entered(body):
	if body.is_in_group("balls"):
		ballsInArea[body.name] = body
		body.get_node("StateMachine").on_child_transition(body.get_node("StateMachine/Moving"), "scoring")

func _on_body_exited(body):
	if body.is_in_group("balls"):
		ballsInArea.erase(body.name)
		body.get_node("StateMachine").on_child_transition(body.get_node("StateMachine/Scoring"), "moving")

func _physics_process(_delta):
	for key in ballsInArea:
		var ball = ballsInArea[key]
		if ball.get_node("StateMachine").current_state.name.to_lower() == "scoring":
			ball.apply_central_force((self.global_position - ball.global_position) * 20)
