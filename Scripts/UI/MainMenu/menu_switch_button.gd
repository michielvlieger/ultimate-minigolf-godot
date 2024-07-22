extends Button
class_name MenuSwitchButton

@export var to_menu: MenuControl
signal menu_switch_signal

func _ready():
	self.add_to_group("menu_switch_buttons")
	self.pressed.connect(_on_pressed)

func _on_pressed():
	menu_switch_signal.emit(to_menu)
