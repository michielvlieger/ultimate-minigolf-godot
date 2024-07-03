extends Node2D
class_name KillComponent

const Ball = preload("res://Scripts/ball.gd")

func _on_kill_zone_body_entered(body):
	if body is Ball:
		kill_player.rpc(body)

@rpc("any_peer","call_local","reliable")
func kill_player(player):
	player.kill.emit()
