extends StateMachine
class_name GameManager

@onready var player_manager = $"../PlayerManager"

var current_round: int = 1
@export var number_of_rounds: int = 18
