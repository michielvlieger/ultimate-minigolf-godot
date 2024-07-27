extends State
class_name BallScored

@onready var ball = $"../.."
@onready var collision_shape_2d = $"../../CollisionShape2D"
@onready var state_machine = $".."

func enter():
	emit_scored.rpc()

@rpc("any_peer","call_local","reliable")
func emit_scored():
	ball.enable_ball_collision(false)
	ball.visible = false
	ball.is_finished = true
	ball.scored.emit()
	transitioned.emit("spectating")
