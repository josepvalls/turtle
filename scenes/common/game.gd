# Game autoload. Use `Game` global variable as a shortcut to access features.
# Eg: `Game.change_scene("res://scenes/gameplay/gameplay.tscn)`
extends Node

signal display_settings_changed(viewport_drawing)

onready var transitions = get_node_or_null("/root/Transitions")

var pause_scenes_on_transitions = false
var prevent_input_on_transitions = true
var scenes: Scenes
var size: Vector2


func _enter_tree() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS # needed to make "prevent_input_on_transitions" work even if the game is paused
	_register_size()
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	if transitions:
		transitions.connect("transition_started", self, "_on_Transitions_transition_started")
		transitions.connect("transition_finished", self, "_on_Transitions_transition_finished")
#	add_script("Utils", "utils", "res://addons/game-template/utils.gd")


func _ready() -> void:
	scenes = load("res://scenes/common/scenes.gd").new()
	scenes.name = "Scenes"
	get_node("/root/").call_deferred("add_child", scenes)
	_ready_settings()
	_ready_audio()


func _on_screen_resized():
	_register_size()


func _register_size():
	size = get_viewport().get_visible_rect().size


func change_scene(new_scene: String, params = {}):
	if "stop_music_fade_time" in params:
		stop_music(params["stop_music_fade_time"])
	if not Utils.file_exists(new_scene):
		printerr("Scene file not found: ", new_scene)
		return

	if OS.has_feature('HTML5'): # See https://github.com/crystal-bit/godot-game-template/wiki/2.-Features#single-thread-vs-multihtread
		scenes.change_scene_background_loading(new_scene, params) # single-thread
	else:
		scenes.change_scene_multithread(new_scene, params) # multi-thread


# Restart the current scene
func restart_scene():
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene(scene_data.path, scene_data.params)


# Restart the current scene, but use given params
func restart_scene_with_params(override_params):
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene(scene_data.path, override_params)


# Prevents all inputs while a graphic transition is playing.
func _input(_event: InputEvent):
	if transitions and prevent_input_on_transitions and transitions.is_displayed():
		# prevent all input events
		get_tree().set_input_as_handled()


func _on_Transitions_transition_started(anim_name):
	if pause_scenes_on_transitions:
		get_tree().paused = true


func _on_Transitions_transition_finished(anim_name):
	if pause_scenes_on_transitions:
		get_tree().paused = false


func add_script(script_name, self_prop_name, script_path):
	var new_script: Node = load(script_path).new()
	new_script.name = script_name
	call_deferred("add_script_node", new_script, self_prop_name)


func add_script_node(new_node, prop_name):
	get_tree().root.add_child(new_node)
	self[prop_name] = new_node


var elapsed := 0.0
func _process(delta):
	elapsed += delta
	process_sfx_pool()

### Settings

var SETTINGS_FILE_PATH = "user://settings.tres"
var settings = ResourceLoader.load("res://scripts/settings.tres") as Settings

func _ready_settings():
	load_settings_file()
	#set_audio_bus(settings.music_volume, "Music")
	#set_audio_bus(settings.sfx_volume, "SFX")

func load_settings_file():
	if (ResourceLoader.exists(SETTINGS_FILE_PATH)):
		settings = ResourceLoader.load(SETTINGS_FILE_PATH)
	if not Game.settings.user_name or Game.settings.user_name == "":
		Game.settings.user_name = Talo.players.generate_identifier()
		write_settings()
	if not Game.settings.player_name or Game.settings.player_name == "" or Game.settings.player_name == "???" or Game.settings.player_name == "Anonymous":
		randomize()
		var things = ["Loggerhead","Green turtle","Hawksbill","Leatherback","Flatback","Galápagos","Tiger shark","Flattened musk","Painted turtle","Red-bellied cooter","Gopher tortoise","Peninsula cooter","Stripe-necked turtle","Forest turtle","Coahuilan box turtle","Peacock softshell turtle","African softshell turtle","Gopher tortoise","Arrau turtle","Pig-nosed turtle","Black wood turtle","Balkan terrapin"]
		Game.settings.player_name = things.pick_random()
		Game.settings.player_name += " " + str(randi() % 100)
			

func write_settings():
	ResourceSaver.save(SETTINGS_FILE_PATH, settings)

func set_audio_bus(percent: float, bus_name: String):
	prints("set_audio_bus", bus_name, percent)
	settings.set_bus_volume_percent(bus_name, percent)
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear2db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


### Audio

const default_stream0 := preload("res://bgm/Sea Turtle_s Retribution.ogg")
const default_stream1 := preload("res://bgm/Sea Turtle_s Requiem.ogg")

var music_stream_player: AudioStreamPlayer
var current_music_track = -1
func play_music(track: int=0):
	if track != current_music_track:
		var current_position = music_stream_player.get_playback_position()
		if track == 0:
			music_stream_player.stream = default_stream0
			music_stream_player.play()
		elif track == 1:
			music_stream_player.stream = default_stream1
			music_stream_player.play()
		current_music_track = track
	
func stop_music(transition: float=0.0):
	current_music_track = -1
	if transition > 0.0:
		var tween = create_tween()
		tween.tween_property(music_stream_player, "volume_db", -80, transition)
		tween.tween_callback(music_stream_player, "stop")
		tween.tween_callback(music_stream_player, "set", ["volume_db", 0.0])
	else:
		music_stream_player.stop()
		

var num_players = 6
var available = []
var queue = []
func ready_sfx_pool():
	for i in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.connect("finished",self, "_on_stream_finished", [player])
		player.bus = "SFX"


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)

func play_sfx(sound_path, priority=10):
	if len(queue)>=num_players and priority < 10:
		return
	queue.append(sound_path)

func process_sfx_pool():
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		var sound = queue.pop_front()
		if not sound:
			return
		available[0].stream = load(sound)
		available[0].play()
		available.pop_front()


func _ready_audio():
	music_stream_player = AudioStreamPlayer.new()
	music_stream_player.bus = "Music"
	add_child(music_stream_player)
	ready_sfx_pool()
	
