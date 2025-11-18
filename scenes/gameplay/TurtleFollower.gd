extends Node2D

export (NodePath) var target_node_path
var target = null
var last_target_position = null
var path = []
export var active = false
var moving = false
var desired_position = Vector2.ZERO
var max_speed = 0
export var random_speed = 0.4
export var move_while_inactive = true

func _ready():
	target = get_node_or_null(target_node_path)
	desired_position = position
	
func activate(target_):
	GameManager.player.tail.append(self)
	target = target_
	active = true

func _process(delta):
	if active:
		position = position.move_toward(desired_position + Vector2(sin(Game.elapsed*random_speed*2), sin(Game.elapsed*random_speed)) * 16 * random_speed,target.max_speed*delta*0.5)
	elif move_while_inactive:
		position = position.move_toward(desired_position + Vector2(pow(sin(Game.elapsed*random_speed*3),2), 0)*16,200*delta*0.5)
	
	if not target or not active:
		return

	max_speed = target.max_speed
	if not last_target_position:
		last_target_position = target.position
	elif last_target_position and (target.position-last_target_position).length_squared() > 400:
		path.append(target.position)
		last_target_position = target.position
		
	if path and not moving and desired_position.distance_squared_to(target.position) > 3600:
		moving = true
		var tween = create_tween()
		var dest = path.pop_front()
		var dist = (dest - position).length()
		tween.tween_property(self, "desired_position", dest, dist / max_speed)
		tween.tween_callback(self, "set", ["moving", false])
		
	var s = get_node_or_null("Trash")
	if s:
		s.rotation = sin(Game.elapsed*random_speed) * PI * 0.25
	if moving:
		$Sprite.play("walk")
	else:
		$Sprite.play("idle")
	if target.position.x < position.x:
		$Sprite.flip_h = true
		if s:
			s.position.x = 11
			s.scale.x = -1
	else:
		$Sprite.flip_h = false
		if s:
			s.position.x = -11
			s.scale.x = 1
	
func die():
	if $Sprite.animation!="die":
		$Sprite.play("die")
		var air = get_node_or_null("Particles2D")
		if air:
			air.emitting = true
	#var tween = create_tween()
	#tween.tween_property($Trash, "position", Vector2(0,24), 0.8)
