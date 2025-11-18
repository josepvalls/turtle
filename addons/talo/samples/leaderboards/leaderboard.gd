extends Node

export var leaderboard_internal_name =  "w0"
onready var entries_container = $MarginContainer/VBoxContainer/EntriesVBoxContainer

func _ready() -> void:
	$MarginContainer/VBoxContainer/LeaderboardNameLabel.text = leaderboard_internal_name
	$MarginContainer/VBoxContainer/Button.connect("pressed", self, "_on_submit_pressed")
	Talo.leaderboards.connect("add_entry_response", self, "add_entry_response")
	_load_entries()
	$MarginContainer/VBoxContainer/LineEditUserName.text = Talo.players.generate_identifier()

func _create_entry(entry) -> void:
	var entry_instance = Label.new()
	entry_instance.text = ""
	entry_instance.text += " " + str(entry["position"])
	var player_name = str(entry["playerAlias"]["identifier"])
	if entry["playerAlias"]["player"]["props"]:
		var props_dict = TaloPropUtils.array_to_dictionary(entry["playerAlias"]["player"]["props"])
		if "player_name" in props_dict and props_dict["player_name"]:
			player_name = props_dict["player_name"]

	entry_instance.text += " " + player_name
	entry_instance.text += " " + str(entry["score"])
	entries_container.add_child(entry_instance)

func _build_entries(entries) -> void:
	for child in entries_container.get_children():
		child.queue_free()

	if not entries:
		return
	for entry in entries:
		entry["position"] = entries.find(entry)
		_create_entry(entry)

func _load_entries() -> void:
	var options = Talo.leaderboards.GetEntriesOptions.new()
	options.page = 0
	options.include_archived = true
	Talo.leaderboards.get_entries(leaderboard_internal_name, funcref(self,"_load_entries_callback"), options)

func _load_entries_callback(res, callbacks):
	if not res:
		prints("no response")
		return
	var entries = res["body"]["entries"]
	_build_entries(entries)

func _on_submit_pressed():
	if Talo.has_identity():
		prints("player is identified")
		_submit_leaderboard_entry()
	else:
		prints("player needs to be identified")
		var username = $MarginContainer/VBoxContainer/LineEditUserName.text
		Talo.players.identify("username", username, [funcref(self, "_submit_leaderboard_entry")])

func _submit_leaderboard_entry(_previous_response=null, _callbacks=null):
	prints("actually submitting the score")
	randomize()
	var score := randi() % 1000
	Talo.leaderboards.add_entry(leaderboard_internal_name, score, {"player_name": $MarginContainer/VBoxContainer/LineEditPlayerName.text})	
	Talo.players.update({"player_name": $MarginContainer/VBoxContainer/LineEditPlayerName.text})

func add_entry_response(res):
	# this is the signal after submitting connected from a signal instead of a callback
	if res:
		_load_entries()
