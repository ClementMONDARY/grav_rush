extends RayCast2D

@export var animation_manager: AnimationManager

var last_flip_h := false

func _physics_process(_delta: float) -> void:
	var current_flip = animation_manager.animated_sprite.flip_h
	if current_flip != last_flip_h:
		scale.x = -1 if current_flip else 1
		last_flip_h = current_flip
