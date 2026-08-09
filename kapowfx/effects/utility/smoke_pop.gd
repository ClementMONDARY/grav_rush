extends FxEffect
## Cartoon "poof": puffy cloud that expands and vanishes.
## Spawns, despawns, dashes, teleports — the universal utility effect.

@export_range(3, 16) var puff_count: int = 7

var _puffs: GPUParticles2D
var _flash: Sprite2D

func _build() -> void:
	_flash = Sprite2D.new()
	_flash.texture = FxEffect.make_dot_texture(96)
	_flash.material = FxEffect.make_add_material()
	_flash.modulate.a = 0.0
	add_child(_flash)

	_puffs = GPUParticles2D.new()
	_puffs.one_shot = true
	_puffs.emitting = false
	_puffs.explosiveness = 1.0
	_puffs.amount = puff_count
	_puffs.lifetime = 0.55
	_puffs.local_coords = true
	_puffs.texture = FxEffect.make_dot_texture(80)
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(1, 0, 0)
	pm.spread = 180.0
	pm.gravity = Vector3(0, -40, 0)
	pm.initial_velocity_min = 90.0
	pm.initial_velocity_max = 200.0
	pm.damping_min = 260.0
	pm.damping_max = 420.0
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 14.0
	pm.scale_min = 0.6
	pm.scale_max = 1.2
	pm.scale_curve = FxEffect.make_curve([[0.0, 0.5], [0.3, 1.0], [1.0, 0.2]])
	_puffs.process_material = pm
	add_child(_puffs)

func _apply_colors() -> void:
	# Smoke pop reads best in soft neutral tones; color_main tints it lightly.
	var base := color_main.lerp(Color(0.92, 0.92, 0.95, 1), 0.75)
	var pm: ParticleProcessMaterial = _puffs.process_material
	pm.color_ramp = FxEffect.make_ramp([
		Color(base.r, base.g, base.b, 0.95),
		Color(base.r, base.g, base.b, 0.7),
		Color(base.r, base.g, base.b, 0.0),
	])
	_flash.modulate = Color(1, 1, 1, 0)

func _play() -> void:
	var spd := maxf(speed, 0.01)
	_puffs.speed_scale = spd
	_puffs.restart()
	_puffs.emitting = true
	_flash.scale = Vector2.ONE * 1.1
	_flash.modulate.a = 0.5
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_flash, "scale", Vector2.ONE * 0.2, 0.14 / spd)
	t.tween_property(_flash, "modulate:a", 0.0, 0.14 / spd)

func _duration() -> float:
	return 0.7
