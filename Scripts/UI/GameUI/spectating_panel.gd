extends Control

signal cycle_spectating(is_next)

@export var username_label:Label

func _on_cycle_previous_pressed():
	cycle_spectating.emit(false)

func _on_cycle_next_pressed():
	cycle_spectating.emit(true)
