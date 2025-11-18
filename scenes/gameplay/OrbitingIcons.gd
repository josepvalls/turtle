extends Node2D

var icons = []
var speed = 1.0
var radius = 300.0
func _ready():
	icons = get_children()
	icons.shuffle()


func _process(delta):
	var angle = TAU / len(icons)
	for idx in len(icons):
		var i = icons[idx]
		i.position = Vector2.RIGHT.rotated(angle * idx + Game.elapsed * speed) * radius
