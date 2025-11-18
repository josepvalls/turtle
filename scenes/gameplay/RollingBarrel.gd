extends Sprite


func _process(delta):
	rotation -= delta * clamp(get_parent().speed * 0.1, 0, 10)
