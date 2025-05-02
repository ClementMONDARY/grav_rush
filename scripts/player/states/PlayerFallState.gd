extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent
@export var air_control_component: AirControlComponent
@export var stamina_component: StaminaComponent
@export var wall_detector: RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0

func Enter() -> void:
	animation_manager.play("fall")

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
	player.velocity.y += gravity * delta

func _apply_air_control(delta: float) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		var target_velocity = input_dir * speed_component.speed
		player.velocity.x = lerp(player.velocity.x, target_velocity, air_control_component.acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, air_control_component.friction * delta)

func _flip_sprite() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir > 0:
		animation_manager.animated_sprite.flip_h = false
	elif input_dir < 0:
		animation_manager.animated_sprite.flip_h = true

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
	elif Input.is_action_just_pressed("jump"):
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
		jump_component.jumps_remaining += 1
		player.velocity.x = wall_direction * jump_component.jump_force / 2.0
		animation_manager.flip_sprite(true, false)
		player.move_and_slide()
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_jump() -> bool:
	if Input.is_action_just_pressed("jump") and jump_component.jumps_remaining > 0:
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "airdash")
		return true
	return false

func _handle_landing() -> bool:
	if player.is_on_floor():
		jump_component.jumps_remaining = jump_component.max_jumps
		dash_component.remaining_dashs = dash_component.max_dash
		Transitioned.emit(self, "idle")
		return true
	return false
