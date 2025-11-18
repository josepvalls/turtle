class_name TaloProp extends Object

var key: String
var value

func _init(key: String, value):
	self.key = key
	self.value = str(value) if value != null else value

func to_dictionary() -> Dictionary:
	return { key = key, value = value }
