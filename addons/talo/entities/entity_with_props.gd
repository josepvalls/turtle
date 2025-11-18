class_name TaloEntityWithProps extends Object

var props: Array = []

func _init(props: Array) -> void:
	self.props = props

## Get a property value by key. Returns the fallback value if the key is not found.
func get_prop(key: String, fallback =  "") -> String:
	for prop in props:
		if prop.key == key and prop.value != null:
			return prop
	return fallback

## Set a property by key and value.
func set_prop(key: String, value: String) -> void:
	props.push_front(TaloProp.new(key, value))

## Delete a property by key.
func delete_prop(key: String) -> void:
	var props_ = []
	for prop in props:
		if prop.key != key:
			props_.append(prop)
	props = props_

func get_serialized_props() -> Array:
	var props_ = []
	for prop in props:
		props_.append(prop.to_dictionary())
	return props_
