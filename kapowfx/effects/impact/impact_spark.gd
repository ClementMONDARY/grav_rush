extends FxEffect
## Anime-style impact spark: hot star flash + radial streaks + glow pop.
## The bread-and-butter "something got HIT" effect.

@export_range(2, 16) var star_points: int = 4
@export_range(4, 30) var streak_count: int = 14

var _star: Sprite2D
var _glow: Sprite2D
var _streaks: GPUParticles2D
var _star_mat: ShaderMaterial

func _build() -> void:
	# Hot star flash
	_star_mat = ShaderMaterial.new()
	_star_mat.shader = load("res://kapowfx/common/shaders/spark_star.gdshader")
	_star = Sprite2D.new()
	_star.texture = FxEffect.make_white_texture(64)
	_star.material = _star_mat
	_star.scale = Vector2.ZERO
	add_child(_star)

	# Soft glow behind everything
	_glow = Sprite2D.new()
	_glow.texture = FxEffect.make_dot_texture(128)
	_glow.material = FxEffect.make_add_material()
	_glow.scale = Vector2.ZERO
	add_child(_glow)

	# Radial streaks
	_streaks = GPUParticles2D.new()
	_streaks.one_shot = true
	_streaks.emitting = false
	_streaks.explosiveness = 1.0
	_streaks.amount = streak_count
	_streaks.lifetime = 0.38
	_streaks.local_coords = true
	_streaks.texture = FxEffect.make_streak_texture(9, 52)
	_streaks.material = FxEffect.make_add_material()
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(1, 0, 0)
	pm.spread = 180.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 520.0
	pm.initial_velocity_max = 950.0
	pm.damping_min = 1600.0
	pm.damping_max = 2400.0
	pm.particle_flag_align_y = true
	pm.scale_min = 0.7
	pm.scale_max = 1.4
	pm.scale_curve = FxEffect.make_curve([[0.0, 1.0], [0.55, 0.6], [1.0, 0.0]])
	_streaks.process_material = pm
	add_child(_streaks)

func _apply_colors() -> void:
	_star_mat.set_shader_parameter("tint", color_main)
	_star_mat.set_shader_parameter("core_tint", Color(1, 1, 0.95, 1))
	_star_mat.set_shader_parameter("points", star_points)
	_glow.modulate = color_accent.lerp(Color.WHITE, 0.45)
	var pm: ParticleProcessMaterial = _streaks.process_material
	pm.color_ramp = FxEffect.make_ramp([
		Color(1, 1, 0.95, 1), color_main, color_accent,
		Color(color_accent.r, color_accent.g, color_accent.b, 0.0),
	])

func _play() -> void:
	var spd := maxf(speed, 0.01)
	_streaks.speed_scale = spd
	_streaks.restart()
	_streaks.emitting = true
	_star_mat.set_shader_parameter("spin", randf_range(-0.3, 0.3))
	_star_mat.set_shader_parameter("progress", 0.0)
	_star.scale = Vector2.ONE * 1.1
	_glow.scale = Vector2.ONE * 1.5
	_glow.modulate.a = 1.0
	var t := create_tween()
	t.set_parallel(true)
	# Star: instant pop, quick growth, snappy decay.
	t.tween_property(_star, "scale", Vector2.ONE * 2.5, 0.16 / spd)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(_star_mat, "shader_parameter/progress", 1.0, 0.24 / spd)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# Glow: tight hot pop that dies fast (no lingering orange ball).
	t.tween_property(_glow, "scale", Vector2.ONE * 0.4, 0.16 / spd)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(_glow, "modulate:a", 0.0, 0.17 / spd)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _duration() -> float:
	return 0.45
