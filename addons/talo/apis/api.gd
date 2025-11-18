class_name TaloAPI extends Node

var client: TaloClient

func set_url(base_path: String):
	name = "Talo%s" % base_path
	client = TaloClient.new(base_path)
	add_child(client)
