extends Node

@export var audio_player_node: Node2D

var audio_player_gp: Vector2 = Vector2.ZERO

func _ready() -> void:
	if audio_player_node:
		audio_player_gp = audio_player_node.global_position

enum FUNC_TYPE {
	DEFAULT,
	AT_LOCATION,
	AT_LOCATION_WITH_CULLING
}

func play_audio(func_type: FUNC_TYPE, audio_type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	match func_type:
		FUNC_TYPE.DEFAULT:
			AudioManager.create_audio(audio_type)
		FUNC_TYPE.AT_LOCATION:
			AudioManager.create_2d_audio_at_location(audio_player_gp, audio_type)
		FUNC_TYPE.AT_LOCATION_WITH_CULLING:
			AudioManager.create_2d_audio_at_location_with_culling(audio_player_gp, audio_type)
