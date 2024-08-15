extends Node2D
class_name GravityComponent

const Ball = preload("res://Scripts/Game/ball.gd")

@export var affected_area: Area2D
@export var strength: int
var killed_players = []

func _physics_process(_delta):
	for body in affected_area.get_overlapping_bodies():
		if body is Ball and !killed_players.has(body):
			body.apply_central_force((self.global_position - body.global_position) * strength)
