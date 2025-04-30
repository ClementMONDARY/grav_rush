extends Node
class_name AudioContainer

var audios: Dictionary = {}

func _ready() -> void:
	for audio in get_children():
		if audio is AudioStreamPlayer2D:
			audios[audio.name.to_lower()] = audio
