extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree_sprite: AnimationTree = %AnimationTreeSprite
@onready var anim_tree_particules: AnimationTree = %AnimationTreeParticules
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D

@onready var jump_component: JumpComponent = %JumpComponent
@onready var dash_component: DashComponent = %DashComponent
@onready var speed_component: SpeedComponent = %SpeedComponent
@onready var stamina_component: StaminaComponent = %StaminaComponent
@onready var air_control_component: AirControlComponent = %AirControlComponent

var wall_direction: int = 0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	_play_jump_animations()
	_apply_initial_jump_velocity()
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_JUMP)
	dash_component.add_dash()
	jump_component.consume_jump_buffer()
	jump_component.consume_coyote_time()

func Physics_Update(delta: float) -> void:
	_apply_variable_jump_height()
	_apply_gravity(delta)
	_handle_double_jump()
	_apply_air_control(delta)
	_flip_sprite()
	player.move_and_slide()
	if _handle_wall_interaction():
		return
	if _handle_air_dash():
		return
	if _handle_fall_transition():
		return

# --- Logic split below ---

func _play_jump_animations() -> void:
	if player.is_on_floor() or jump_component.has_coyote_time():
		anim_tree_sprite.set("parameters/Jump/FloorContext/blend_position", -1.0)
	else:
		anim_tree_sprite.set("parameters/Jump/FloorContext/blend_position", 1.0)
	anim_tree_sprite.get("parameters/playback").travel("Jump")
	anim_tree_particules.get("parameters/playback").travel("Jump")

func _apply_initial_jump_velocity() -> void:
	player.velocity.y = -jump_component.JUMP_FORCE

func _apply_variable_jump_height() -> void:
	if !Input.is_action_pressed("jump"):
		player.velocity.y *= 0.8

func _apply_gravity(delta: float) -> void:
	player.velocity.y += gravity * delta

func _handle_double_jump() -> void:
	if Input.is_action_just_pressed("jump") and jump_component.can_double_jump():
		jump_component.use_bonus_jump()
		Transitioned.emit(self, "jump")
		return

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
	if wall_detector.is_colliding():
		if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
			AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
			Transitioned.emit(self, "wallgrab")
			return true
		elif jump_component.has_buffered_jump():
			_handle_wall_jump()
			return true
	return false

func _handle_wall_jump() -> void:
	var collision_pos = wall_detector.get_collision_point()
	wall_direction = sign(player.global_position.x - collision_pos.x)
	player.velocity.x = wall_direction * jump_component.JUMP_FORCE / 2.0
	sprite.scale.x = -sprite.scale.x
	player.move_and_slide()
	Transitioned.emit(self, "jump")

func _handle_air_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_fall_transition() -> bool:
	if player.velocity.y >= 0:
		Transitioned.emit(self, "fall")
		return true
	return false
