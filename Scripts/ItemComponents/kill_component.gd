extends Node2D
class_name KillComponent

const Ball = preload("res://Scripts/Game/ball.gd")
var safe_time_components = []
@onready var item = $".."

func _ready():
	for component in item.get_children():
		if component is GravityComponent:
			safe_time_components.append(component)

func _on_kill_zone_body_entered(body):
	if body is Ball:
		body.kill.emit()
		for component in safe_time_components:
			component.killed_players.append(body)
		#safe time after kill
		await get_tree().create_timer(1).timeout
		
		for component in safe_time_components:
			component.killed_players.erase(body)
