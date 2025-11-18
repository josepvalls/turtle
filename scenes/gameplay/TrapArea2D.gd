extends Area2D
class_name TrapArea

export (NodePath) var ui_path
export (NodePath) var turtle_path
export var activate_on_touch = false
export var activate_not_kill = true


func _ready():
	if activate_on_touch:
		connect("area_entered", self, "release")


func release(_nothing=null):
	if ui_path:
		var node = get_node_or_null(ui_path)
		if node:
			var tween = create_tween()
			tween.tween_property(node, "modulate", Color.transparent, 0.5)
			tween.tween_callback(node, "queue_free")
	if turtle_path:
		if activate_not_kill:
			get_node_or_null(turtle_path).activate(GameManager.player.get_tail())
		else:
			get_node_or_null(turtle_path).die()
