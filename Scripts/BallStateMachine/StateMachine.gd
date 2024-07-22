extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
	#set_multiplayer_authority(multiplayer.get_unique_id())
	#if !is_multiplayer_authority():
		#return
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
			
func _process(delta):
	if !is_multiplayer_authority():
		return
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if current_state:
		current_state.physics_update(delta)

func _input(event):
	if !is_multiplayer_authority():
		return
	if current_state:
		current_state.input(event)

@rpc("any_peer","call_local","reliable")
func on_child_transition(new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	
	if !new_state:
		return
	
	if current_state:
		await current_state.exit()
	
	new_state.enter()
	
	current_state = new_state
