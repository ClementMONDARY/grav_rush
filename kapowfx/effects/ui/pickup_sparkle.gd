extends FxEffect
## Item pickup twinkle: a few star pops + rising motes. Light and cheerful.

@export_range(2, 10) var star_count: int = 5

var _stars: Array[Sprite2D] = []
var _motes: GPUParticles2D

func _build() -> void:
	for i in star_count:
		var s := FxEffect.make_star_sprite(4, 26.0)
		s.visible = false
		add_child(s)
		_stars.append(s)
	_motes = GPUParticles2D.new()
	_motes.one_shot = true
	_motes.emitting = false
	_motes.explosiveness = 0.6
	_motes.amount = 10
	_motes.lifetime = 0.55
	_motes.local_coords = true
	_motes.texture = FxEffect.make_dot_texture(24)
	_motes.material = FxEffect.make_add_material()
	var mm := ParticleProcessMaterial.new()
	mm.direction = Vector3(0, -1, 0)
	mm.spread = 40.0
	mm.gravity = Vector3(0, -320, 0)
	mm.initial_velocity_min = 40.0
	mm.initial_velocity_max = 130.0
	mm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mm.emission_sphere_radius = 22.0
	mm.scale_min = 0.4
	mm.scale_max = 1.0
	mm.scale_curve = FxEffect.make_curve([[0.0, 1.0], [1.0, 0.0]])
	_motes.process_material = mm
	add_child(_motes)

func _apply_colors() -> void:
	for s in _stars:
		(s.material as ShaderMaterial).set_shader_parameter("tint", color_main)
	var mm: ParticleProcessMaterial = _motes.process_material
	mm.color_ramp = FxEffect.make_ramp([
		Color(1, 1, 1, 1), color_main,
		Color(color_main.r, color_main.g, color_main.b, 0.0),
	])

func _play() -> void:
	var spd := maxf(speed, 0.01)
	_motes.speed_scale = spd
	_motes.restart()
	_motes.emitting = true
	for i in _stars.size():
		var s := _stars[i]
		var mat := s.material as ShaderMaterial
		s.visible = true
		s.position = Vector2(randf_range(-26, 26), randf_range(-26, 26))
		s.rotation = randf() * TAU
		s.scale = Vector2.ZERO
		mat.set_shader_parameter("progress", 0.0)
		var delay := i * 0.05 / spd
		var t := create_tween()
		t.tween_interval(maxf(delay, 0.001))
		t.tween_property(s, "scale", Vector2.ONE * randf_range(0.5, 0.9), 0.12 / spd)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(mat, "shader_parameter/progress", 1.0, 0.3 / spd)\
			.set_delay(0.05 / spd)

func _duration() -> float:
	return 0.7
