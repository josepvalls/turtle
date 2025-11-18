extends Node

# fire player
var player#: Player
var player_projectiles: Node2D
var enemy_projectiles: Node2D
var scrolling_projectiles: Node2D
var explosion_manager: Node2D

var max_score = 0
var max_score_submitted = true

signal update_ui
var get_top_scores_cache = "Loading leaderboard...\n(If you are playing for the jam on itch.io,\nYou may need to use the top-right score)"
var get_top_scores_i = 0
func get_top_scores():
	pass




func _on_get_entries_completed(success, entries):
	prints("_on_get_entries_completed", success)
	if success:
		var bb = ""
		for entry in entries:
			bb += entry.name + ": " + str(entry.score) + "\n"
		get_top_scores_cache = bb.strip_edges()
		emit_signal("update_ui")
	
