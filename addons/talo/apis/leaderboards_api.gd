class_name LeaderboardsAPI extends TaloAPI
## An interface for communicating with the Talo Leaderboards API.
##
## This API is used to read and update leaderboards in your game. Leaderboards are used to track player scores and rankings.
##
## @tutorial: https://docs.trytalo.com/docs/godot/leaderboards

## Get a list of all the entries that have been previously fetched or created for a leaderboard.
var cached_entries = null
func get_cached_entries(internal_name: String) -> Array:
	return cached_entries


## Get a list of entries for a leaderboard. The options include "page", "alias_id", "include_archived", "prop_key", "prop_value", "start_date" and "end_date" for additional filtering.
func get_entries(internal_name: String, callback=null, options := GetEntriesOptions.new()):
	var url := "/%s/entries?page=%s"
	var url_data := [internal_name, options.page]

	if options.alias_id != -1:
		url += "&aliasId=%s"
		url_data.append(options.alias_id)

	if options.include_archived:
		url += "&withDeleted=1"

	if options.prop_key != "":
		url += "&propKey=%s"
		url_data.append(options.prop_key)

		if options.prop_value != "":
			url += "&propValue=%s"
			url_data.append(options.prop_value)

	if options.start_date != "":
		url += "&startDate=%s"
		url_data.append(options.start_date)

	if options.end_date != "":
		url += "&endDate=%s"
		url_data.append(options.end_date)

	client.make_request(HTTPClient.METHOD_GET, url % url_data, {}, [], false, [funcref(self, "get_entries_callback"), callback])

signal entries_response(entries)
func get_entries_callback(res, callbacks):
	var callback = null
	if callbacks:
		callback = callbacks.pop_front()
	match res.status:
		200:
			cached_entries = res.body.entries
			emit_signal("entries_response", res.body.entries)
			if callback:
				callback.call_func(res, callbacks)
		_:
			emit_signal("entries_response", null) 
			if callback:
				callback.call_func(null, callbacks)

## Add an entry to a leaderboard.
func add_entry(internal_name: String, score: float, props_dict = {}):
	#if Talo.identity_check() != OK:
	#	return null
	#var props_array = TaloEntityWithProps.from_dict(props_dict).get_serialized_props()
	var props_array = TaloPropUtils.serialise_prop_array(TaloPropUtils.dictionary_to_prop_array(props_dict))
	client.make_request(HTTPClient.METHOD_POST, "/%s/entries" % internal_name, {
		score = score,
		props = props_array
	}, [], false, [funcref(self, "add_entry_callback")])

signal add_entry_response(entry)
func add_entry_callback(res):
	prints("add_entry_callback", res)
	match res.status:
		200:
			emit_signal("add_entry_response", res)
		_:
			emit_signal("add_entry_response", null)

class GetEntriesOptions:
	var page =  0
	var alias_id =  -1
	var include_archived =  false
	var prop_key =  ""
	var prop_value =  ""
	var start_date =  ""
	var end_date =  ""
