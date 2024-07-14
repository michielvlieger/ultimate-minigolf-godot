extends Control

@export var initial_menu: MenuControl

var current_menu: MenuControl

func _ready():
	for child in get_tree().get_nodes_in_group("menu_switch_buttons"):
		child.menu_switch_signal.connect(switch_menu)
	
	if initial_menu:
		switch_menu(initial_menu)

func switch_menu(new_menu):
	if current_menu:
		current_menu.hide()
	
	new_menu.show()
	current_menu = new_menu
