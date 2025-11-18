extends Control


func _ready():
	title = "Leaderboard"
	$Title.text = title
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$PlayButton1.connect("pressed", self, "end_stage")
	$"%Submit".connect("pressed", self, "submit_score")
	$"%Discard".connect("pressed", $FinalLayer, "hide")
	#GameManager.get_scores()
	$Refreshing.hide()
	if GameManager.final_score_available and not GameManager.final_score_submitted:
		$FinalLayer/VBoxOptions/LineEdit.text = Game.settings.player_name
		$FinalLayer/VBoxOptions/Score.text = str(GameManager.get_final_score())
		$FinalLayer.show()
	else:
		$FinalLayer.hide()
		

func submit_score():
	var player_name = $FinalLayer/VBoxOptions/LineEdit.text
	Game.settings.set_player_name(player_name)
	Game.write_settings()
	GameManager.final_score_submission()
	$FinalLayer.hide()
	Game.play_sfx("res://assets/sfx/BOSS PROJECTILE SHOOT_1A_TS.wav")
	GameManager.get_scores()
	$Refreshing.show()
	

func _process(delta):
	$RichTextLabel.bbcode_text = GameManager.get_scores_cache
	
var current_text = 0
export(String) var title = ""
export(Array, String) var text = [""]
export(String) var next_scene = null
export(String) var display = ""
export(int) var next_slide = 0

func end_stage():
	Game.play_sfx("res://assets/sfx/BOSS PROJECTILE SHOOT_1A_TS.wav")
	Game.change_scene("res://scenes/menu/menu.tscn", {})
