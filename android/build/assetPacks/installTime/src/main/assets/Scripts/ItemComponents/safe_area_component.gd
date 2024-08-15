extends Node2D
class_name SafeAreaComponent

const Ball = preload("res://Scripts/Game/ball.gd")

@export var safe_area: Area2D

func _ready():
	safe_area.body_exited.connect(_on_safe_area_exited)

func _on_safe_area_exited(body):
	if body is Ball:
		body.enable_ball_collision(true)
