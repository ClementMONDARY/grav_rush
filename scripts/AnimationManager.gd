extends Node
class_name AnimationManager

@export var animated_sprite: AnimatedSprite2D
@export var animation_player: AnimationPlayer

func play(animation_name: String, reverse: bool = false) -> void:
	animation_name.to_lower()
	
	play_sprite_animation(animation_name, reverse)
	play_animation_player(animation_name, reverse)

func play_random_frame(animation_name: String) -> void:
	animation_name.to_lower()
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
		animated_sprite.frame = randi_range(0, animated_sprite.sprite_frames.get_frame_count(animation_name) - 1)

func play_sprite_animation(animation_name: String, reverse: bool = false) -> void:
	animation_name.to_lower()
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
		if reverse:
			animated_sprite.speed_scale = -1
			# Se positionner sur le dernier frame pour jouer à l'envers
			animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count(animation_name) - 1
		else:
			animated_sprite.speed_scale = 1
			animated_sprite.frame = 0

func play_animation_player(animation_name: String, reverse: bool = false) -> void:
	animation_name.to_lower()
	
	if animation_player and animation_player.has_animation(animation_name):
		if reverse:
			animation_player.play_backwards(animation_name)
		else:
			animation_player.play(animation_name)

func flip_sprite(flip_h: bool = true, flip_v: bool = true) -> void:
	if animated_sprite:
		animated_sprite.flip_h = !animated_sprite.flip_h if flip_h else animated_sprite.flip_h
		animated_sprite.flip_v = !animated_sprite.flip_v if flip_v else animated_sprite.flip_v
