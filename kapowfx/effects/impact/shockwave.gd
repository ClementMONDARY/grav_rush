extends FxEffect
## Expanding shockwave ring. Stack under explosions, landings, big hits.

## Squash < 1.0 gives a floor-perspective ellipse (great for ground slams).
@export_range(0.2, 1.0, 0.01) var squash: float = 1.0
@export_range(64, 1024, 1) var max_radius_px: int = 170

var _ring: Sprite2D
var _mat: ShaderMaterial

func _build() -> void:
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://kapowfx/common/shaders/ring.gdshader")
	_ring = Sprite2D.new()
	_ring.texture = FxEffect.make_white_texture(64)
	_ring.material = _mat
	add_child(_ring)

func _apply_colors() -> void:
	_mat.set_shader_parameter("tint", color_main)
	_mat.set_shader_parameter("squash", squash)
	_ring.scale = Vector2.ONE * (float(max_radius_px) * 2.0 / 64.0)

func _play() -> void:
	var spd := maxf(speed, 0.01)
	_mat.set_shader_parameter("radius", 0.02)
	_mat.set_shader_parameter("thickness", 0.16)
	_mat.set_shader_parameter("softness", 0.045)
	_mat.set_shader_parameter("fade", 1.0)
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_mat, "shader_parameter/radius", 0.9, 0.36 / spd)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(_mat, "shader_parameter/thickness", 0.03, 0.36 / spd)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(_mat, "shader_parameter/fade", 0.0, 0.26 / spd)\
		.set_delay(0.08 / spd).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _duration() -> float:
	return 0.42
