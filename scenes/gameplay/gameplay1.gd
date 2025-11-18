extends Node2D

var enemies_until_next_wave = []
var enemies_coordinated = []
var enemies_coordinated_explosive = []
var enemies_simultaneous_explosive = []
var enemies_simultaneous = []
var enemy_queue = []
var enemies_initialized = false
var coordinated_bombs_enabled = 0
var simultaneous_bombs_enabled = 0
export var enemies_until_next_world = 70
export var gravity_direction := Vector2.ZERO
var time_elapsed = 0.0
func _ready():
	GameManager.player_projectiles = $PlayerProjectiles
	GameManager.enemy_projectiles = $EnemyProjectiles
	init_player_health()
	$WinLayer/WinOverlay.hide()
	$Player.connect("take_hit", self, "take_hit")
	$"%Main Menu".connect("pressed", Game, "change_scene", ["res://scenes/menu/menu.tscn"])
	$AudioStreamPlayer.connect("finished", self, "audio_finished")

func pre_start(params):
	prints("pre_start", params)


export var current_wave = 0

func start():
	prints("start")
	Bridge.platform.send_message("gameplay_started")
	yield(get_tree().create_timer(0.5), "timeout")
	$AudioStreamPlayer.play()
	$Player.can_action = true
	
	next_wave()

func next_world_unlock():
	$"%FinalScoreLabel".text = $"%ScoreLabel".text + " seconds"
	Game.settings.unlocked_levels = max(current_world + 1, Game.settings.unlocked_levels)
	#SilentWolf.Scores.persist_score(Game.settings.player_name, -time_elapsed, "w"+str(current_world))
	var leaderboardId = "shapes_v2_l" + str(current_world)
	Bridge.leaderboards.set_score(leaderboardId, -time_elapsed, funcref(self, "_on_set_score_completed"))

	Game.write_settings()
	get_tree().paused = true
	Game.play_sfx("res://assets/sfx/win.wav")
	$WinLayer/WinOverlay.show()
	pass

func advance_next_wave():
	if enemies_initialized:
		current_wave += 1
		next_wave()

export var current_world = 1
func next_wave():
	match current_world:
		1:
			next_wave_green()
		2:
			next_wave_pink()
		3:
			next_wave_red()
		4:
			next_wave_blue()
		5:
			next_wave_yellow()
var total_enemy_count_id = 0
func next_wave_pink():
	enemies_initialized = false
	var template: EnemyArea2D
	match current_wave:
		0:
			template = $Templates/EnemyArea2Dv0
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			init_enemies(template, 5, false, PI*1.99, 350,350,0.0,5,32)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			init_enemies(template, 5, false, PI*1.5, 351,351,0.0,5,32)
		1:
			template = $Templates/EnemyArea2Dv0
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			init_enemies(template, 5, false, TAU+TAU/10, 230,230,0.0,5,32)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			init_enemies(template, 5, false, PI*1.5, 351,351,0.0,5,32)
		2:
			template = $Templates/EnemyArea2Dv0
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			init_enemies(template, 5, false, TAU, 115,115,0.0,5,32)
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			init_enemies(template, 5, false, TAU+TAU/10, 230,230,0.0,5,32)
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			init_enemies(template, 5, false, TAU, 350,350,0.0,5,32)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			init_enemies(template, 5, false, PI*0.125, 351,351,0.0,5,32)
		3:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			init_enemies(template, 5, false, PI*1.5, 351,351,0.0,5,32)
			bomb_area(4)
			template = $Templates/EnemyArea2Dv3
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			coordinated_bombs_enabled = 1
			template.move_speed = 80
			template.health = 25
			init_enemies(template, 1, false, TAU, 377, 377, 3.0, 2, 50)
		4:
			template = $Templates/EnemyArea2Dv3
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			bomb_area(4)
			coordinated_bombs_enabled = 4
			template.move_speed = 80
			template.health = 25
			init_enemies(template, 1, false, TAU, 377, 377, 3.0, 2, 50)
		5:
			template = $Templates/EnemyArea2Dv3
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			bomb_area(3, false)
			simultaneous_bombs_enabled = 3
			template.move_speed = 80
			template.health = 25
			init_enemies(template, 1, false, TAU, 377, 377, 3.0, 2, 50)
		6:
			template = $Templates/EnemyArea2Dv3
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			simultaneous_bombs_enabled = 3
			template.move_speed = 80
			template.health = 50
			init_enemies(template, 1, false, TAU, 377, 377, 3.0, 2, 50)
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 180
			template.health = 1
			init_enemies(template, 15, false, TAU, 375, 375, 3.0, 15, 150)
		7:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 200
			template.health = 2
			init_enemies(template, 15, false, TAU, 375, 375, 3.0, 30, 15)
			init_enemies(template, 15, false, TAU+TAU/30, 375, 375, 3.0, 30, 15)
			init_enemies(template, 1, false, TAU*1.01, 375, 375, 3.0, 30, 15)

	prints("initialized enemies", len(enemy_queue), len($"%EnemiesRemaining".get_parent().get_children()))
	attack_count = 0

func next_wave_blue():
	enemies_initialized = false
	var template: EnemyArea2D
	match current_wave:
		0:
			template = $Templates/EnemyArea2Dv1
			#template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.current_attack_aim = EnemyArea2D.AIM.WAY4
			template.hit_jitter = 0
			template.hit_impact = 0
			template.move_speed = 200
			template.health = 10
			init_enemies(template, 16, false, PI, 330, 330, 3.0, 4, 320)
		1:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.current_attack_aim = EnemyArea2D.AIM.WAY4
			template.hit_jitter = 10
			template.hit_impact = 16
			template.move_speed = 200
			template.health = 20
			#init_enemies(template, 10, false, TAU+TAU/20, 375, 375, 3.0, 30, 15)
			init_enemies(template, 16, false, TAU, 375, 375, 3.0, 4, 320)
			#init_enemies(template, 1, false, PI, 375, 375, 3.0, 30, 15)
			var points = [Vector3(0, 0.178411, 0.467086), Vector3(0.288675, 0.288675, 0.288675), Vector3(-0.288675, 0.288675, 0.288675), Vector3(0.178411, 0.467086, 0), Vector3(-0.178411, 0.467086, 0), Vector3(0.467086, 0, 0.178411), Vector3(0.467086, 0, -0.178411), Vector3(0.288675, 0.288675, -0.288675), Vector3(0.288675, -0.288675, -0.288675), Vector3(0, -0.178411, -0.467086), Vector3(0, 0.178411, -0.467086), Vector3(-0.288675, -0.288675, -0.288675), Vector3(-0.467086, 0, -0.178411), Vector3(-0.288675, 0.288675, -0.288675), Vector3(-0.178411, -0.467086, 0), Vector3(-0.288675, -0.288675, 0.288675), Vector3(-0.467086, 0, 0.178411), Vector3(0, -0.178411, 0.467086), Vector3(0.178411, -0.467086, 0), Vector3(0.288675, -0.288675, 0.288675)]

	prints("initialized enemies", len(enemy_queue), len($"%EnemiesRemaining".get_parent().get_children()))
	attack_count = 0


func next_wave_yellow():
	enemies_initialized = false
	var template: EnemyArea2D
	match current_wave:
		0:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.HINT
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.hit_jitter = 0
			template.hit_impact = 0
			template.staggered_time_on_hit = 0.0
			template.staggered_time_on_shot = 0.0
			template.move_speed = 800
			template.health = 20
			var ring = init_enemies(template, 8, false, TAU, 0, 0, 3.0, 16, 320)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.hit_jitter = 10
			template.hit_impact = 16
			template.move_speed = 100
			template.health = 3
			var controller = init_enemies(template, 1, false, TAU, 0, 0, 3.0, 16, 320)[0]
			var orbital_controller = $OrbitalController.duplicate()
			controller.register_child(orbital_controller)
			orbital_controller.activate(ring)
			

	prints("initialized enemies", len(enemy_queue), len($"%EnemiesRemaining".get_parent().get_children()))
	attack_count = 0


func bomb_area(count, coordinated=true):
	var template = $Templates/EnemyArea2Dv0
	template.current_movement = EnemyArea2D.MOVEMENT.NONE
	template.current_attack = EnemyArea2D.ATTACK.PULSE
	template.coordinated = coordinated
	init_enemies(template, count, true, TAU, 50,300,0.0,5,32)

func next_wave_green():
	enemies_initialized = false
	var template: EnemyArea2D
	match current_wave:
		0:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.move_speed = 40
			template.coordinated = false
			init_enemies(template, 1, false, PI, 375,375,0.0,1,32)
		1:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.move_speed = 80
			template.coordinated = true
			init_enemies(template, 4, false, PI*0.5, 375,375,1.0,15,32)
		2:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 120
			init_enemies(template, 8, false, PI, 375,375,1.0,15,32)
		3:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.health = 1
			init_enemies(template, 15, false, TAU, 375, 375, 1.0, 15, 250)
		4:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.move_speed = 160
			template.coordinated = true
			init_enemies(template, 4, false, PI, 375,375,0.0,4,250)
		5:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			template.move_speed = 180
			init_enemies(template, 2, false, PI, 375,375,2.0,2, 75)
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 200
			init_enemies(template, 5, false, TAU, 375, 375, 3.0, 5, 150)
		6:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 200
			template.health = 1
			init_enemies(template, 5, false, TAU, 375, 375, 3.0, 5, 150)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.coordinated = true
			template.move_speed = 60
			init_enemies(template, 5, false, TAU, 376,376,2.0,4, 75)
		7:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 180
			template.health = 1
			init_enemies(template, 8, false, TAU, 375, 375, 3.0, 8, 150)
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 220
			template.health = 1
			init_enemies(template, 5, false, TAU, 376, 376, 3.0, 5, 150)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.coordinated = true
			template.move_speed = 60
			init_enemies(template, 4, false, TAU+TAU/8, 377,377,2.0,2, 75)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			template.move_speed = 120
			init_enemies(template, 4, false, TAU, 378,378,2.0,4, 75)

func next_wave_red():
	enemies_initialized = false
	var template: EnemyArea2D
	match current_wave:
		0:
			#bomb_area(8)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 100
			template.coordinated = true
			template.health = 5
			init_enemies(template, 5, false, PI, 375,375,0.0,5,50)
		1:
			bomb_area(8)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.move_speed = 150
			template.coordinated = false
			template.health = 5
			init_enemies(template, 5, false, PI, 375,375,1.0,5,150)
			#coordinated_bombs_enabled = 8
		2:
			#coordinated_bombs_enabled = 0
			bomb_area(8)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.move_speed = 150
			template.coordinated = false
			template.health = 5
			init_enemies(template, 5, false, PI, 375,375,1.0,10,250)

			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.move_speed = 250
			template.coordinated = true
			template.health = 3
			init_enemies(template, 9, false, PI, 375,375,1.0,9,10)

		3:
			# final boss?


			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.health = 3
			template.hit_jitter = 0
			template.hit_impact = 0
			template.coordinated = false
			init_enemies(template, 15, false, TAU, 130, 130, 1.0, 15, 250)

			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.health = 3
			template.hit_jitter = 0
			template.hit_impact = 0
			template.coordinated = true
			init_enemies(template, 15, false, TAU, 325, 325, 1.0, 15, 250)

			
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.health = 3
			template.coordinated = true
			init_enemies(template, 15, false, TAU+TAU/30, 325, 325, 1.0, 15, 250)

			template = $Templates/EnemyArea2Dv3
			template.current_movement = EnemyArea2D.MOVEMENT.NONE
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.health = 10
			template.hit_jitter = 0
			template.hit_impact = 0
			template.coordinated = true
			#template.health = 10
			init_enemies(template, 1, false, TAU, 0, 0, 1.0, 15, 250)


			
		4:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.SEEK
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.move_speed = 160
			template.coordinated = true
			init_enemies(template, 4, false, PI, 375,375,0.0,4,250)
		5:
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			template.move_speed = 180
			init_enemies(template, 2, false, PI, 375,375,2.0,2, 75)
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 200
			init_enemies(template, 5, false, TAU, 375, 375, 3.0, 5, 150)
		6:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 200
			template.health = 1
			init_enemies(template, 5, false, TAU, 375, 375, 3.0, 5, 150)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.coordinated = true
			template.move_speed = 60
			init_enemies(template, 5, false, TAU, 376,376,2.0,4, 75)
		7:
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 180
			template.health = 1
			init_enemies(template, 8, false, TAU, 375, 375, 3.0, 8, 150)
			template = $Templates/EnemyArea2Dv1
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.NONE
			template.move_speed = 220
			template.health = 1
			init_enemies(template, 5, false, TAU, 376, 376, 3.0, 5, 150)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.SHOOT
			template.coordinated = true
			template.move_speed = 60
			init_enemies(template, 4, false, TAU, 377,377,2.0,2, 75)
			template = $Templates/EnemyArea2Dv2
			template.current_movement = EnemyArea2D.MOVEMENT.BOID
			template.current_attack = EnemyArea2D.ATTACK.PULSE
			template.coordinated = true
			template.move_speed = 120
			init_enemies(template, 4, false, TAU, 378,378,2.0,4, 75)
	prints("initialized enemies", len(enemy_queue), len($"%EnemiesRemaining".get_parent().get_children()))
			
var max_health = 14
var current_health = 14
var player_health = []
func init_player_health():
	for i in max_health:
		var ui = $"%PlayerHealth".duplicate()
		$"%PlayerHealth".get_parent().add_child(ui)
		player_health.append(ui)
		ui.show()
	
	
func init_enemies(template: EnemyArea2D, count, random_angle, fan_angle, min_radius, max_radius, delay, bias_num, bias_distance):
	var initialized_enemies = []
	for i in count:
		var a := template.custom_duplicate() as EnemyArea2D
		if random_angle:
			a.position = Vector2.RIGHT.rotated(randf()*fan_angle-PI*0.5-fan_angle*0.5) * (min_radius + randf()*(max_radius-min_radius))
		else:
			if fan_angle >= TAU:
				a.position = Vector2.RIGHT.rotated(TAU / count * i+fan_angle - PI*0.5) * (min_radius + randf()*(max_radius-min_radius))
			else:
				a.position = Vector2.RIGHT.rotated(fan_angle/(count+1)*(i+1)-PI*0.5-fan_angle*0.5) * (min_radius + randf()*(max_radius-min_radius))
		#$Enemies.add_child(a)
		$Enemies.call_deferred("add_child", a)
		#a.hide()
		a.name = "EnemyArea"+str(total_enemy_count_id)
		total_enemy_count_id += 1
		a.idx = i
		a.siblings = enemies_until_next_wave
		a.target = $Player
		if fan_angle >= TAU:
			a.target_position_bias = Vector2.RIGHT.rotated(TAU/bias_num*(i%bias_num) - PI*0.5) * bias_distance
		else:
			a.target_position_bias = Vector2.RIGHT.rotated(fan_angle/(count+1)*(i+1)-PI*0.5-fan_angle*0.5) * bias_distance
			
		a.projectile_template = $Templates/Projectile
		a.pulse_template = $Templates/PulseProjectile
		a.connect("explosion", self, "explosion")
		a.gravity_direction = gravity_direction
		if a.is_bomb:
			pass
		else:
			var ui = $"%EnemiesRemaining".duplicate()
			$"%EnemiesRemaining".get_parent().add_child(ui)
			ui.show()
			a.ui = ui

			enemies_until_next_wave.append(a)
		enemy_queue.append(a)
		initialized_enemies.append(a)
		if a.current_attack != EnemyArea2D.ATTACK.NONE:
			if a.coordinated:
				if a.is_bomb:
					enemies_coordinated_explosive.append(a)
				else:
					enemies_coordinated.append(a)
			else:
				if a.is_bomb:
					enemies_simultaneous_explosive.append(a)
				else:
					enemies_simultaneous.append(a)
		#match a.current_attack:
		#	EnemyArea2D.ATTACK.NONE:
		#		pass
		#	EnemyArea2D.ATTACK.SHOOT:
		#		shooting_enemies.append(a)
		#	EnemyArea2D.ATTACK.PULSE:
		#		shooting_enemies_half.append(a)
	return initialized_enemies
		
	

func explosion(entity: EnemyArea2D):
	match entity.size:
		1:
			$Templates/ExplosionParticles2D1.position = entity.position
			$Templates/ExplosionParticles2D1.emitting = true
		2:
			$Templates/ExplosionParticles2D2.position = entity.position
			$Templates/ExplosionParticles2D2.emitting = true
		5:
			$Templates/ExplosionParticles2D3.position = entity.position
			$Templates/ExplosionParticles2D3.emitting = true
	if entity.ui:
		entity.ui.modulate = Color.black
	
	if entity in enemies_coordinated:
		enemies_coordinated.erase(entity)
	elif entity in enemies_coordinated_explosive:
		enemies_coordinated_explosive.erase(entity)
		if coordinated_bombs_enabled > 0 and len(enemies_coordinated_explosive)<coordinated_bombs_enabled:
			bomb_area(coordinated_bombs_enabled - len(enemies_coordinated_explosive))
	elif entity in enemies_simultaneous:
		enemies_simultaneous.erase(entity)
	elif entity in enemies_simultaneous_explosive:
		enemies_simultaneous_explosive.erase(entity)
		if simultaneous_bombs_enabled > 0 and len(enemies_simultaneous_explosive)==0:
			bomb_area(simultaneous_bombs_enabled, false)

	
	if entity in enemies_until_next_wave:
		enemies_until_next_world -= 1
		enemies_until_next_wave.erase(entity)
	
	if enemies_until_next_world==0:
		next_world_unlock()
		return
		
	#if len(shooting_enemies)==0 and len(shooting_enemies_half)==0:
	if len(enemies_until_next_wave)==0:
		advance_next_wave()
		
	
func _process(delta):
	if get_node_or_null("PlayerShadow"):
		if current_world == 2:
			$PlayerShadow.position = $Player.position + Vector2(5,5)
			$PlayerShadow.rotation = $Player.rotation + PI * 0.5
		elif current_world == 3:
			$PlayerShadow.position = $Player.position
	beat_check()
	beat_check_player()
	if $Player.can_action:
		time_elapsed += delta
	$"%ScoreLabel".text = "%.2f" % time_elapsed
	#coordinate_attack()

export var bpm = 132.0
var attack_count = 0
var beat_count = 0
#var beat_delay = 0.151515
var beat_delay = 0.454545
export var background_beat = false
func beat_check():
	if $AudioStreamPlayer.get_playback_position() > beat_count * beat_delay:
		beat_count += 1
		coordinate_attack()
		next_player_beat_subdivision_count += 1
		if background_beat:
			if background_beat_tween:
				background_beat_tween.kill()
			background_beat_tween = create_tween()
			background_beat_tween.set_ease(Tween.EASE_OUT)
			background_beat_tween.set_trans(Tween.TRANS_EXPO)
			background_beat_tween.tween_property($BackgroundBeat/Line2D, "rotation", TAU/(4) * beat_count, beat_delay)


var next_player_beat = 0.0
var next_player_beat_subdivision_count = 0
var background_beat_tween: SceneTreeTween
func beat_check_player(subdivision=4.0):
	var playtime = $AudioStreamPlayer.get_playback_position()
	if playtime >= next_player_beat:
		var beat_interval = (60.0 / bpm) / subdivision
		next_player_beat = playtime + beat_interval - (playtime - next_player_beat)
		$Player.do_fire(true)
		return
		next_player_beat_subdivision_count += 1
		if background_beat_tween:
			background_beat_tween.kill()
		background_beat_tween = create_tween()
		background_beat_tween.set_ease(Tween.EASE_OUT)
		background_beat_tween.set_trans(Tween.TRANS_EXPO)
		background_beat_tween.tween_property($BackgroundBeat/Line2D, "rotation", TAU/(4*subdivision) * next_player_beat_subdivision_count, beat_interval)
		

func coordinate_attack():
	if enemy_queue:
		enemy_queue.pop_front().activate()
		return
	else:
		enemies_initialized = true

	if enemies_simultaneous and (beat_count-1) % 4 == 0:
		#prints("coordinate_attack", attack_count)
		for idx in len(enemies_simultaneous):
			#enemies_simultaneous[idx].do_fire(true, idx>0)
			enemies_simultaneous[idx].call_deferred("do_fire", true, idx>0)
		#shooting_enemies_half[attack_count_half % len(shooting_enemies_half)].do_fire(true)
		
	if enemies_coordinated:
		#prints("coordinate_attack", attack_count)
		enemies_coordinated[attack_count % len(enemies_coordinated)].do_fire(true)
		attack_count += 1
		
	if enemies_coordinated_explosive:
		enemies_coordinated_explosive[0].do_fire(true)
		
	if enemies_simultaneous_explosive:
		for idx in len(enemies_simultaneous_explosive):
			enemies_simultaneous_explosive[idx].call_deferred("do_fire", true, idx>0)
		

	
func audio_finished():
	prints("audio restart")
	beat_count = 0
	next_player_beat = 0.0
	$AudioStreamPlayer.play(0.0)

	
func take_hit():
	$Camera2D.apply_shake()
	$Templates/ExplosionParticles2D0.position = $Player.position
	$Templates/ExplosionParticles2D0.emitting = true
	current_health -= 1
	if current_health < 0:
		pass
	else:
		player_health[current_health].modulate = Color.black
		if current_health == 0:
			pass
			game_over()
			
func game_over():
	Game.play_sfx("res://assets/sfx/EXPLOSION.ogg")
	$"%EndLabel".text = "Game over"
	$"%FinalScoreLabel".text = $"%ScoreLabel".text + " seconds"
	get_tree().paused = true
	$WinLayer/WinOverlay.show()
	pass


	



