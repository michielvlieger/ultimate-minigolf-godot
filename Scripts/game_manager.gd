extends Node2D
class_name GameManager

@onready var player_manager = $"../PlayerManager"

var current_round: int = 1
@export var number_of_rounds: int = 18

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
	if !is_multiplayer_authority():
		return
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
			

func on_child_transition(new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		await current_state.exit()
	
	new_state.enter()
	
	current_state = new_state
