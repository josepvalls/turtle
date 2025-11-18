extends Node2D

const animation_time = 1.0
func activate(score):
	$PanelContainer/ScoreLabel.text = "+" + str(score)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", Vector2(0,-64), animation_time).as_relative()
	tween.tween_property(self, "modulate", Color.transparent, animation_time * 0.5).set_delay(animation_time * 0.5)
	tween.chain()
	tween.tween_callback(self, "queue_free")
	
	
