extends Node

## Emitted when Talo has finished setting up internal dependencies.
signal init_completed()

## Emitted when internet connectivity is lost.
signal connection_lost()

## Emitted when internet connectivity is restored.
signal connection_restored()

var current_alias: String
var current_player: String

var settings: TaloSettings

var players#: PlayersAPI # TODO resolve cyclyc references
var events: EventsAPI
var leaderboards: LeaderboardsAPI
var health_check: HealthCheckAPI

func _ready() -> void:
	_load_config()
	_load_apis()

	if Talo.settings.handle_tree_quit:
		get_tree().set_auto_accept_quit(false)
	pause_mode = Node.PAUSE_MODE_PROCESS
	emit_signal("init_completed")
	
func _notification(what: int):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			_do_flush()
			if Talo.settings.handle_tree_quit:
				get_tree().quit()
		NOTIFICATION_WM_FOCUS_OUT:
			_do_flush()
	
func _load_config() -> void:
	settings = TaloSettings.new()

func _load_apis() -> void:
	players = load("res://addons/talo/apis/players_api.gd").new()  # TODO resolve cyclyc references
	players.set_url("/v1/players")
	events = preload("res://addons/talo/apis/events_api.gd").new()
	events.set_url("/v1/events")
	leaderboards = preload("res://addons/talo/apis/leaderboards_api.gd").new()
	leaderboards.set_url("/v1/leaderboards")
	health_check = preload("res://addons/talo/apis/health_check_api.gd").new()
	health_check.set_url("/v1/health-check")

	for api in [
		players,
		events,
		leaderboards,
		health_check,
	]:
		add_child(api)

func has_identity() -> bool:
	return current_alias != ""

func identity_check(should_error = true):
	if not has_identity():
		if should_error:
			printerr("You need to identify a player using Talo.players.identify() before doing this")
		return ERR_UNAUTHORIZED

	return OK

func is_offline() -> bool:
	return settings.offline_mode

func _do_flush() -> void:
	if identity_check(false) == OK:
		events.flush()
