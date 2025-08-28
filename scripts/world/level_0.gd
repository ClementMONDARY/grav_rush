extends Node2D

func _ready() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.LEVEL_MUSIC)
