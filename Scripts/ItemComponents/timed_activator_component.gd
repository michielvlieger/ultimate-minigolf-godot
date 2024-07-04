extends Node2D
class_name TimedActivatorComponent

@export var activation_timer: Timer
@export var deactivation_timer: Timer
@export var to_activate: Node2D
@export var should_change_visibility: bool

func _ready():
	activation_timer.timeout.connect(_on_activationtimer_timeout)
	_change_activity.rpc(false)
	if deactivation_timer:
		deactivation_timer.timeout.connect(_on_deactivationtimer_timeout)
	else:
		activation_timer.autostart = true

func _on_activationtimer_timeout():
	_change_activity.rpc(true)
	if deactivation_timer:
		deactivation_timer.start()

func _on_deactivationtimer_timeout():
	_change_activity.rpc(false)
	activation_timer.start()

@rpc("any_peer","call_local","reliable")
func _change_activity(to_bool: bool):
	to_activate.set_process(to_bool)
	to_activate.set_physics_process(to_bool)
	if should_change_visibility:
		to_activate.visible = to_bool
