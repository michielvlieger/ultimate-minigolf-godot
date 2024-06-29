extends CanvasLayer

@onready var grid_container = $Panel/MarginContainer/VBoxContainer/GridContainer
@export var games_amount:int
var current_game:int = 0

func _ready():
	grid_container.columns = games_amount+1
	add_label_to_grid_container("Games")
	for game_number in games_amount:
		add_label_to_grid_container(str(game_number+1))
	
	add_player("player 1")
	add_player("player 2")
	
func add_player(playername = 'test'):
	add_label_to_grid_container(playername)
	for game_number in games_amount:
		add_label_to_grid_container(str(0))
		
func add_label_to_grid_container(label_text:String):
	var games_label = Label.new()
	games_label.set_text(label_text)
	grid_container.add_child(games_label)
	
func change_score():
	pass
