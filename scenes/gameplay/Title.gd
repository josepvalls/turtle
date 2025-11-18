extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var custom_layout = preload("res://default_bus_layout.tres")
	AudioServer.set_bus_layout(custom_layout)
	
	
	$"%Button1".connect("pressed", self, "select_level", ["res://scenes/gameplay/level1.tscn"])
	if Game.settings.unlocked_levels > 1:
		$"%Button2".connect("pressed", self, "select_level", ["res://scenes/gameplay/level2.tscn"])
		$"%Button2".disabled = false
		$"%Button3".connect("pressed", self, "select_level", ["res://scenes/gameplay/leaderboard.tscn"])
	else:
		$"%Button2".hide()
		$"%Button3".hide()


func select_level(level):
	Game.play_sfx("res://sfx/Menu Selection.wav")
	var tween = create_tween()
	tween.set_parallel(true)
	$CanvasLayer/WhiteColorRect.show()
	$CanvasLayer/WhiteColorRect.modulate = Color.transparent
	tween.tween_property($CanvasLayer/WhiteColorRect, "modulate", Color.white, 1.0)
	tween.tween_property($AudioStreamPlayer, "volume_db", -80, 0.6)
	tween.tween_callback($AudioStreamPlayer, "stop").set_delay(0.6)
	tween.tween_callback(get_tree(), "change_scene", [level]).set_delay(1.0)

func _process(delta):
	$ParallaxBackground.scroll_base_offset.x += 16*delta
	#$"Node2D/2".position.x = sin(Game.elapsed * 0.1) * 50 - 50
