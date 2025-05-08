extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree: AnimationTree = %AnimationTreeSprite

@onready var dash_component: DashComponent = %DashComponent
@onready var jump_component: JumpComponent = %JumpComponent
@onready var stamina_component: StaminaComponent = %StaminaComponent
@onready var ground_control_component: GroundControlComponent = %GroundControlComponent

func Enter() -> void:
	anim_tree.get("parameters/playback").travel("Idle")
	stamina_component.refill_stamina()
	dash_component.refill_dash()

func Physics_Update(delta: float) -> void:
	if _handle_airborne():
		return

	_apply_slide(delta)

	if _handle_run():
		return
	if _handle_jump():
		return
	if _handle_dash():
		return
	if _handle_wall_grab():
		return

	player.move_and_slide()

# --- Logic split below ---

func _handle_airborne() -> bool:
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return true
	return false

func _apply_slide(delta: float) -> void:
	if Input.get_axis("move_left", "move_right") == 0:
		player.velocity.x = move_toward(player.velocity.x, 0, ground_control_component.SLIDE_FRICTION * delta)

func _handle_run() -> bool:
	if Input.get_axis("move_left", "move_right") != 0:
		Transitioned.emit(self, "run")
		return true
	return false

func _handle_jump() -> bool:
	if jump_component.has_buffered_jump():
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_wall_grab() -> bool:
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
		Transitioned.emit(self, "wallgrab")
		return true
	return false
