extends State
class_name BallIdle

@onready var ball = $"../.."
@onready var aiming_line = $"../../AimingLine"

@export
var max_speed:float = 1500

var mouse_clicked_position = null
var isAiming = false

func enter():
	print("entered idle")
	mouse_clicked_position = null
	isAiming = false

func input(event):
	if !isAiming && event.is_action_pressed("click"):
		start_aiming()
	if isAiming:
		var relative_shooting_vector = get_relative_shooting_vector()
		if event is InputEventMouseMotion:
			var aiming_line_vector = relative_shooting_vector.rotated(-ball.global_rotation)
			aiming_line_vector = aiming_line_vector.limit_length(max_speed)
			aiming_line_vector = aiming_line_vector / max_speed * 400
			aiming_line.set_point_position(1,aiming_line_vector)
		if event.is_action_released("click"):
			if(relative_shooting_vector.length() > 10):
				shoot_ball.rpc_id(1,relative_shooting_vector)
			stop_aiming()

func update(_delta):
	if(ball.linear_velocity.length() > 2):
		transitioned.emit(self, "moving")
	
func start_aiming():
	mouse_clicked_position = get_local_mouse_position()
	aiming_line.add_point(get_relative_shooting_vector().rotated(-ball.global_rotation))
	isAiming=true
	
func stop_aiming():
	aiming_line.remove_point(1)
	mouse_clicked_position = null
	isAiming = false
	
func get_relative_shooting_vector():
	return(mouse_clicked_position-get_local_mouse_position())

@rpc("authority", "call_local", "reliable")
func shoot_ball(relative_shooting_vector):
	print("shooting")
	print(multiplayer.get_remote_sender_id())
	print(ball)
	ball.apply_central_impulse(relative_shooting_vector.limit_length(max_speed))
