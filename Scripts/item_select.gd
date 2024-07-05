extends Control

@onready var texture_rect = $VBoxContainer/TextureRect
@onready var label = $VBoxContainer/Label

@rpc("any_peer","call_local","reliable")
func set_data(image:Image,text:String):
	texture_rect.texture = ImageTexture.create_from_image(image)
	label.text = text
