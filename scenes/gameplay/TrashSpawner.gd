extends Node2D


var trash = []
var pieces = []
export var is_driller = false
export var water_speed = 30
export var forward_speed = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	pieces = get_children()
	if not is_driller:
		activate()
	
	
func activate():
	var tween = create_tween()
	tween.tween_callback(self, "dump")
	tween.tween_interval(0.5)
	tween.set_loops(0)


func dump():
	var piece := pieces.pick_random().duplicate() as Node2D
	add_child(piece)
	piece.set_meta("rotation_mult", randf() - 0.5)
	piece.position.x = randf() * 32
	if is_driller:
		piece.position.y += randf() * 32
		piece.set_meta("forward_speed", forward_speed + randf() * 10)
		
	piece.position.y += randf() * 10
	piece.rotation = randf() * TAU
	trash.append(piece)
	
func _process(delta):
	for i in Array(trash):
		if is_driller:
			i.position.x -= i.get_meta("forward_speed") * delta
			i.set_meta("forward_speed", i.get_meta("forward_speed") * (1.0-delta))
		if i.position.y < 0.0:
			i.position.y += water_speed* 3 * delta
		elif i.position.y < 500:
			i.position.y += water_speed * delta
			i.rotation += delta * i.get_meta("rotation_mult") * PI
		else:
			i.queue_free()
			trash.erase(i)
