extends State

@onready var player: CharacterBody2D = $"../.."

@onready var anim_tree: AnimationTree = %AnimationTreeSprite
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D

@onready var dash_component: DashComponent = %DashComponent
@onready var jump_component: JumpComponent = %JumpComponent
@onready var stamina_component: StaminaComponent = %StaminaComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	_start_dash()

func Exit() -> void:
	pass

func Physics_Update(delta: float) -> void:
	_update_dash_timer(delta)
	_check_for_jump()
	_check_for_dash_end()
	player.move_and_slide()

# --- Logic split below ---

func _start_dash() -> void:
	dash_component.use_dash()
	if player.is_on_floor():
		anim_tree.set("parameters/Dash/FloorContext/blend_position", -1.0)
	else:
		anim_tree.set("parameters/Dash/FloorContext/blend_position", 1.0)
	anim_tree.get("parameters/playback").travel("Dash")
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_DASH)
	dash_timer = dash_component.dash_duration
	dash_direction = sprite.scale.x
	player.velocity.x = dash_direction * dash_component.dash_speed
	player.velocity.y = 0

func _update_dash_timer(delta: float) -> void:
	dash_timer -= delta

func _check_for_jump() -> void:
	if jump_component.has_buffered_jump() && player.is_on_floor():
		player.velocity.x *= 1.5
		Transitioned.emit(self, "jump")
		return

func _check_for_dash_end() -> void:
	if dash_timer <= 0:
		if player.is_on_floor():
			Transitioned.emit(self, "run")
		else:
			Transitioned.emit(self, "fall")
		return

func instantiate_ghosts() -> void:
	var ghost_count = 4
	var interval = dash_component.dash_duration / ghost_count

	for i in range(ghost_count):
		await get_tree().create_timer(interval).timeout
		
		var ghost_sprite = new_ghost_sprite()

		get_tree().current_scene.add_child(ghost_sprite)

		var tween = get_tree().create_tween()
		tween.tween_property(ghost_sprite, "modulate:a", 0, 0.3)  # Alpha de 0.5 à 0 sur 0.4s
		tween.tween_callback(Callable(ghost_sprite, "queue_free"))
		tween.play()

func new_ghost_sprite() -> AnimatedSprite2D:
	var ghost_sprite = AnimatedSprite2D.new()
	ghost_sprite.sprite_frames = sprite.sprite_frames
	ghost_sprite.animation = sprite.animation
	ghost_sprite.frame = sprite.frame
	ghost_sprite.position.x = player.global_position.x
	ghost_sprite.position.y = player.global_position.y - 18.0
	ghost_sprite.scale = sprite.scale
	ghost_sprite.modulate = Color(1, 1, 1, 0.3)
	if stamina_component.stamina <= stamina_component.low_stamina_threshold:
		ghost_sprite.modulate = Color(1.0, 0.407843, 0.337254, 0.3)  # Color(ff6856) with alpha 0.3
	return ghost_sprite
