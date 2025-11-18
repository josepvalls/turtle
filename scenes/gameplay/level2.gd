extends Node2D


export var skip_intro = false
export var active = true
var food_bar_alert
var air_bar_alert

const leaderboard_internal_name = "turtle2"

var score = 0.0
func _ready():
	GameManager.player_projectiles = self
	GameManager.enemy_projectiles = self
	GameManager.scrolling_projectiles = $Entities
	GameManager.explosion_manager = self
	GameManager.player = $Player
	
	food_bar_alert = $"%ProgressBarFood".get_stylebox("bg").duplicate()
	air_bar_alert = $"%ProgressBarFood".get_stylebox("bg").duplicate()
	$"%ProgressBarAir".add_stylebox_override("bg", air_bar_alert)
	$"%ProgressBarFood".add_stylebox_override("bg", food_bar_alert)
	update_ui()
	
	$CanvasLayer/ColorRect1.hide()
	$CanvasLayer/ColorRect2.hide()
	start_game_labels = [$CanvasLayer/WhiteColorRect, $CanvasLayer/CenterContainer/Label1, $CanvasLayer/CenterContainer/Label2, $CanvasLayer/CenterContainer/Label3]
	if skip_intro:
		start_game()
	else:
		ready_set_go()
	$"%LeaderboardVBoxContainer".hide()
	$"%Retry".connect("pressed", get_tree(), "reload_current_scene")
	$"%MainMenu".connect("pressed", get_tree(), "change_scene", ["res://scenes/gameplay/Title.tscn"])
	setup_leaderboard()
	
func setup_leaderboard():
	#$"%LineEdit".text = Game.settings.player_name
	$"%Submit".connect("pressed", self, "submit_pressed")
	Talo.leaderboards.connect("add_entry_response", self, "add_entry_response")
	$"%LineEdit".text = Game.settings.player_name
	load_leaderboard()
	
func load_leaderboard():
	var options = Talo.leaderboards.GetEntriesOptions.new()
	options.page = 0
	options.include_archived = true
	Talo.leaderboards.get_entries(leaderboard_internal_name, funcref(self,"_load_entries_callback"), options)

func _load_entries_callback(res, callbacks):
	if not res:
		prints("no response")
		return
	var entries = res["body"]["entries"]

	if not entries:
		prints("no entries")
		return
	var out = ""
	var entry_count = 0
	for entry in entries:
		entry_count += 1
		if entry_count > 10: break
		entry["position"] = entries.find(entry)
		var player_name = str(entry["playerAlias"]["identifier"])
		if entry["playerAlias"]["player"]["props"]:
			var props_dict = TaloPropUtils.array_to_dictionary(entry["playerAlias"]["player"]["props"])
			if "player_name" in props_dict and props_dict["player_name"]:
				player_name = props_dict["player_name"]

		out += " " + player_name
		out += ": " + str(floor(entry["score"]*10))
		out += "\n"
	$"%LeaderboardEntries".text = out.strip_edges()
	
func ready_set_go():
	Game.settings.unlocked_levels = 2
	Game.write_settings()
	$CanvasLayer/WhiteColorRect.show()
	for i in start_game_labels:
		i.modulate = Color.transparent
	$CanvasLayer/WhiteColorRect.modulate = Color.white
	var tween = create_tween()
	#tween.set_parallel(true)
	for i in start_game_labels:
		tween.tween_property(i, "modulate", Color.white, 0.5)
		tween.tween_property(i, "modulate", Color.transparent, 0.5)
	tween.tween_callback(self, "start_game")
		
var start_game_labels = []
func start_game():
	Game.play_music(0)
	for i in start_game_labels:
		i.hide()
	$Player.can_action = true
	$Entities.jellyfish_spawner()
	$Entities.obstacle_spawner()
	$NonScrollingEntities.drone_spawner()


var health = 100.0
var food = 50.0
var air = 100.0
func _physics_process(delta):
	health = clamp(health, 0, 100)
	food = clamp(food, 0, 100)
	air = clamp(air, 0, 100)
	if air <=0:
		health -= 5*delta
	if food <=0:
		health -= 5*delta
	if health <= 0:
		game_over()
	update_ui()
	if active:
		score += delta
		$ParallaxBackground.scroll_base_offset.x += -256*delta
		$ParallaxBackground2.scroll_base_offset.x += -256*delta
	
func game_over():
	Game.stop_music(1.0)
	if not active:
		return
	active = false
	$Entities.active = false
	GameManager.player.can_action = false
	$CanvasLayer/WhiteColorRect.show()
	$CanvasLayer/WhiteColorRect.modulate = Color.transparent
	var tween = create_tween()
	tween.tween_property($CanvasLayer/WhiteColorRect, "modulate", Color.white, 2.0)
	tween.tween_callback(self, "game_over_leaderboard")

func game_over_leaderboard():
	#for i in $Entities.get_children():
	#	i.queue_free()
	#for i in $NonScrollingEntities.get_children():
	#	i.queue_free()
	$Entities.queue_free()
	$NonScrollingEntities.queue_free()
		
	if GameManager.max_score < score:
		GameManager.max_score = score
		GameManager.max_score_submitted = false
		$"%SubmitContainer".show()
	else:
		$"%SubmitContainer".hide()
	$"%maxScoreLabel".text = str(floor(GameManager.max_score*10))
	$"%LeaderboardVBoxContainer".show()
	
func submit_pressed():
	$"%SubmitContainer".hide()
	GameManager.max_score_submitted = true
	Game.settings.set_player_name($"%LineEdit".text)
	Game.write_settings()
	if Talo.has_identity():
		prints("player is identified")
		_submit_leaderboard_entry()
	else:
		prints("player needs to be identified")
		var username = Game.settings.user_name
		Talo.players.identify("username", username, [funcref(self, "_submit_leaderboard_entry")])
func _submit_leaderboard_entry(_previous_response=null, _callbacks=null):
	prints("actually submitting the score")
	Talo.leaderboards.add_entry(leaderboard_internal_name, score, {"player_name": Game.settings.player_name})	
	Talo.players.update({"player_name": Game.settings.player_name})

func add_entry_response(res):
	# this is the signal after submitting connected from a signal instead of a callback
	if res:
		load_leaderboard()
	

func update_ui():
	$"%ProgressBarHealth".value = health
	$"%ProgressBarFood".value = food
	var v = sin(Game.elapsed*15)*0.5+0.5
	if food > 0:
		food_bar_alert.border_color = Color.black
		food_bar_alert.bg_color = Color.black
	else:
		food_bar_alert.bg_color = Color(v,0,0,1)
		food_bar_alert.border_color = food_bar_alert.bg_color
	$"%ProgressBarAir".value = air
	if air > 0:
		air_bar_alert.border_color = Color.black
		air_bar_alert.bg_color = Color.black
	else:
		air_bar_alert.bg_color = Color(v,0,0,1)
		air_bar_alert.border_color = air_bar_alert.bg_color
	$"%ScoreLabel".text = str(floor(score*10))
	
func die_offscreen():
	game_over()
	
func explosion(entity: Node2D):
	if entity is Projectile:
		$Entities/Burst.position = entity.position
		$Entities/Burst.emitting = true
		$Entities/Burst.restart()
		score += 10
	else:
		if entity.position.y < 0:
			$Entities/Explosion.position = entity.position
			$Entities/Explosion.emitting = true
			$Entities/Explosion.restart()
		else:
			$Entities/Death.position = entity.position
			$Entities/Death.emitting = true
			$Entities/Death.restart()
		score += 100
	pass
