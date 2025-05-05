extends State

@export var sprite: AnimatedSprite2D
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var stamina_component: StaminaComponent
@export var dash_component: DashComponent
@export var wall_detector: RayCast2D
@export var ground_control_component: GroundControlComponent
@export var anim_tree: AnimationTree

func Enter() -> void:
	anim_tree.get("parameters/playback").travel("Run")
	stamina_component.refill_stamina()
	dash_component.refill_dash()

func Physics_Update(delta: float) -> void:
	if _handle_airborne():
		return
	if _handle_jump():
		return
	if _handle_dash():
		return

	_handle_horizontal_movement(delta)
	_flip_sprite()
	player.move_and_slide()

	if _handle_wall_grab():
		return
	if _handle_idle_transition():
		return

# --- Logic split below ---

func _handle_airborne() -> bool:
	if not player.is_on_floor():
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_jump() -> bool:
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_horizontal_movement(delta: float) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		player.velocity.x = move_toward(player.velocity.x, 0, ground_control_component.slide_friction * 3.0 * delta)
	else:
		player.velocity.x = input_dir * speed_component.speed

func _flip_sprite() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir > 0:
		sprite.flip_h = false
	elif input_dir < 0:
		sprite.flip_h = true

func _handle_wall_grab() -> bool:
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
		Transitioned.emit(self, "wallgrab")
		return true
	return false

func _handle_idle_transition() -> bool:
	var input_dir = Input.get_axis("move_left", "move_right")
	if abs(player.velocity.x) < 5.0 and input_dir == 0:
		Transitioned.emit(self, "idle")
		return true
	return false
