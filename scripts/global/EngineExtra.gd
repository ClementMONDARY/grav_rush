extends Node

func frameFreeze(timeScale, duration) -> void:
	Engine.time_scale = timeScale
	await get_tree().create_timer(timeScale * duration).timeout
	Engine.time_scale = 1.0
