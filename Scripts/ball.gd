extends RigidBody2D
class_name Ball

signal scored
signal shot

@onready var camera_2d = $Camera2D
@onready var state_machine = $StateMachine

@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float

var player_data:PlayerData

func set_data(fplayer_id:int, fplayer_name:String, fnumber_of_rounds:int):
	player_data = PlayerData.new(fplayer_id, fplayer_name, fnumber_of_rounds)

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
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
