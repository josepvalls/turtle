extends RigidBody2D


var hit = 0
var current_body = null
func _ready():
	connect("body_entered", self, "body_entered")
	current_body = $"1"


func body_entered(body):
	if body is Player:
		get_parent().get_parent().health -= 10
	if not hit:
		#prints("first hit")
		hit += 1
	elif hit == 1:
		hit += 1
		current_body.hide()
		current_body = [$"2", $"3"].pick_random()
		current_body.show()
	else:
		current_body.hide()
		current_body = [$"2", $"3", $"4"].pick_random()
		current_body.show()

		set_deferred("contact_monitor", false)
		disconnect("body_entered", self, "body_entered")

var velocity = Vector2(0,100)
func _physics_process(delta):
	pass
	#if abs(position.x - GameManager.player.position.x) > 500:
	#	return
	#else:
	#	if last_y <= 0 and position.y > 0:
	#		Game.play_sfx("res://sfx/Splash.wav")
	#	last_y = position.y
