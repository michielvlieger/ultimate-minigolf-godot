extends RigidBody2D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

@rpc("any_peer", "call_local", "reliable")
func _ready():
	Camera2D.new()
