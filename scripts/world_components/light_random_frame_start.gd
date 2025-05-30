extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	var anim_name = "idle"
	var length = anim_player.get_animation(anim_name).length
	var random_offset = randf() * length
	anim_player.play(anim_name)
	anim_player.seek(random_offset, true) # true = update immediately
