extends Node2D


var background_speed = 0

func _ready():
	animate()

var animation_time = 2.0

func animate():
	$Weapons.hide()
	$Icons.hide()
	$Turtle.modulate = Color.transparent
	$CanvasLayer/Label.modulate = Color.transparent
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_callback($AudioStreamPlayer, "play")
	tween.tween_interval(1.0*animation_time)
	tween.chain()
	tween.tween_property($Turtle, "modulate", Color.white, 2.0*animation_time)
	tween.chain()
	tween.tween_callback($Turtle, "play", ["die", true])
	tween.tween_callback($Turtle, "play", ["idle", false]).set_delay(1.0)
	tween.tween_property($WhiteColorRect, "modulate", Color.transparent, 2.0*animation_time)
	tween.chain()
	tween.tween_callback($Icons, "show")
	tween.tween_property($Icons, "radius", 100.0, 2.0*animation_time).from(300.0)
	tween.chain()
	tween.tween_interval(4.0)
	tween.chain()
	tween.tween_property($Icons, "radius", 0.0, 0.5*animation_time)
	tween.tween_property($WhiteColorRect, "modulate", Color.white, 0.5*animation_time)
	tween.tween_property($Icons, "modulate", Color.transparent, 0.5*animation_time)
	tween.chain()
	tween.tween_callback($Icons, "hide")
	tween.tween_callback($VFX, "hide")
	tween.tween_callback($EvolveParallaxBackground, "hide")
	tween.tween_callback($Weapons, "show")
	tween.tween_property($WhiteColorRect, "modulate", Color.transparent, 0.5*animation_time)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_method(self, "set_speed", 0, 256, 4.0*animation_time)
	tween.tween_property($"%Camera2D", "position", Vector2(192,0), 3.0*animation_time).set_delay(1.0)
	tween.tween_property($"%Camera2D", "zoom", Vector2(1,1), 3.0*animation_time).set_delay(1.0)
	tween.chain()
	tween.tween_callback($Turtle, "play", ["walk"])
	tween.tween_property($Turtle, "position", Vector2(0,64), 0.5*animation_time)
	tween.tween_property($Weapons, "position", Vector2(0,64), 0.5*animation_time)
	tween.chain()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback($Turtle, "play", ["walk"])
	tween.tween_property($Turtle, "position", Vector2(128,-128), 1.0*animation_time)
	tween.tween_property($Weapons, "position", Vector2(128,-128), 1.0*animation_time)
	tween.tween_property($"%Camera2D", "position", Vector2(192,-128), 1.0*animation_time)
	tween.tween_property($WhiteColorRect, "modulate", Color.white, 0.25*animation_time).set_delay(0.75*animation_time)
	tween.tween_property($Turtle, "modulate", Color.transparent, 0.25*animation_time).set_delay(0.75*animation_time)
	tween.tween_property($CanvasLayer/Label, "modulate", Color.white, 0.25*animation_time).set_delay(0.75*animation_time)
	tween.chain()
	tween.tween_interval(1.0*animation_time)
	tween.chain()
	tween.tween_callback(get_tree(), "change_scene", ["res://scenes/gameplay/level2.tscn"])

	

func set_speed(speed):
	background_speed = speed

func _process(delta):
	$EvolveParallaxBackground.scroll_base_offset = Vector2.RIGHT.rotated(Game.elapsed*3) * 256
	$ParallaxBackground.scroll_base_offset.x += -background_speed*delta
