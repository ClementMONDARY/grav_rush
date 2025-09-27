extends State

@onready var player: CharacterBody2D = $"../.."
@onready var player_animated_sprite_2d: AnimatedSprite2D = %PlayerAnimatedSprite2D
@onready var attack_hitbox_area: Area2D = $"../../PlayerAnimatedSprite2D/Hitboxes/AttackboxArea"
@onready var animation_tree_sprite: AnimationTree = %AnimationTreeSprite
@onready var jump_component: JumpComponent = %JumpComponent
@onready var ground_control_component: GroundControlComponent = %GroundControlComponent
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D
@onready var air_control_component: AirControlComponent = %AirControlComponent
@onready var speed_component: SpeedComponent = %SpeedComponent

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	await get_tree().physics_frame
	animation_tree_sprite.get("parameters/playback").travel("Attack")

func Exit() -> void:
	if attack_hitbox_area.is_monitoring():
		attack_hitbox_area.set_monitoring(false)

func Physics_Update(delta: float) -> void:
	if not player.is_on_floor():
		_handle_air_control(delta)
		_flip_sprite()
		player.move_and_slide()
		return

	if _handle_jump():
		player.move_and_slide()
		return

	_handle_horizontal_movement(delta)
	_flip_sprite()
	player.move_and_slide()

func _on_animation_player_sprite_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ground_attack":
		var direction = Input.get_axis("move_left", "move_right")
		Transitioned.emit(self, "run" if direction else "idle")
		player.move_and_slide()

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

func _handle_air_control(delta: float) -> void:
	player.velocity.y = min(player.velocity.y + gravity * delta * air_control_component.GRAVITY_FALL_MULTIPLIER, 400)
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		var target_velocity = input_dir * speed_component.x_speed
		player.velocity.x = lerp(player.velocity.x, target_velocity, air_control_component.ACCELERATION * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, air_control_component.FRICTION * delta)

func _handle_jump() -> bool:
	if jump_component.has_buffered_jump():
		player.velocity.y = -jump_component.JUMP_FORCE
		AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_JUMP)
		return true
	return false

func _handle_horizontal_movement(delta: float) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	
	if input_dir == 0:
		# Décélération
		player.velocity.x = move_toward(
			player.velocity.x, 
			0, 
			ground_control_component.SLIDE_FRICTION * delta
		)
	else:
		# Calcul de la vitesse cible
		var target_speed = input_dir * ground_control_component.max_speed
		
		# Accélération progressive
		player.velocity.x = move_toward(
			player.velocity.x,
			target_speed,
			ground_control_component.acceleration * delta
		)

func _flip_sprite() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir > 0:
		sprite.scale.x = 1.0
	elif input_dir < 0:
		sprite.scale.x = -1.0
