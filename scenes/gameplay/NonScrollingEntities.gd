extends Node2D

var dropship = null
func drone_spawner():
	if dropship == null:
		var i = $"../Templates/Dropship".custom_duplicate()
		i.fire_elapsed = -1.0
		i.current_movement = EnemyArea2D.MOVEMENT.NONE
		i.position = Vector2(-128,-128)
		i.target = GameManager.player
		i.projectile_template = $"../Templates/Projectile2"
		add_child(i)
		i.connect("explosion", get_parent(), "explosion")
		i.activate()
		if get_parent().score > 1000:
			i.fire_cooldown = 1.3333
		dropship = i
		for j in 32:
			var projectile = $"../Templates/Projectile2".duplicate()
			projectile.position = Vector2(680, 26*j - 256)
			projectile.speed = 0.0
			projectile.get_node("Barrel").rotation = 0.0
			$"../Entities".add_child(projectile)
			projectile.activate(2)

		
	var r = randf()
	if randf() < 0.5:
		var i = [
			$"../Templates/DroneEnemyArea2D",
			$"../Templates/DroneEnemyArea2D",
			$"../Templates/DroneEnemyArea2D2"
			].pick_random().custom_duplicate()
		i.fire_elapsed = -7.0
		i.target = GameManager.player
		i.target_position_bias = Vector2(128,-128)
		i.projectile_template = $"../Templates/Projectile"
		add_child(i)
		i.connect("explosion", get_parent(), "explosion")
		i.activate()
	else:
		var i = [
			$"../Templates/SwimmerEnemyArea2D",
			$"../Templates/SwimmerEnemyArea2D",
			$"../Templates/SwimmerEnemyArea2D2",
			].pick_random().custom_duplicate()
		i.fire_elapsed = -7.0
		i.target = GameManager.player
		i.target_position_bias = Vector2(128,128)
		i.projectile_template = $"../Templates/Projectile"
		add_child(i)
		i.connect("explosion", get_parent(), "explosion")
		i.activate()		
	var tween = create_tween()
	var delay = 7.0
	delay -= get_parent().score / 1000
	delay = clamp(delay, 1, 7.0)
	tween.tween_callback(self, "drone_spawner").set_delay(delay)

var dropship_direction = 1
func _process(delta):
	if not is_instance_valid(dropship):
		dropship = null
		return
	if dropship:
		dropship.position.x += dropship_direction * delta * 128
		if dropship.position.x > 512 and dropship_direction > 0:
			dropship_direction *= -1
		if dropship.position.x < -128 and dropship_direction < 0:
			dropship_direction *= -1
		

