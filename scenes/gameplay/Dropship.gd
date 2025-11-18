extends Area2D

enum STATE {NONE, ACTIVE, STAGGERED, ADRIFT}
enum MOVEMENT {NONE, BOID, SEEK, DRIFT, HINT, FLEE}
enum ATTACK {NONE, SHOOT, PULSE, BOMB}
enum AIM {DIRECT, WAY4, DOWN}

var ui: Control

var current_state = STATE.NONE
var current_movement = MOVEMENT.BOID
var current_attack = ATTACK.SHOOT
var current_attack_aim = AIM.DIRECT

var idx = -1
var staggered_timeout = 0.0
var target: Node2D

export var hit_jitter = 10
export var hit_impact = 10
export var hit_impact_projectile_direction_ratio := 0.75

var fire_elapsed := 0.0
export var fire_cooldown := 1.0
export var fire_power := 1.0
export var fire_cadence := 1

export var health = 5

export var coordinated := false
export var gravity_direction := Vector2.ZERO

export var is_bomb := false
export var bomb_delay := 4
export var invulnerable := false
export var staggered_time_on_hit := 0.3
export var staggered_time_on_shot := 2.0

var projectile_template: Projectile
var pulse_template: Projectile

var desired_position = Vector2.ZERO
var follower: PathFollow2D
var follower_multiplier := 1.0



var siblings = []
export var move_speed = 200
export(int) var size = 1
var perception_radius = 20000
var centralization_force_radius = 10
var velocity = Vector2()
var acceleration = Vector2()
var steer_force = 50.0
var alignment_force = 1.2
var cohesion_force = 0.5
var seperation_force = 10.0
var avoidance_force = 15.0
var centralization_force = 15#0.5
var target_position: Vector2 = Vector2(0, 0)
var movement_factor = 0.05
var target_position_bias = Vector2.ZERO

var scheduled_start_time = 0.0

func _ready():
	connect("area_entered", self, "area_entered")
	hide()
	$SpriteHit.modulate = Color.transparent
	$SpriteHit.show()

export var activate_delay = 0.454545
func activate():
	show()
	if activate_delay > 0.0:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(self, "_activate").set_delay(activate_delay)
	else:
		_activate()
func _activate():
	current_state = STATE.ACTIVE
	set_deferred("monitorable", true)
	

func custom_duplicate():
	var d = self.duplicate()
	d.current_state = self.current_state
	d.current_movement = self.current_movement
	d.current_attack = self.current_attack
	d.current_attack_aim = self.current_attack_aim
	d.hit_jitter = self.hit_jitter
	d.hit_impact = self.hit_impact
	d.health = self.health
	d.size = self.size
	d.move_speed = self.move_speed
	d.fire_cooldown = self.fire_cooldown
	d.fire_power = self.fire_power
	d.fire_cadence = self.fire_cadence
	d.activate_delay = self.activate_delay
	return d


var impact_tween: SceneTreeTween
func hit_impact(hit_direction: Vector2):
	if not is_instance_valid(self) or not is_inside_tree():
		return
	#current_state = STATE.STAGGERED
	if current_state == STATE.ADRIFT:
		position += Vector2(randf()* hit_jitter - hit_jitter*0.5, randf()*hit_jitter-hit_jitter*0.5)
		position += hit_direction * hit_impact

	else:
		if staggered_timeout < staggered_time_on_hit:
			staggered_timeout += staggered_time_on_hit
		if impact_tween:
			impact_tween.kill()
		impact_tween = create_tween()
		impact_tween.set_parallel(true)
		#var position_ = position + Vector2(randf()* hit_jitter - hit_jitter*0.5, randf()*hit_jitter-hit_jitter*0.5)
		#position_ += hit_direction * hit_impact
		if impact_tween:
			impact_tween.set_ease(Tween.EASE_OUT)
			impact_tween.set_trans(Tween.TRANS_EXPO)
			impact_tween.tween_property($SpriteHit, "modulate", Color.transparent, 0.3).from(Color.white)
			#impact_tween.tween_property(self, "position", position_, staggered_time_on_hit)
			


func area_entered(area):
	if current_state == STATE.NONE:
		return
	if (current_state == STATE.ACTIVE or current_state== STATE.STAGGERED or current_state == STATE.ADRIFT) and area is ProjectileArea2D and area.get_parent().active:
		# correct directon when not stuck
		var hit_direction := area.get_parent().direction.normalized() as Vector2
		var hit_position := (position - area.get_parent().position).normalized() as Vector2
		var hit_angle = hit_position.angle()
		
		
		
		
		#hit_direction = lerp(hit_position, hit_direction, hit_impact_projectile_direction_ratio)
		hit_impact(hit_direction)
		
		if false:
			# bounce the bullet
			area.get_parent().direction = (area.get_parent().position - position).normalized()
			#area.get_parent().modulate *= 0.7
			area.get_parent().speed *= 0.8
			#return
		else:
			# destroy the bullet
			area.get_parent().explode()
		
		
		
		if current_state == STATE.ADRIFT:
			velocity = hit_direction * move_speed * 0.25
		else:
			#current_state = STATE.STAGGERED
			#current_movement = MOVEMENT.NONE
			staggered_timeout = min(staggered_time_on_shot, staggered_timeout)
			if not invulnerable:
				health -= 1
				if health <= 0:
					die(hit_direction)
					#Game.play_sfx()
				else:
					pass
					#Game.play_sfx("res://hitHurt.wav")
			else:
				pass
				#Game.play_sfx("res://assets/sfx/hitHurtShield.wav")

signal explosion(entity)

func die(direction: Vector2):
	emit_signal("explosion", self)
	cleanup()
	
	
func cleanup():
	if follower:
		follower.queue_free()
	queue_free()

func _process(delta):
	if current_state == STATE.NONE:
		return
	if target:
		target_position = target.position
		if target_position_bias.y > 0:
			target_position.y = clamp(target_position.y, 16, 320)
			position.y = clamp(position.y, 8, 480)
		else:
			target_position.y = clamp(target_position.y, -320, -16)
			position.y = clamp(position.y, -480, -8)
		target_position += target_position_bias
	
	fire_elapsed += delta
	
	if staggered_timeout > 0.0:
		staggered_timeout -= delta
		return # prevent any movement but do not override it
	else:
		staggered_timeout = 0.0

	if current_state == STATE.ACTIVE:
		if current_attack_aim == AIM.DIRECT:
			pass
			#look_at(target.position)
		match current_attack:
			ATTACK.SHOOT:
				do_fire()
		
	match current_movement:
		MOVEMENT.BOID:
			_process_movement_boid(delta)
		MOVEMENT.DRIFT:
			if gravity_direction == Vector2.ONE:
				var n = position.normalized()
				if n == Vector2.ZERO:
					prints("random jitter")
					n = Vector2(randf(), randf()) * 10
				velocity += -n * delta * 40
			elif gravity_direction != Vector2.ZERO:
				velocity += gravity_direction * delta * 10
			translate(velocity * delta)
		MOVEMENT.SEEK:
			velocity = (target_position-position).normalized()*move_speed
			translate(velocity * delta)
			#look_at(target.position)
		MOVEMENT.HINT:
			var movement_target = (desired_position - position)
			if movement_target.length_squared() > pow(move_speed * delta, 2):
				position += movement_target.limit_length(move_speed * delta)
			else:
				position = desired_position
				
	$Sprite.flip_h = position.x > target.position.x
	$SpriteHit.flip_h = $Sprite.flip_h

func do_fire(force=false, quiet=false):
	if current_state != STATE.ACTIVE:
		return
	if force or fire_elapsed >= 0.0:
		Game.play_sfx("res://sfx/Splash.wav")
		var projectile = projectile_template.duplicate()
		GameManager.scrolling_projectiles.add_child(projectile)
		
		projectile.position = position
		projectile.speed += randf() * 100
		projectile.activate(2)
		fire_elapsed = - fire_cooldown
			
func _process_movement_boid(delta):
	var neighbors = get_neighbors(perception_radius)
	
	acceleration += process_alignments(neighbors) * alignment_force * movement_factor
	acceleration += process_cohesion(neighbors) * cohesion_force * movement_factor
	acceleration += process_seperation(neighbors) * seperation_force * movement_factor
	acceleration += process_centralization(target_position) * centralization_force * movement_factor
	if position.length() > 300:
		acceleration += position.normalized() * centralization_force * -2.0
	velocity += acceleration * delta
	velocity = velocity.clamped(move_speed)
	#rotation = velocity.angle()
	
	translate(velocity * delta)


func set_prey_position(position: Vector2):
	target_position = position
	
func process_centralization(center: Vector2):
	if position.distance_to(center) < centralization_force_radius:
		return Vector2()
		
	return steer((center - position).normalized() * move_speed)	

func process_cohesion(neighbors):
	var vector = Vector2()
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.position
	vector /= neighbors.size()
	
	return steer((vector - position).normalized() * move_speed)
		

func process_alignments(neighbors):
	var vector = Vector2()
	if neighbors.empty():
		return vector
		
	for boid in neighbors:
		vector += boid.velocity
	vector /= neighbors.size()
	
	return steer(vector.normalized() * move_speed)
	

func process_seperation(neighbors):
	var vector = Vector2()
	var close_neighbors = []
	for boid in neighbors:
		if position.distance_to(boid.position) < perception_radius / 2:
			close_neighbors.push_back(boid)
	if close_neighbors.empty():
		return vector
	
	for boid in close_neighbors:
		var difference = position - boid.position
		vector += difference.normalized() / difference.length()
	
	vector /= close_neighbors.size()
	
	return steer(vector.normalized() * move_speed)
	

func steer(var target):
	var steer = target - velocity
	steer = steer.normalized() * steer_force
	
	return steer
	

func get_neighbors(view_radius):
	var neighbors = []

	for boid in siblings:
		if position.distance_squared_to(boid.position) <= view_radius and not boid == self:
			neighbors.push_back(boid)
			
	return neighbors

var registered_children = []
func register_child(child):
	add_child(child)
	registered_children.append(child)
