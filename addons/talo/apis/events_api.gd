class_name EventsAPI extends TaloAPI
## An interface for communicating with the Talo Events API.
##
## This API is used to track events in your game. Events are used to measure user interactions such as button clicks, level completions and other kinds of game interactions.
##
## @tutorial: https://docs.trytalo.com/docs/godot/events

var _queue := []
var _min_queue_size := 10
var _max_queue_size := 1000

var _events_to_flush := []
var _lock_flushes := false
var _flush_attempted_during_lock := false

const VERSION_SCRIPT_PATH = "res://version.gd"

signal events_updated()

func _get_game_version() -> String:
	var version_script = preload(VERSION_SCRIPT_PATH)
	return version_script.VERSION

func _build_meta_props() -> Array:
	return [
		TaloProp.new("META_OS", OS.get_name()),
		TaloProp.new("META_GAME_VERSION", _get_game_version()),
	]

## Track an event with optional props (key-value pairs) and add it to the queue of events ready to be sent to the backend. If the queue reaches the minimum size, it will be flushed.
func track(name: String, props: Dictionary = {}) -> void:
	var final_props := _build_meta_props()
	final_props.append_array(TaloPropUtils.dictionary_to_prop_array(props))

	_queue.push_back({
		name = name,
		props = TaloPropUtils.serialise_prop_array(final_props),
		timestamp = TaloTimeUtils.get_timestamp_msec()
	})
	
	emit_signal("events_updated")

	if _queue.size() >= _min_queue_size:
		flush()

## Flush the current queue of events. This is called automatically when the queue reaches the minimum size.
func flush() -> void:
	if _queue.size() == 0:
		return
		
	if not Talo.has_identity():
		prints("player needs to be identified")
		var username = "unidentified"
		Talo.players.identify("username", username, [funcref(self, "flush")])
		return

	if _lock_flushes:
		_flush_attempted_during_lock = true
		return

	_lock_flushes = true
	_events_to_flush.append_array(_queue)
	_queue.clear()

	client.make_request(HTTPClient.METHOD_POST, "/", { events = _events_to_flush }, [], false, [funcref(self, "flush_callback")])

func flush_callback(res):
	_lock_flushes = false

	match res.status:
		200:
			pass
		_:
			# enqueue events to be flushed again
			_queue.append_array(_events_to_flush)
		
	_events_to_flush.clear()
	emit_signal("events_updated")

	if _flush_attempted_during_lock:
		_flush_attempted_during_lock = false
		flush()

## Clear the queue of events waiting to be flushed.
func clear_queue() -> void:
	_queue.clear()
	_events_to_flush.clear()
	_lock_flushes = false
	_flush_attempted_during_lock = false
