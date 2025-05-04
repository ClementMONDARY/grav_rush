extends Node2D
class_name AnimationManager

@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer

func play(animation_name: String, reverse: bool = false) -> void:
	animation_name.to_lower()
	
	play_animation_player(animation_name, reverse)

func play_animation_player(animation_name: String, reverse: bool = false) -> void:
	animation_name.to_lower()
	
	if animation_player and animation_player.has_animation(animation_name):
		if reverse:
			animation_player.play_backwards(animation_name)
		else:
			animation_player.play(animation_name)

func flip_sprite(flip_h: bool = true, flip_v: bool = true) -> void:
	if sprite:
		sprite.flip_h = !sprite.flip_h if flip_h else sprite.flip_h
		sprite.flip_v = !sprite.flip_v if flip_v else sprite.flip_v
