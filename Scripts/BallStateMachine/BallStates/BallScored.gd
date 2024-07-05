extends State
class_name BallScored

@onready var ball = $"../.."
@onready var collision_shape_2d = $"../../CollisionShape2D"

func enter():
	emit_scored.rpc()

@rpc("any_peer","call_local","reliable")
func emit_scored():
	collision_shape_2d.disabled = true
	ball.visible = false
	ball.is_finished = true
	ball.scored.emit()
