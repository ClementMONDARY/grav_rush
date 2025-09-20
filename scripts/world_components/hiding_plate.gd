extends TextureRect

func _on_destructible_ground_wall_destroyed() -> void:
	queue_free()
