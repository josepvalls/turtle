extends Line2D

var points_ = []
export (NodePath) var tug_to_path = null
var tug_to = null
func _ready():
	points_ = points
	if tug_to_path:
		tug_to = get_node_or_null(tug_to_path)
	tug_line()

func tug_line():
	var idx = randi() % (len(points_)-1)
	idx += 1
	set_point_position(idx, points_[idx]+Vector2(randi()%6-2, 0))
	var tween = create_tween()
	if not tug_to == null:
		set_point_position(0, to_local(tug_to.global_position))
		set_point_position(1, (points[0]+points[1])*0.5)
		tween.tween_interval(.25)
		#yield(get_tree().create_timer(0.25), "timeout")
	else:
		tween.tween_interval(.5)
		#yield(get_tree().create_timer(0.5), "timeout")
	tween.tween_callback(self, "tug_line")
