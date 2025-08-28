extends RayCast2D

var sprite: AnimatedSprite2D

var last_flip_h := false

func _ready() -> void:
	sprite = get_parent()

func _physics_process(_delta: float) -> void:
	var current_flip = sprite.flip_h
	if current_flip != last_flip_h:
		scale.x = -1 if current_flip else 1
		last_flip_h = current_flip
