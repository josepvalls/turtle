class_name PlayersAPI extends TaloAPI
## An interface for communicating with the Talo Players API.
##
## This API is used to identify players and update player data.
##
## @tutorial: https://docs.trytalo.com/docs/godot/identifying

## Emitted when a player has been identified.
signal identified(player)

## Emitted when identification starts.
signal identification_started()

## Emitted when identification fails.
signal identification_failed()

## Emitted after calling clear_identity().
signal identity_cleared()

func _ready() -> void:
	#Talo.connection_restored.connect(_on_connection_restored)
	pass

func _handle_identify_success(alias, socket_token =  ""):
	Talo.current_player = alias["player"]["id"]
	Talo.current_alias = alias["id"]
	
func clear_identity():
	Talo.current_player = ""
	Talo.current_alias = ""
	

## Identify a player using a service (e.g. "username") and identifier (e.g. "bob").
func identify(service: String, identifier: String, callbacks=null):
	emit_signal("identification_started")
	if not callbacks:
		callbacks = []
	callbacks.push_front(funcref(self, "identify_callback"))
	client.make_request(HTTPClient.METHOD_GET, "/identify?service=%s&identifier=%s" % [service, identifier], {}, [], false, callbacks)

func identify_callback(res, callbacks=null):
	prints("identify_callback", res.body)
	var callback: FuncRef = null
	if callbacks:
		callback = callbacks.pop_front()

	match res.status:
		200:
			var alias = res.body.alias
			#alias.write_offline_alias()
			_handle_identify_success(alias, res.body.socketToken)
			if callback:
				if callbacks:
					callback.call_func(true, callbacks)
				else:
					callback.call_func()

		_:
			emit_signal("identification_failed")
			emit_signal("identified", null)
			if callback:
				if callbacks:
					callback.call_func(null, callbacks)
				else:
					callback.call_func()


## Flush and sync the player's current data with Talo.
func update(player_dict, callbacks=null):
	if not callbacks:
		callbacks = []
	callbacks.push_front(funcref(self, "update_callback"))
	if Talo.identity_check() != OK:
		return false
		
	#var player_props_array = TaloEntityWithProps.from_dict(player_dict).get_serialized_props()
	var player_props_array = TaloPropUtils.serialise_prop_array(TaloPropUtils.dictionary_to_prop_array(player_dict))

	client.make_request(HTTPClient.METHOD_PATCH, "/%s" % Talo.current_player, { props = player_props_array }, [], false, callbacks)

func update_callback(res, callbacks=null):
	match res.status:
		200:			
			var p = TaloPlayer.new()
			p.id = res.body.player
			return p
		_:
			return null

signal find_player_id(player)
## Get a player by their ID.
func find(player_id: String):
	client.make_request(HTTPClient.METHOD_GET, "/%s" % player_id, {}, [], false, funcref(self, "find_callback"))
	
func find_callback(res):
	match res.status:
		200:
			emit_signal("find_player_id", res.body.player)
		_:
			emit_signal("find_player_id", null)

## Generate a mostly-unique identifier.
func generate_identifier() -> String:
	var time_hash := str(TaloTimeUtils.get_timestamp_msec()).sha256_text()
	var size := 12
	var split_start := RandomNumberGenerator.new().randi_range(0, time_hash.length() - size)
	return time_hash.substr(split_start, size)
