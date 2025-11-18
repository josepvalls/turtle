extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_callback(self, "dump")
	tween.tween_property($BarrelRow, "position", Vector2(790,-125+32), 2.0).from(Vector2(815,-125+32))
	#tween.tween_interval(1.0)
	tween.set_loops(100)


func dump():
	var barrel := $FallingBarrel.duplicate() as RigidBody2D
	add_child(barrel)
	barrel.show()
	barrel.mode = RigidBody2D.MODE_RIGID
	barrel.set_collision_layer_bit(0, true)
	barrel.set_collision_mask_bit(0, true)
	barrel.contact_monitor = true
