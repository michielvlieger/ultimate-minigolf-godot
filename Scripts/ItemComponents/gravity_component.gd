extends Node2D
class_name GravityComponent

var balls_in_area = {}
const Ball = preload("res://Scripts/ball.gd")

@export var strength: int

func _on_gravity_zone_body_entered(body):
	if body is Ball:
		balls_in_area[body.name] = body

func _on_gravity_zone_body_exited(body):
	if body is Ball:
		balls_in_area.erase(body.name)

func _physics_process(_delta):
	for key in balls_in_area:
		var ball = balls_in_area[key]
		if ball.get_node("StateMachine").current_state_name != "idle":
			ball.apply_central_force((self.global_position - ball.global_position) * strength)
