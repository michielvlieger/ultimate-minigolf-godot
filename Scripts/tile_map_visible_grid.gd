extends Node2D

@export var color := Color(1.0, 0.0, 0.0)
@export var line_width := 2.0

func _ready():
	set_process(true)
	
func _draw():
	var tilemap = get_parent() as TileMap
	for cell in tilemap.get_used_cells(3):
		var local_pos = tilemap.map_to_local(cell)
		var tile_size = Vector2(tilemap.tile_set.tile_size)
		local_pos -= tile_size/2
		#left line
		draw_line(local_pos, Vector2(local_pos.x,local_pos.y+tile_size.y), color,line_width)
		#top line
		draw_line(local_pos, Vector2(local_pos.x+tile_size.x,local_pos.y), color,line_width)
		#bottom line
		draw_line(Vector2(local_pos.x,local_pos.y+tile_size.y), Vector2(local_pos.x+tile_size.x,local_pos.y+tile_size.y), color,line_width)
		#right line
		draw_line(Vector2(local_pos.x+tile_size.x,local_pos.y), Vector2(local_pos.x+tile_size.x,local_pos.y+tile_size.y), color,line_width)
