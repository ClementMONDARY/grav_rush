extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree: AnimationTree = %AnimationTreeSprite
@onready var standing_hitbox: CollisionShape2D = $"../../StandingHitbox"
@onready var crouching_hitbox: CollisionShape2D = $"../../CrouchingHitbox"
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D

@onready var dash_component: DashComponent = %DashComponent
@onready var jump_component: JumpComponent = %JumpComponent
@onready var ground_control_component: GroundControlComponent = %GroundControlComponent

func Enter() -> void:
	_toggle_hitbox()
	anim_tree.get("parameters/playback").travel("Crouch")

func Exit() -> void:
	_toggle_hitbox()
	player.move_and_slide()

func _input(event: InputEvent) -> void:
	if _handle_uncrouch(event) : return
	if _handle_dash(event): return
	if _handle_wall_grab(event): return
	if _handle_ground_attack(event): return

func Physics_Update(delta: float) -> void:
	_handle_sprite_flip()
	if _handle_parade(): return
	if _handle_jump(): return
	
	_apply_slide(delta)
	player.move_and_slide()

# --- Logic split below ---

func _handle_parade() -> bool:
	if Input.is_action_pressed("parade"):
		Transitioned.emit(self, "parade")
		return true
	return false

func _handle_uncrouch(event: InputEvent) -> bool:
	if event.is_action_released("crouch"):
		Transitioned.emit(self, "idle")
		return true
	return false

func _apply_slide(delta: float) -> void:
	# Décélération progressive vers 0
	player.velocity.x = move_toward(
		player.velocity.x,
		0,
		ground_control_component.SLIDE_FRICTION * delta
	)

func _handle_jump() -> bool:
	if jump_component.has_buffered_jump():
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash(event: InputEvent) -> bool:
	if event.is_action_pressed("dash") and PlayerManager.can_dash and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_wall_grab(event: InputEvent) -> bool:
	if wall_detector.is_colliding() and event.is_action_pressed("wall_grab"):
		AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
		Transitioned.emit(self, "wallgrab")
		return true
	return false

func _handle_ground_attack(event: InputEvent) -> bool:
	if event.is_action_pressed("attack") and PlayerManager.can_attack:
		Transitioned.emit(self, "attack")
		return true
	return false

func _handle_sprite_flip() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir > 0:
		sprite.scale.x = 1.0
	elif input_dir < 0:
		sprite.scale.x = -1.0

func _toggle_hitbox() -> void:
	var temp = standing_hitbox.disabled
	standing_hitbox.disabled = crouching_hitbox.disabled
	crouching_hitbox.disabled = temp
