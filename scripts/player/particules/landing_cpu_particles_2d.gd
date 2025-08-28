extends CPUParticles2D

func play(parent_node: Node2D) -> void:
	var p = self.duplicate()
	parent_node.add_child(p)
	p.emitting = true

	await get_tree().create_timer(p.lifetime).timeout
	p.queue_free()
