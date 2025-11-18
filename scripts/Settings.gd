extends Resource
class_name Settings

export var sfx_volume: float = 1.0
export var music_volume: float = 1.0
export var player_name: String = "???"
export var user_name: String = ""
export var user_secret: String = ""
export var unlocked_levels : int = 1


func set_bus_volume_percent(bus_name: String, percent: float):
	match bus_name:
		"Music":
			music_volume = percent
		"SFX":
			sfx_volume = percent

func set_player_name(name: String):
	name = name.strip_edges()
	if name.length() > 0:
		player_name = name
	else:
		player_name = "Anonymous"

