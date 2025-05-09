extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree: AnimationTree = %AnimationTreeSprite
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D
@onready var landing_particules: PackedScene = preload("res://scenes/player/particules/landing_cpu_particles_2d.tscn")

@onready var jump_component: JumpComponent = %JumpComponent
@onready var dash_component: DashComponent = %DashComponent
@onready var speed_component: SpeedComponent = %SpeedComponent
@onready var stamina_component: StaminaComponent = %StaminaComponent
@onready var air_control_component: AirControlComponent = %AirControlComponent

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0

func Enter() -> void:
	anim_tree.get("parameters/playback").travel("Fall")

func Physics_Update(delta: float) -> void:
	_apply_gravity(delta)
	_apply_air_control(delta)
	_flip_sprite()
	player.move_and_slide()

	if _handle_wall_interaction():
		return

	if _handle_jump():
		return

	if _handle_dash():
		return

	if _handle_landing():
		return

# --- Logic split below ---

func _apply_gravity(delta: float) -> void:
	player.velocity.y = min(player.velocity.y + gravity * delta * air_control_component.GRAVITY_FALL_MULTIPLIER, 400)

func _apply_air_control(delta: float) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		var target_velocity = input_dir * speed_component.x_speed
		player.velocity.x = lerp(player.velocity.x, target_velocity, air_control_component.ACCELERATION * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, air_control_component.FRICTION * delta)

func _flip_sprite() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir > 0:
		sprite.scale.x = 1.0
	elif input_dir < 0:
		sprite.scale.x = -1.0

func _handle_wall_interaction() -> bool:
	if not wall_detector.is_colliding():
		return false
	
	var input_dir = Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
		AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
		Transitioned.emit(self, "wallgrab")
		return true
	elif input_dir != 0:
		Transitioned.emit(self, "wallslide")
		return true
	elif jump_component.has_buffered_jump():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
		player.velocity.x = wall_direction * jump_component.JUMP_FORCE / 2.0
		sprite.scale.x = -sprite.scale.x
		player.move_and_slide()
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_jump() -> bool:
	if jump_component.has_coyote_time() and jump_component.has_buffered_jump():
		Transitioned.emit(self, "jump")
		return true
	if jump_component.can_double_jump() and jump_component.has_buffered_jump():
		jump_component.use_bonus_jump()
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_landing() -> bool:
	if player.is_on_floor():
		_play_landing_particules()
		jump_component.refill_bonus_jump()
		Transitioned.emit(self, "run" if player.velocity.x != 0 else "idle")
		return true
	return false

func _play_landing_particules() -> void:
	var p = landing_particules.instantiate()
	sprite.add_child(p)
	p.emitting = true

	await get_tree().create_timer(p.lifetime).timeout
	p.queue_free()
