extends VBoxContainer


func _ready():
	$"%HSliderSFX".connect("value_changed", Game, "set_audio_bus", ["SFX"])
	$"%HSliderMusic".connect("value_changed", Game, "set_audio_bus", ["Music"])
	$LineEdit.connect("text_changed", Game.settings, "set_player_name")
	$"%HSliderMusic".value = Game.settings.music_volume
	$"%HSliderSFX".value = Game.settings.sfx_volume
	$LineEdit.text = Game.settings.player_name
	$"%ResetButton".connect("pressed", self, "reset_game")
	$"%DisableViewports".connect("pressed", self, "disable_viewports")
	
func reset_game():
	if $"%ResetCheckBox".pressed:
		GameManager.reset_game()
	
func refresh():
	$LineEdit.text = Game.settings.player_name
	
func disable_viewports():
	prints("viewport drawing", $"%DisableViewports".pressed)
	Game.emit_signal("display_settings_changed", $"%DisableViewports".pressed)
	

