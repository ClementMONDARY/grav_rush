extends CPUParticles2D

func play(parent_node_path: NodePath) -> void:
	var parent_node = get_node_or_null(parent_node_path)
	if parent_node == null:
		push_error("play(): Invalid parent_node_path")
		return
	
	var p = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	_setup_direction(p, parent_node)
	
	parent_node.add_child(p)
	p.emitting = true
	
	await get_tree().create_timer(p.lifetime).timeout
	p.queue_free()

func _setup_direction(particle: CPUParticles2D, parent_node: Node) -> void:
	var velocity = parent_node.get_parent().velocity
	var opposite_direction = - velocity.normalized()
	opposite_direction.y -= 0.635
	opposite_direction = opposite_direction.normalized()
	particle.direction = opposite_direction
