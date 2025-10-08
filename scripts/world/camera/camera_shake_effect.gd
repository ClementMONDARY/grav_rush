extends Node
class_name CameraShakeScript

@export var camera2D: Camera2D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0

var rng := RandomNumberGenerator.new()
var is_shaking: bool = false
var shake_strength: float = 0.0
var shake_time_left: float = 0.0
var original_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	rng.randomize()
	if camera2D == null:
		push_warning("CameraShakeScript: camera2D is null. Make sure to assign a Camera2D node or set the script as a child of a Camera2D.")
	else:
		original_offset = camera2D.offset

func _process(delta: float) -> void:
	if not is_shaking: return

	if camera2D == null:
		stop_shake()
		return

	camera2D.offset = random_offset()

	shake_time_left -= delta
	if shake_time_left <= 0:
		stop_shake()
	else:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func shake(duration: float, intensity: float, fade: float = 5.0) -> void:
	if camera2D == null:
		push_warning("CameraShakeScript.shake: camera2D is null, cannot shake.")
		return

	shake_time_left = max(duration, 0.0)
	shake_strength = max(intensity, 0.0)
	shakeFade = max(fade, 0.0)
	is_shaking = shake_time_left > 0.0 and shake_strength > 0.0
	original_offset = camera2D.offset

func stop_shake() -> void:
	if camera2D:
		camera2D.offset = original_offset
	is_shaking = false
	shake_time_left = 0.0
	shake_strength = 0.0
