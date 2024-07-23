extends RigidBody2D

signal scored
signal score_change
signal shot
signal reset(pos)
signal kill

@export var camera_2d: Camera2D
@onready var state_machine = $StateMachine
@onready var state_scored = $StateMachine/Scored
@onready var collision_shape_2d = $CollisionShape2D

@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float

@export var peer_id:int
@export var player_name:String
@export var is_finished:bool
@export var last_pos: Vector2
@export var spawn_position: Vector2
var _kill_player = false
var _reset_player = false

@export var scores: Array:
	get = get_scores, set = set_scores
		
func get_scores():
	return scores

@rpc("any_peer", "call_local", "reliable")	
func set_scores(new_scores):
	score_change.emit()
	scores = new_scores

func set_data(fplayer_id:int, fplayer_name:String, fnumber_of_rounds:int, fspawn_position:Vector2):
	peer_id = fplayer_id
	player_name = fplayer_name
	var init_scores = []
	init_scores.resize(fnumber_of_rounds)
	init_scores.fill(0)
	scores = init_scores
	spawn_position = fspawn_position

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	multiplayer.allow_object_decoding = true
	last_pos = position

func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
	if _kill_player:
		_kill_player = false
		kill_player.rpc()
	if _reset_player:
		_reset_player = false
		reset_player.rpc()
	
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

@rpc("any_peer","call_local","reliable")
func reset_player():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	position = Vector2.ZERO
	last_pos = Vector2.ZERO
	state_machine.on_child_transition("idle")
	visible = true
	is_finished = false

func _on_reset(_pos):
	_reset_player = true
	#reset_variables.rpc()
	enable_ball_collision(false)

func _on_kill():
	_kill_player = true

@rpc("any_peer","call_local","reliable")
func kill_player():
	if last_pos == Vector2.ZERO:
		enable_ball_collision(false)
	transform.origin = last_pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	state_machine.on_child_transition("idle")

@rpc("any_peer","call_local","reliable")
func set_camera_to_player(ball):
	ball.camera_2d.make_current()

@rpc("any_peer","call_local","reliable")
func enable_ball_collision(to_bool):
	set_collision_layer_value(2,to_bool)
	set_collision_mask_value(2,to_bool)
