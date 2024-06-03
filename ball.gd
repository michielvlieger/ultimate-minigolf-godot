extends RigidBody2D

enum BallState {
	idle,
	aiming,
	moving,
	shooting
}
@onready var aiming_line = $AimingLine

@export
var max_speed:float = 1000

var current_state = BallState.idle
var mouse_clicked_position = null

func _input(event):
	if event.is_action_pressed("click") && current_state == BallState.idle:
		mouse_clicked_position = get_local_mouse_position()
		aiming_line.add_point(position)
		current_state = BallState.aiming
	if event.is_action_released("click") && current_state == BallState.aiming:
		if(Vector2(get_local_mouse_position()-mouse_clicked_position).length() < 10):
			aiming_line.remove_point(1)
			mouse_clicked_position = null
			current_state = BallState.idle
		else:
			current_state = BallState.shooting

func _physics_process(delta):
	match current_state:
		BallState.idle:
			pass
		BallState.aiming:
			var relative_shooting_vector = get_local_mouse_position()-mouse_clicked_position
			relative_shooting_vector /= 2
			aiming_line.set_point_position(1,relative_shooting_vector.limit_length(max_speed/2))
		BallState.shooting:
			shoot_ball()
			aiming_line.remove_point(1)
			mouse_clicked_position = null
		BallState.moving:
			if(linear_velocity.length() < 1):
				current_state = BallState.idle
	

func shoot_ball():
	var relative_shooting_vector = get_local_mouse_position()-mouse_clicked_position
	apply_central_impulse(relative_shooting_vector.limit_length(max_speed))
	current_state = BallState.moving
	
