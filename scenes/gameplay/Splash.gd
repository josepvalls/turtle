extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var is_active = false

func activate(force=false):
	if force or not is_active:
		if GameManager.player.global_position.distance_squared_to(global_position) < 102400:
			Game.play_sfx("res://sfx/Splash.wav")
		
	is_active = true
	$RocketEffect02.show()
	$Particles2D2.emitting = true
	$Particles2D3.emitting = true
	
func deactivate():
	is_active = false
	$RocketEffect02.hide()
	$Particles2D2.emitting = false
	$Particles2D3.emitting = false

func _process(delta):
	pass
