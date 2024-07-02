extends RigidBody2D

signal scored
signal score_change
signal shot

@onready var camera_2d = $Camera2D
@onready var state_machine = $StateMachine

@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float

@export var peer_id:int
@export var player_name:String
@export var scores: Array:
	get = get_scores, set = set_scores
		
func get_scores():
	return scores

@rpc("any_peer", "call_local", "reliable")	
func set_scores(new_scores):
	score_change.emit()
	scores = new_scores

func set_data(fplayer_id:int, fplayer_name:String, fnumber_of_rounds:int):
	peer_id = fplayer_id
	player_name = fplayer_name
	var init_scores = []
	init_scores.resize(fnumber_of_rounds)
	init_scores.fill(0)
	scores = init_scores

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	multiplayer.allow_object_decoding = true
	if $"./MultiplayerSynchronizer".get_multiplayer_authority() == multiplayer.get_unique_id(): camera_2d.make_current()

func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
	if is_multiplayer_authority():
		replicated_position = position
		replicated_rotation = rotation
		replicated_linear_velocity = linear_velocity
		replicated_angular_velocity = angular_velocity
	else:
		position = replicated_position
		rotation = replicated_rotation
		linear_velocity = replicated_linear_velocity
		angular_velocity = replicated_angular_velocity
