extends Node2D

@onready var player: CharacterBody2D = $"../.."

@onready var particle_scene: CPUParticles2D = $FOOTSTEPS_CPUParticles2D

func play_footstep_particles(velocity_node_path: NodePath) -> void:
	var velocity_node = get_node_or_null(velocity_node_path)
	if velocity_node == null:
		push_error("play_footstep_particles(): Invalid nodes path")
		return

	var p = particle_scene.duplicate()
	_setup_particle_direction(p, velocity_node)

	add_child(p)
	p.emitting = true

	await get_tree().create_timer(p.lifetime).timeout
	p.queue_free()


func play_footstep_sound() -> void:
	var material = _get_floor_type()
	match material:
		"stone":
			AudioManager.create_2d_audio_at_location_with_culling(global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_FOOTSTEP_STONE)
			print("stone")
		"wood":
			print("wood")
		null, "":
			AudioManager.create_2d_audio_at_location_with_culling(global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_FOOTSTEP_STONE)


func _setup_particle_direction(particle: CPUParticles2D, velocity_node: CharacterBody2D) -> void:
	var velocity = velocity_node.velocity
	var opposite_direction = -velocity.normalized()
	opposite_direction.y -= 0.635 # small lift-up
	particle.direction = opposite_direction.normalized()


func _get_floor_type() -> String:
	var last_floor_collision := player.get_last_slide_collision()
	if last_floor_collision == null:
		return ""
		
	var collider = last_floor_collision.get_collider()
	if collider is TileMapLayer:
		var tile_map_layer := collider as TileMapLayer
		var local_point = tile_map_layer.to_local(last_floor_collision.get_position())
		var pos = tile_map_layer.local_to_map(local_point)
		var data = tile_map_layer.get_cell_tile_data(pos)
		if data:
			return data.get_custom_data("material")
	return ""
