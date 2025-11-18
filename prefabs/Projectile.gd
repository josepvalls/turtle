extends Node2D
class_name Projectile


export var lifetime := 2.0
export var direction = Vector2.UP
export var speed = 750
export var active = false
export var pulse = false
export var pulse_time = 0.2
export var destructible = false
export var slow_down_in_water = false
var velocity = Vector2.ZERO
var current_faction = 0

func _ready():
	hide()

var last_y = -1000.0

func _process(delta):
	if not active:
		return
	lifetime -= delta
	if lifetime <= 0:
		explode()
	if (position - GameManager.player.position).length_squared() >= 490000: # 700
		queue_free()
	velocity = speed*direction
	translate(velocity*delta)
	if slow_down_in_water:
		if position.y > 0:
			speed -= 600*delta
			speed = clamp(speed, 0, 1000)
			
	#if last_y <= 0 and position.y > 0:
	#	Game.play_sfx("res://sfx/Splash.wav")
	#last_y = position.y
	
func bounce_circular():
	position = position.limit_length(349)
	direction = direction.bounce(position.normalized())
	modulate *= 0.7
	speed *= 0.8
	
func explode():
	active = false
	var particles: Particles2D = get_node_or_null("Particles2D")
	if not pulse and not particles:
		queue_free()
	elif not pulse and particles:
		particles.emitting = true
		var tween = create_tween()
		tween.tween_property($Sprite, "modulate", Color(1,1,1,0), 0.15)
		tween.tween_callback(self, "queue_free")

		

func activate(faction=1):
	show()
	active = true
	current_faction = faction
	match faction:
		1:
			$ProjectileArea2D.collision_layer = 8
			$ProjectileArea2D.collision_mask = 4
		2:
			$ProjectileArea2D.collision_layer = 16
			$ProjectileArea2D.collision_mask = 2
			if destructible:
				$ProjectileArea2D.connect("area_entered", self, "area_entered")
				$ProjectileArea2D.collision_mask += 8
				$ProjectileArea2D.collision_layer += 256
				
				$ProjectileArea2D.set_deferred("monitoring", true)

var health = 5
func area_entered(area):
	health -= 1
	if health <= 0:
		GameManager.explosion_manager.explosion(self)
		queue_free()
	
