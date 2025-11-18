extends Camera2D

export var RANDOM_SHAKE_STRENGTH: float = 10.0
export var SHAKE_DECAY_RATE: float = 5.0

onready var rand = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()

func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH

func _process(delta: float) -> void:
	shake_strength = lerp(shake_strength, 0, SHAKE_DECAY_RATE * delta)
	offset = get_random_offset()

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
