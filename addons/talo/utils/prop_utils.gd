class_name TaloPropUtils extends Reference

static func dictionary_to_array(props: Dictionary) -> Array:
	var ret: Array = []
	return ret

static func dictionary_to_prop_array(props: Dictionary) -> Array:
	var ret: Array = []
	for i in props:
		ret.append(TaloProp.new(i, props[i]))
	return ret
	
static func array_to_dictionary(props: Array) -> Dictionary:
	var ret: Dictionary = {}
	for i in props:
		ret[i["key"]] = i["value"]
	return ret

static func serialise_prop_array(props: Array) -> Array:
	var ret: Array = []
	for prop in props:
		ret.append(prop.to_dictionary())
	return ret
