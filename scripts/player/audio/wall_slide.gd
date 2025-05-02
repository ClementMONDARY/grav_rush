extends AudioStreamPlayer2D

@export var player: CharacterBody2D

func _process(_delta: float) -> void:
	volume_db = min(player.velocity.y * 0.4 - 50, -15)
	print(volume_db)
