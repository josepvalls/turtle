class_name TaloPlayer extends Object #TaloEntityWithProps
## @tutorial: https://docs.trytalo.com/docs/godot/player-props

var id: String
var aliases: Array = []
var groups: Array = []
var _offline_data: Dictionary

func _init():
	pass
	#super._init(props)
	#update_from_raw_data(data)

## Update the player from raw JSON data.
func update_from_raw_data(data: Dictionary) -> void:
	#for prop_key in data.props:
	#	props[prop_key] = TaloProp.new(prop_key, props[prop_key])

	id = data.id

	_offline_data = data

## Set a property by key and value. Optionally sync the player (default true) with Talo.
func set_prop(key: String, value: String, update =  true) -> void:
	pass
	
## Delete a property by key. Optionally sync the player (default true) with Talo.
func delete_prop(key: String, update =  true) -> void:
	pass
	
## Get the offline data for the player.
func get_offline_data() -> Dictionary:
	return _offline_data

## Get the first alias that matches an optional service.
func get_alias(service =  ""):
	if service == "":
		return null if aliases.empty() else aliases[0]
	for alias in aliases:
		if alias.service == service:
			return alias
	return null
