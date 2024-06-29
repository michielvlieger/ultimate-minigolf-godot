extends RigidBody2D

signal scored

@onready var camera_2d = $Camera2D

@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float

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
