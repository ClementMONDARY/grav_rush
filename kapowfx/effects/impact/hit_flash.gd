extends FxEffect
## Small, fast hit flash — bullet impacts, rapid melee, UI feedback.
## Cheap enough to spam dozens per second.

@export_range(2, 16) var star_points: int = 4

var _star: Sprite2D
var _mat: ShaderMaterial
var _dot: Sprite2D

func _build() -> void:
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://kapowfx/common/shaders/spark_star.gdshader")
	_mat.set_shader_parameter("sharpness", 22.0)
	_star = Sprite2D.new()
	_star.texture = FxEffect.make_white_texture(64)
	_star.material = _mat
	add_child(_star)
	_dot = Sprite2D.new()
	_dot.texture = FxEffect.make_dot_texture(64)
	_dot.material = FxEffect.make_add_material()
	add_child(_dot)

func _apply_colors() -> void:
	_mat.set_shader_parameter("tint", color_main)
	_mat.set_shader_parameter("points", star_points)
	_dot.modulate = color_accent

func _play() -> void:
	var spd := maxf(speed, 0.01)
	_mat.set_shader_parameter("progress", 0.0)
	_mat.set_shader_parameter("spin", randf() * TAU)
	_star.scale = Vector2.ONE * 0.2
	_star.rotation = randf() * TAU
	_dot.scale = Vector2.ONE * 1.1
	_dot.modulate.a = 1.0
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_star, "scale", Vector2.ONE * 1.05, 0.14 / spd)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(_mat, "shader_parameter/progress", 1.0, 0.17 / spd)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_property(_dot, "scale", Vector2.ONE * 0.15, 0.15 / spd)
	t.tween_property(_dot, "modulate:a", 0.0, 0.15 / spd)

func _duration() -> float:
	return 0.2
