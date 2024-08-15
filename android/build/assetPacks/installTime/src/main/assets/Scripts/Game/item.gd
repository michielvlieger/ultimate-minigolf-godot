extends Node2D
class_name Item

func activate_item():
	for component in get_children():
		if component is TimedActivatorComponent:
			component.start_timer()

func deactivate_item():
	for component in get_children():
		if component is TimedActivatorComponent:
			component.stop_timer()
		
