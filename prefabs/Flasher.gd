extends CanvasItem


func _process(delta):
	if visible:
		#pass
		modulate = Color(1,1,1,sin(Game.elapsed*10))
