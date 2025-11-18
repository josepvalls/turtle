extends Node2D


export var num = 50
export var radius_w = 150
export var radius_h = 50
export var speed = 15.0
export var anim = "a"

var fishes = []
var directions = []
var speeds = []

func _ready():
	for i in num:
		var f = $AnimatedSprite.duplicate()
		add_child(f)
		f.show()
		f.play(anim)
		fishes.append(f)
		f.position = Vector2(randf()*radius_w*1.9-radius_w,randf()*radius_h*2-radius_h)
		directions.append([-1,1].pick_random())
		speeds.append((0.5 + randf()*0.5) * speed)

func _process(delta):
	for i in len(fishes):
		if abs(fishes[i].position.x) >= radius_w:
			directions[i]*=-1
			speeds[i] = (0.5 + randf()*0.5) * speed
		fishes[i].flip_h = directions[i] < 0
		fishes[i].position.x += speeds[i] * delta * directions[i]
