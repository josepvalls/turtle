extends KinematicBody2D
class_name Player
	
var areas_in_touch = 0

export (Color) var projectile_color:=Color("a7f2ee")
export var can_action := false
var velocity = Vector2.ZERO
export var acceleration := 1600.0
export var max_speed := 400.0
export var chill := false
var invulnerable_timeout = 0.0
signal take_hit

export var fire_cooldown := 0.05
var fire_elapsed := 0.0
var air_elapsed := 0.0
var projectile_template1 = preload("res://prefabs/Projectile.tscn")
var projectile_template2 = preload("res://prefabs/ProjectileLong.tscn")
var projectile_template3 = preload("res://prefabs/ProjectileKnife.tscn")

func _ready():
	if chill:
		$Camera2DOffset.position = Vector2.ZERO
		$Camera2DOffset/Camera2D.zoom = Vector2.ONE * 0.5
		$MouthArea2D.connect("area_entered", self, "do_eat")
	else:
		pass
		#$Area2D.connect("area_entered", self, "do_eat")
	$Area2D.connect("area_entered", self, "area_control", [+1])
	$Area2D.connect("area_exited", self, "area_control", [-1])
	$Sprite.connect("animation_finished", self, "animation_finished")
	

func do_eat(area):
	if area is Jellyfish:
		Game.play_sfx("res://sfx/Eating.wav")
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(area, "position", position, 0.5)
		tween.tween_property(area, "rotation", TAU, 0.5)
		tween.tween_property(area, "scale", Vector2.ZERO, 0.5)
		tween.chain()
		tween.tween_callback(area, "eaten")
		get_parent().food += 25
	elif area is TrapArea:
		area.release()

func area_control(area, count):
	#prints("area_control", area, count)
	if area is Jellyfish:
		do_eat(area)
		return
	if area is TrapArea:
		return
	areas_in_touch += count
	if areas_in_touch <= 0:
		$Sprite.modulate = Color.white
	else:
		$Sprite.modulate = Color.red

	if area is ProjectileArea2D:
		area.get_parent().explode()
		take_damage()
		return
		
	if count > 0 and invulnerable_timeout <= 0.0:
		take_damage()
		#Game.play_sfx("res://assets/sfx/playerExplosion.wav")
	else:
		pass
		#Game.play_sfx("res://assets/sfx/hitHurt.wav")
		

func play_death():
	$Sprite.play("die")

func take_damage():
	if not chill:
		invulnerable_timeout = 1.0
		get_parent().health -= 10.0
		emit_signal("take_hit")

func process_needs(delta):
	if areas_in_touch > 0:
		get_parent().health -= 5.0 * delta
	
	if not chill:
		if abs(position.y)<8:
			$Splash.activate()
		else:
			$Splash.deactivate()
	
	if position.y < 8:
		get_parent().air += 50.0 * delta
		$Particles2D.emitting = false
	else:
		if chill:
			get_parent().air -= 2.0 * delta
		else:
			get_parent().air -= 10.0 * delta
			$Particles2D.emitting = get_parent().air < 25
	if chill:
		air_elapsed += delta
		if position.y > 32:
			if air_elapsed >= 0.0:
				$Particles2D.emitting = true
				air_elapsed -= 12.0
			$Camera2DOffset/Camera2D/Particles2D.emitting = true
		else:
			$Camera2DOffset/Camera2D/Particles2D.emitting = false

func process_actions(delta):
	fire_elapsed += delta
	if invulnerable_timeout > 0.0:
		invulnerable_timeout -= delta
	if invulnerable_timeout <= 0.0:
		invulnerable_timeout = 0.0
		$Shield.modulate = Color(0,0,0,0)
		if areas_in_touch > 0:
			take_damage()
	else:
		$Shield.modulate = Color(1,1,1,sin(Game.elapsed*25)*0.5+0.5)
		if areas_in_touch > 0:
			$Sprite.modulate = Color(1,sin(Game.elapsed*25)*0.5+0.5, sin(Game.elapsed*25)*0.5+0.5)
		else:
			$Sprite.modulate = Color.white


	if can_action and Input.is_action_pressed("do_a"):
		do_fire()
	

export var auto_fire_enabled = false
var projectile_idx = 0
func do_fire(force=false):
	if chill:
		if $Sprite.animation == "eat":
			can_action = false
			return
		velocity = Vector2.ZERO
		$Sprite.frame = 0
		$Sprite.play("eat")
		#$MouthArea2D.set_deferred("monitoring", true)
		var tween = create_tween()
		tween.tween_callback($MouthArea2D/CollisionShape2D, "set_deferred", ["disabled", false]).set_delay(0.4)
		tween.tween_callback($MouthArea2D/CollisionShape2D, "set_deferred", ["disabled", true]).set_delay(0.2)
		return
	if not auto_fire_enabled:
		return
	if fire_elapsed >= 0.0 or force:
		get_parent().food -= 0.1
		projectile_idx += 1
		#Game.play_sfx("res://laserShoot.wav")
		var projectile := projectile_template2.instance() as Projectile
		GameManager.player_projectiles.add_child(projectile)		
		#projectile.modulate = projectile_color
		projectile.position = $Weapons/Machinegun/Node2D.global_position
		projectile.rotation = 0
		projectile.direction = Vector2.RIGHT
		projectile.activate(1)
		if projectile_idx % 3 == 0:
			Game.play_sfx("res://sfx/Gunshot (Turtle).wav")
			if get_parent().food > 25:
				projectile = projectile_template1.instance() as Projectile
				GameManager.player_projectiles.add_child(projectile)		
				projectile.position = $Weapons/Side1/Node2D.global_position
				projectile.rotation = 0
				projectile.direction = Vector2.RIGHT.rotated(-PI*0.25)
				projectile.activate(1)
				projectile = projectile_template1.instance() as Projectile
				GameManager.player_projectiles.add_child(projectile)		
				projectile.position = $Weapons/Side2/Node2D.global_position
				projectile.rotation = 0
				projectile.direction = Vector2.RIGHT.rotated(PI*0.25)
				projectile.activate(1)
				projectile = projectile_template1.instance() as Projectile
				GameManager.player_projectiles.add_child(projectile)		
				projectile.position = $Weapons/Gun/Node2D.global_position
				projectile.rotation = 0
				projectile.direction = Vector2.LEFT
				projectile.activate(1)
		if get_parent().food > 75 and projectile_idx % 7 == 0:
			for i in 7:
				projectile = projectile_template3.instance() as Projectile
				GameManager.player_projectiles.add_child(projectile)		
				projectile.position = $Knife/Knife.global_position
				projectile.rotation = -0.5 + 1.0/7*(i+0.5)
				projectile.direction = Vector2.RIGHT.rotated(projectile.rotation)
				projectile.activate(1)

		fire_elapsed = - fire_cooldown


var facing_direction = 1
func _physics_process(delta):
	process_needs(delta)
	process_actions(delta)
	if can_action:
		# var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction := Vector2.ZERO
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")
		direction = direction.normalized()
		
		if not chill:
			pass
			#$Knife.rotation += direction.y * delta * 0.7853975 * 6
			#$Knife.rotation = (1.0-delta) * $Knife.rotation + delta * 0.1 * $Knife.rotation
			#$Knife.rotation = clamp($Knife.rotation, -0.5, 0.5)
		
		
		#velocity = speed * direction
		velocity = velocity.move_toward(max_speed * direction, acceleration*delta)
		if direction != Vector2.ZERO:
			if velocity.length_squared() < 100:
				velocity = direction * 50
		else:
			if position.y < -1:
				velocity.y += 50.0

		
		if velocity.length_squared() > 0.0:
			$Sprite.play("walk")
			if position.y < -1:
				get_parent().food -= 25.0 * delta
				if get_parent().food <= 0:
					velocity.y += 75 #* delta
			else:
				get_parent().food -= 1.0 * delta
		else:
			if position.y < -1:
				get_parent().food -= 15.0 * delta
				velocity.y += 25 #* delta
				if get_parent().food <= 0:
					velocity.y += 75 #* delta
					
		if position.y < -1:
			velocity.limit_length(max_speed*0.5)
		else: 
			if abs(velocity.y) > max_speed:
				velocity.y *= 0.5

				
					
		move_and_slide(velocity)


	if chill:
		if position.y < 0.0:
			position.y = 0.0
			velocity.y = 0.0
			
		if abs(velocity.x)>1 and sign(velocity.x) != facing_direction:
			facing_direction = sign(velocity.x)
			scale.x = -1
	else:
		if can_action and position.x <= -128:
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				print("Collided with: ", collision.collider.name)
				get_parent().die_offscreen()

		#position.y = clamp(position.y, -384, 384)
		position.y = clamp(position.y, -368, 368)
		position.x = clamp(position.x, -128,512)
	
func animation_finished():
	if $Sprite.animation == "eat" and chill:
		$MouthArea2D/CollisionShape2D.set_deferred("disabled", true)
		can_action = true
	elif $Sprite.animation == "die":
		return
	$Sprite.play("idle")

var tail = []
func get_tail():
	if tail:
		return tail[-1]
	else:
		return self
	
