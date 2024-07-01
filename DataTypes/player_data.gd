extends Resource
class_name PlayerData

@export var peer_id:int
@export var name:String
@export var is_finished:bool
@export var scores: Array

func _init(fpeer_id, fname, fnumber_of_rounds):
	peer_id = fpeer_id
	name = fname
	is_finished = false
	scores = []
	scores.resize(fnumber_of_rounds)
	scores.fill(0)
