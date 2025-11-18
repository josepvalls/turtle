extends Node2D

export var active = true

const leaderboard_internal_name = "turtle2"

func _ready():
	$"%MainMenu".connect("pressed", get_tree(), "change_scene", ["res://scenes/gameplay/Title.tscn"])
	$"%maxScoreLabel".text = str(floor(GameManager.max_score*10))
	setup_leaderboard()
	
func setup_leaderboard():
	#$"%LineEdit".text = Game.settings.player_name
	#$"%Submit".connect("pressed", self, "submit_pressed")
	#Talo.leaderboards.connect("add_entry_response", self, "add_entry_response")
	#$"%LineEdit".text = Game.settings.player_name
	load_leaderboard()
	
func load_leaderboard():
	var options = Talo.leaderboards.GetEntriesOptions.new()
	options.page = 0
	options.include_archived = true
	Talo.leaderboards.get_entries(leaderboard_internal_name, funcref(self,"_load_entries_callback"), options)

func _load_entries_callback(res, callbacks):
	if not res:
		prints("no response")
		return
	var entries = res["body"]["entries"]

	if not entries:
		prints("no entries")
		return
	var out = ""
	var entry_count = 0
	for entry in entries:
		entry_count += 1
		if entry_count > 10: break
		entry["position"] = entries.find(entry)
		var player_name = str(entry["playerAlias"]["identifier"])
		if entry["playerAlias"]["player"]["props"]:
			var props_dict = TaloPropUtils.array_to_dictionary(entry["playerAlias"]["player"]["props"])
			if "player_name" in props_dict and props_dict["player_name"]:
				player_name = props_dict["player_name"]

		out += " " + player_name
		out += ": " + str(floor(entry["score"]*10))
		out += "\n"
	$"%LeaderboardEntries".text = out.strip_edges()

func _process(delta):
	$ParallaxBackground.scroll_base_offset.x += -256*delta
