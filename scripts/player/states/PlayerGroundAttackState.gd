extends State

@onready var player_animated_sprite_2d: AnimatedSprite2D = %PlayerAnimatedSprite2D
@onready var attack_hitbox_area: Area2D = $"../../PlayerAnimatedSprite2D/Hitboxes/AttackboxArea"
@onready var animation_tree_sprite: AnimationTree = %AnimationTreeSprite

func Enter() -> void:
	await get_tree().physics_frame
	animation_tree_sprite.get("parameters/playback").travel("GroundAttack")

func Exit() -> void:
	attack_hitbox_area.set_monitoring(false)

func _on_animation_player_sprite_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ground_attack":
		Transitioned.emit(self, "run" if Input.get_axis("move_left", "move_right") else "idle")

func _play_attack_audio() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var overlapping_areas = attack_hitbox_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		var is_enemy = area.get_collision_layer_value(3)
		var is_world = area.get_collision_layer_value(1)
		if is_enemy:
			AudioManager.create_2d_audio_at_location(player_animated_sprite_2d.get_global_position(), SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_ATTACK_HIT_ENNEMY)
			return
		elif is_world:
			AudioManager.create_2d_audio_at_location(player_animated_sprite_2d.get_global_position(), SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_ATTACK_HIT_WORLD)
			return
	AudioManager.create_2d_audio_at_location(player_animated_sprite_2d.get_global_position(), SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_ATTACK_MISS)
