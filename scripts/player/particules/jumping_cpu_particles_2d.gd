extends CPUParticles2D

func wall_jump(parent_node_path: NodePath) -> void:
	emission_rect_extents = Vector2(0.0, 2.0)
	direction = Vector2(0.25, 1.0)
	explosiveness = 1.0
	_play(parent_node_path)

func ground_jump(parent_node_path: NodePath) -> void:
	emission_rect_extents = Vector2(2.0, 0.0)
	direction = Vector2(0.0, -1.0)
	explosiveness = 0.95
	_play(parent_node_path)

func _play(parent_node_path: NodePath) -> void:
	var parent_node = get_node_or_null(parent_node_path)
	if parent_node == null:
		push_error("play(): Invalid parent_node_path")
		return

	var p = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	p.set_script(null)
	parent_node.add_child(p)
	p.emitting = true

	await get_tree().create_timer(p.lifetime).timeout
	p.queue_free()
