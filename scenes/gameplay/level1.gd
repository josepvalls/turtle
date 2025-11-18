extends Node2D


var food_bar_alert
var air_bar_alert


func _ready():
	$PoisonParticles2D.emitting = false
	$PoisonParticles2D.hide()
	GameManager.player_projectiles = self
	GameManager.enemy_projectiles = self
	GameManager.player = $Player
	food_bar_alert = $"%ProgressBarFood".get_stylebox("bg").duplicate()
	air_bar_alert = $"%ProgressBarFood".get_stylebox("bg").duplicate()
	$"%ProgressBarAir".add_stylebox_override("bg", air_bar_alert)
	$"%ProgressBarFood".add_stylebox_override("bg", food_bar_alert)
	update_ui()
	$CanvasLayer/ColorRect1.hide()
	$CanvasLayer/ColorRect2.hide()
	call_deferred("start_game")

func start_game():
	Game.play_music(1)

var health = 100.0
var food = 50.0
var air = 100.0

func _process(delta):
	health = clamp(health, 0, 100)
	food = clamp(food, 0, 100)
	air = clamp(air, 0, 100)
	if air <=0:
		health -= 5*delta
	if food <=0:
		health -= 5*delta
	if health <= 0:
		game_over()
	update_ui()
	
func game_over():
	if not GameManager.player.can_action:
		return
	Game.stop_music(0.5)
	GameManager.player.can_action = false
	GameManager.player.play_death()
	if $PoisonParticles2D.visible:
		# move to next level
		$CanvasLayer/ColorRect2.show()
		$CanvasLayer/ColorRect2.modulate = Color.transparent
		var tween = create_tween()
		tween.tween_property($CanvasLayer/ColorRect2, "modulate", Color.white, 2.0)
		#tween.tween_callback(get_tree(), "reload_current_scene").set_delay(2.0)
		tween.tween_callback(get_tree(), "change_scene", ["res://scenes/gameplay/level12.tscn"]).set_delay(2.0)

	else:
		$CanvasLayer/ColorRect1.show()
		$CanvasLayer/ColorRect1.modulate = Color.transparent
		var tween = create_tween()
		tween.tween_property($CanvasLayer/ColorRect1, "modulate", Color.white, 2.0)
		tween.tween_callback(get_tree(), "reload_current_scene").set_delay(2.0)
		#tween.tween_callback(Game, "change_scene", ["res://scenes/gameplay/level1.tscn"]).set_delay(2.0)
		#Game.change_scene()

func update_ui():
	$"%ProgressBarHealth".value = health
	$"%ProgressBarFood".value = food
	var v = sin(Game.elapsed*15)*0.5+0.5
	if food > 5:
		food_bar_alert.border_color = Color.black
		food_bar_alert.bg_color = Color.black
	else:
		food_bar_alert.bg_color = Color(v,0,0,1)
		food_bar_alert.border_color = food_bar_alert.bg_color
	$"%ProgressBarAir".value = air
	if air > 5:
		air_bar_alert.border_color = Color.black
		air_bar_alert.bg_color = Color.black
	else:
		air_bar_alert.bg_color = Color(v,0,0,1)
		air_bar_alert.border_color = air_bar_alert.bg_color

