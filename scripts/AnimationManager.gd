extends Node
class_name AnimationManager

@export var animated_sprite: AnimatedSprite2D
@export var animation_player: AnimationPlayer
@export var audio_container: AudioContainer

func play(animation_name: String) -> void:
	animation_name.to_lower()
	
	play_sprite_animation(animation_name)
	play_animation(animation_name)
	play_audio(animation_name)

func play_random_frame(animation_name: String) -> void:
	animation_name.to_lower()
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
		animated_sprite.frame = randi_range(0, animated_sprite.sprite_frames.get_frame_count(animation_name) - 1)

func play_sprite_animation(animation_name: String) -> void:
	animation_name.to_lower()
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)

func play_animation(animation_name: String) -> void:
	animation_name.to_lower()
	
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

func play_audio(audio_name: String) -> void:
	audio_name.to_lower()
	
	if audio_container and audio_container.audios.has(audio_name):
		audio_container.audios.get(audio_name).play()

func flip_sprite(flip_h: bool = false, flip_v: bool = false) -> void:
	if animated_sprite:
		animated_sprite.flip_h = flip_h
		animated_sprite.flip_v = flip_v
