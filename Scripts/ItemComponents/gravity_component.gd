extends Node2D
class_name GravityComponent

var balls_in_area = {}
const Ball = preload("res://Scripts/ball.gd")

@export var affected_area: Area2D
@export var strength: int

func _ready():
	affected_area.body_entered.connect(_on_gravity_zone_body_entered)
	affected_area.body_exited.connect(_on_gravity_zone_body_exited)

func _on_gravity_zone_body_entered(body):
	if body is Ball:
		balls_in_area[body.name] = body

func _on_gravity_zone_body_exited(body):
	if body is Ball:
		balls_in_area.erase(body.name)

func _physics_process(_delta):
	for key in balls_in_area:
		var ball = balls_in_area[key]
		ball.apply_central_force((self.global_position - ball.global_position) * strength)
