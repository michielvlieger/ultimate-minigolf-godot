extends Node2D
class_name ScoringComponent

const Ball = preload("res://Scripts/ball.gd")

@export var affected_area: Area2D

func _ready():
	affected_area.body_entered.connect(_on_scoring_zone_body_entered)
	affected_area.body_exited.connect(_on_scoring_zone_body_exited)

func _on_scoring_zone_body_entered(body):
	if body is Ball:
		body.get_node("StateMachine").on_child_transition("scoring")

func _on_scoring_zone_body_exited(body):
	if body is Ball:
		body.get_node("StateMachine").on_child_transition("moving")
