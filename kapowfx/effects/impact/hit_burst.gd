extends FxEffect
## Chunky debris burst with gravity + lingering smoke puffs.
## Breakables, crates, rocks, enemies popping.

@export_range(4, 40) var chunk_count: int = 14
@export_range(0, 20) var smoke_count: int = 7
## Direction the debris flies (degrees, -90 = up). 999 = full radial.
@export var burst_angle_deg: float = 999.0

var _chunks: GPUParticles2D
var _smoke: GPUParticles2D

func _build() -> void:
	_chunks = GPUParticles2D.new()
	_chunks.one_shot = true
	_chunks.emitting = false
	_chunks.explosiveness = 1.0
	_chunks.amount = chunk_count
	_chunks.lifetime = 0.7
	_chunks.local_coords = true
	_chunks.texture = FxEffect.make_white_texture(7)
	var pm := ParticleProcessMaterial.new()
	if burst_angle_deg > 360.0:
		pm.direction = Vector3(0, -1, 0)
		pm.spread = 180.0
	else:
		pm.direction = Vector3(cos(deg_to_rad(burst_angle_deg)), sin(deg_to_rad(burst_angle_deg)), 0)
		pm.spread = 42.0
	pm.gravity = Vector3(0, 1500, 0)
	pm.initial_velocity_min = 220.0
	pm.initial_velocity_max = 520.0
	pm.angular_velocity_min = -540.0
	pm.angular_velocity_max = 540.0
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 9.0
	pm.scale_min = 0.6
	pm.scale_max = 1.4
	pm.scale_curve = FxEffect.make_curve([[0.0, 1.0], [0.75, 0.8], [1.0, 0.0]])
	_chunks.process_material = pm
	add_child(_chunks)

	_smoke = GPUParticles2D.new()
	_smoke.one_shot = true
	_smoke.emitting = false
	_smoke.explosiveness = 0.9
	_smoke.amount = maxi(smoke_count, 1)
	_smoke.visible = smoke_count > 0
	_smoke.lifetime = 0.8
	_smoke.local_coords = true
	_smoke.texture = FxEffect.make_dot_texture(72)
	var sm := ParticleProcessMaterial.new()
	sm.direction = Vector3(0, -1, 0)
	sm.spread = 180.0
	sm.gravity = Vector3(0, -170, 0)
	sm.initial_velocity_min = 60.0
	sm.initial_velocity_max = 170.0
	sm.damping_min = 80.0
	sm.damping_max = 150.0
	sm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	sm.emission_sphere_radius = 24.0
	sm.scale_min = 0.35
	sm.scale_max = 0.9
	sm.scale_curve = FxEffect.make_curve([[0.0, 0.4], [0.4, 1.0], [1.0, 1.25]])
	_smoke.process_material = sm
	add_child(_smoke)

func _apply_colors() -> void:
	var pm: ParticleProcessMaterial = _chunks.process_material
	pm.color_ramp = FxEffect.make_ramp([
		Color(1, 1, 0.9, 1), color_main, color_accent,
		Color(color_accent.r * 0.5, color_accent.g * 0.5, color_accent.b * 0.5, 0.0),
	])
	var sm: ParticleProcessMaterial = _smoke.process_material
	# Desaturated dark warm gray — smoke should read as haze, not a blob.
	var smoke_col := color_accent.darkened(0.55)
	var gray := (smoke_col.r + smoke_col.g + smoke_col.b) / 3.0
	smoke_col = smoke_col.lerp(Color(gray, gray, gray, 1), 0.6)
	sm.color_ramp = FxEffect.make_ramp([
		Color(smoke_col.r, smoke_col.g, smoke_col.b, 0.3),
		Color(smoke_col.r, smoke_col.g, smoke_col.b, 0.18),
		Color(smoke_col.r, smoke_col.g, smoke_col.b, 0.0),
	])

func _play() -> void:
	var spd := maxf(speed, 0.01)
	_chunks.speed_scale = spd
	_smoke.speed_scale = spd
	_chunks.restart()
	_smoke.restart()
	_chunks.emitting = true
	_smoke.emitting = true

func _duration() -> float:
	return 1.0
