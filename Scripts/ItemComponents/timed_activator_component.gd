extends Node2D
class_name TimedActivatorComponent

@export var activation_timer: Timer
@export var deactivation_timer: Timer
@export var to_activate: Node2D


func _ready():
	activation_timer.timeout.connect(_on_activationtimer_timeout)
	_change_activity(false)
	if deactivation_timer:
		deactivation_timer.timeout.connect(_on_deactivationtimer_timeout)
	else:
		activation_timer.one_shot = false

func _on_activationtimer_timeout():
	_change_activity(true)
	if deactivation_timer:
		deactivation_timer.start()

func _on_deactivationtimer_timeout():
	_change_activity(false)
	activation_timer.start()

func _change_activity(to_bool: bool):
	to_activate.set_process(to_bool)
	to_activate.set_physics_process(to_bool)
	if to_activate is GPUParticles2D:
		to_activate.emitting = to_bool

func start_timer():
	activation_timer.start()

func stop_timer():
	activation_timer.stop()
	deactivation_timer.stop()
