extends Resource
class_name GameData

@export var current_round: int
@export var number_of_rounds: int = 18

func _init(fnumber_of_rounds):
	number_of_rounds = fnumber_of_rounds
	current_round = 1
