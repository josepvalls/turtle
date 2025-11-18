class_name TaloClient extends Node

# automatically updated with a pre-commit hook
const TALO_CLIENT_VERSION = "0.36.1"

var _base_url: String

func _init(base_url: String):
	_base_url = base_url
	name = "Client"
	
func make_request(method:int, url: String, body: Dictionary, headers: Array, continuity: bool, callbacks):
	var continuity_timestamp = TaloTimeUtils.get_timestamp_msec()

	var full_url := url if continuity else _build_full_url(url)
	var all_headers := headers if continuity else _build_headers(headers)
	var request_body := "" if body.keys().empty() else to_json(body)
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = 5
	http_request.name = "%s %s" % [method, url]
	

	prints("make_request", full_url, method)
	http_request.request(full_url, all_headers, false, method, request_body)
	if not Talo.settings.offline_mode:
		http_request.connect("request_completed", self, "_http_request_completed", [callbacks])
		
func _http_request_completed(result, status, headers, response_body, callbacks):
	var callback = null
	if callbacks:
		callback = callbacks.pop_front()
	prints("_http_request_completed", status, callback.function if callback else "No callback")
	var response_text = response_body.get_string_from_utf8()
	var json_data = {}
	if response_text:
		json_data = parse_json(response_text)

	if result != HTTPRequest.RESULT_SUCCESS:
		json_data["message"] = "Request failed: result %s, details: https://docs.godotengine.org/en/stable/classes/class_httprequest.html#enum-httprequest-result" % result

	var ret := {
		status = status,
		body = json_data
	}
	
	if callback:
		if callbacks:
			callback.call_func(ret, callbacks)
		else:
			callback.call_func(ret)

func _build_headers(extra_headers: Array = []) -> Array:
	var headers: Array = [
		"Authorization: Bearer %s" % Talo.settings.access_key,
		"Content-Type: application/json",
		"Accept: application/json",
		"X-Talo-Dev-Build: %s" % ("1" if Talo.settings.is_debug_build() else "0"),
		"X-Talo-Include-Dev-Data: %s" % ("1" if Talo.settings.is_debug_build() else "0"),
		"X-Talo-Client: godot:%s" % TALO_CLIENT_VERSION
	]

	if Talo.current_alias:
		headers.append_array([
			"X-Talo-Player: %s" % Talo.current_player,
			"X-Talo-Alias: %s" % Talo.current_alias
		])

	headers.append_array(extra_headers)

	return headers

func _build_full_url(url: String) -> String:
	return "%s%s%s" % [
		Talo.settings.api_url,
		_base_url,
		url.replace(" ", "%20")
	]
