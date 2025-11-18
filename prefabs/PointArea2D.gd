extends Area2D

var idx = -1
var delay_timeout = 0.0
var current_coords: Vector3
var frozen_coords: Vector3

func _ready():
	connect("area_entered", self, "area_entered")
	
func area_entered(area):
	if area is ProjectileArea2D:
		self.delay_timeout = 2.0
		frozen_coords = current_coords
		frozen_coords += Vector3(randf()* 0.1 - 0.05, randf()*0.1-0.05, 0)
		frozen_coords += Vector3(
			area.get_parent().direction.x * 0.5, 
			area.get_parent().direction.y * -0.5, 
			0.0
			)
		area.get_parent().explode()
