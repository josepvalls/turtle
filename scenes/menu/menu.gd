extends Control

var sfx_playing := false
var default_level: Button
func _ready():
	$Button.connect("pressed", self, "_on_PlayButton_pressed", ["res://scenes/gameplay/level1.tscn"])

func _on_PlayButton_pressed(scene) -> void:
	var tween = create_tween()
	tween.tween_property($AudioStreamPlayer, "volume_db", -80, 0.5)
	var params = {
		show_progress_bar = true,
		"slide": 0,
	}
	#Game.write_settings()
	#Game.change_scene(scene, params)
	get_tree().change_scene("res://scenes/gameplay/level1.tscn")

func randomize_colors():
	var circles = [
		$GridContainer/CenterContainer11/TextureRect4, $GridContainer/CenterContainer/TextureRect5, $GridContainer/CenterContainer2/TextureRect11, $GridContainer/CenterContainer3/TextureRect9, $GridContainer/CenterContainer4/TextureRect8, $GridContainer/CenterContainer5/TextureRect7, $GridContainer/CenterContainer6/TextureRect6, $GridContainer/CenterContainer7/TextureRect10, $GridContainer/CenterContainer8/TextureRect, $GridContainer/CenterContainer9/TextureRect2, $GridContainer/CenterContainer10/TextureRect2, $GridContainer/CenterContainer11/TextureRect4, $GridContainer/CenterContainer13/TextureRect5, $GridContainer/CenterContainer14/TextureRect4, $GridContainer/CenterContainer15/TextureRect5
	]
	var colors = [
		Color("ff60ff"),
		Color("3cc03e"),
		Color("e2511e"),
		Color(0.1,0.1,0.1)
	]
	var tween = create_tween()
	tween.set_parallel(true)
	for i in circles:
		#i.modulate = Color.black
		tween.tween_property(i, "modulate", Color.black, 0.455)
	circles.shuffle()
	tween.chain()
	colors.shuffle()
	for idx in len(colors):
		#circles[idx].modulate = colors[idx]
		tween.tween_property(circles[idx], "modulate", colors[idx], 0.455)
	#yield(get_tree().create_timer(0.455*4), "timeout")
	tween.chain()
	tween.tween_callback(self, "randomize_colors").set_delay(0.455*2)
	#call_deferred("randomize_colors")
	
