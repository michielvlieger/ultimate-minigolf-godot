extends RefCounted
class_name Lobby

var host_id : int
var players : Dictionary = {}
var open_slots : int = 6
var time_to_live = 60

func _init(id):
	host_id = id
	
func AddPlayer(id, name):
	players[id] = {
		"username": name,
		"id": id,
		"index": players.size() + 1,
		"is_ready":false,
		"ball_color":Color.WHITE.to_html(false)
	}
	return players[id]
