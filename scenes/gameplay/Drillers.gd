extends Node2D


var positions = []
var drillers = []
var active = false
func _ready():
	drillers = [$Driller1, $Driller2]
	for i in drillers:
		positions.append(i.position)
	$ActivateArea2D.connect("body_entered", self, "activate")


func activate(body):
	if not active and body is Player and position.x > -1000:
		active = true
		var tween = create_tween()
		$DiggingTrash.activate()
		$DiggingTrash2.activate()
		$"%Camera2D".apply_shake()
		$"../SeaFloorDecor".hide()
		$"../UnderwaterDecor".hide()
		for i in GameManager.player.tail:
			tween.tween_property(i, "position", $"../Characters/Turtle5".position, 3.0)
			i.active = false
		$"../PoisonParticles2D".show()
		$"../PoisonParticles2D".emitting = true
		$"../PoisonParticles2D/Area2D3/CollisionShape2D".set_deferred("disabled", false)
		
		Game.stop_music(2.0)
		tween.tween_callback(Game, "play_music", [0]).set_delay(2.5)
		tween.tween_interval(40)
		tween.tween_callback(get_parent(), "game_over")

func _process(delta):
	if active:
		drillers[0].position = positions[0] + Vector2.RIGHT.rotated(Game.elapsed*4) * 24
		drillers[1].position = positions[1] + Vector2.RIGHT.rotated(-Game.elapsed*4) * 24
		position.x -= 25 * delta
		if randf() < 0.01:
			$"%Camera2D".apply_shake()
		if position.x < -1000:
			active = false
			
