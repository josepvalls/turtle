extends Area2D
class_name Jellyfish

func eaten():
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_interval(15.0)
	tween.tween_callback(self, "reset")
	
func reset():
	$CollisionShape2D.set_deferred("disabled", false)
	show()
	scale = Vector2.ONE
	rotation = 0
	
