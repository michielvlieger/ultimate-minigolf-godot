extends State
class_name BallIdle

@onready var ball = $"../.."
@onready var aiming_line = $"../../AimingLine"
@export
var max_speed:float = 1000
var mouse_clicked_position = null
var isAiming = false

func _input(event):
	if event.is_action_pressed("click"):
		start_aiming()
	if event.is_action_released("click"):
		if(Vector2(get_local_mouse_position()-mouse_clicked_position).length() < 10):
			stop_aiming()
		else:
			transitioned.emit(self, "moving")

func physics_update(_delta):
	if(isAiming):
		var relative_shooting_vector = get_relative_shooting_vector()
		relative_shooting_vector /= 2
		aiming_line.set_point_position(1,relative_shooting_vector.limit_length(max_speed/2))
				
func exit():
	ball.apply_central_impulse(get_relative_shooting_vector().limit_length(max_speed))
	stop_aiming()
	
func start_aiming():
	mouse_clicked_position = get_global_mouse_position()
	aiming_line.add_point(position)
	isAiming=true
	
func stop_aiming():
	aiming_line.remove_point(1)
	mouse_clicked_position = null
	isAiming = false
	
func get_relative_shooting_vector():
	return(get_global_mouse_position()-mouse_clicked_position)
