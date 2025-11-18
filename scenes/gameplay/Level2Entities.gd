extends Node2D
export var active := true

func jellyfish_spawner():
	var i = $"../Templates/Jellyfish".duplicate()
	add_child(i)
	i = $"../Templates/Jellyfish".duplicate()
	add_child(i)
	i.position += Vector2(randf()*256, randf()*256)
	var tween = create_tween()
	tween.tween_callback(self, "jellyfish_spawner").set_delay(1.0)

func obstacle_spawner():
	var obstacles = [$"../Templates/Barge", $"../Templates/Platform", $"../Templates/Driller"]
	var o := obstacles.pick_random().duplicate() as Node2D
	add_child(o)
	if o.has_method("activate"):
		o.activate()
	var tween = create_tween()
	tween.tween_callback(self, "obstacle_spawner").set_delay(5.0)


func _process(delta):
	if not active:
		return
	for i in get_children():
		i.position.x -= 256 * delta
		if i.position.x < -1500 and not i.is_in_group("keep"):
			i.queue_free()
		
		
