extends Node


func file_exists(path) -> bool:
	var f = File.new()
	return f.file_exists(path)


func reparent_node(node: Node2D, new_parent, update_transform = false, deferred = false):
	var previous_xform = node.global_transform
	node.get_parent().remove_child(node)
	if deferred:
		new_parent.call_deferred("add_child", node)
	else:
		new_parent.add_child(node)
	if update_transform:
		node.global_transform = previous_xform
