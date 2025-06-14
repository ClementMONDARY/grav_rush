extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree: AnimationTree = %AnimationTreeSprite
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D

@onready var jump_component: JumpComponent = %JumpComponent
@onready var stamina_component: StaminaComponent = %StaminaComponent
@onready var wall_control_component: WallControlComponent = %WallControlComponent

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0

func Enter() -> void:
	_start_wall_slide()

func Physics_Update(delta: float) -> void:
	_update_wall_collision()
	_apply_gravity(delta)
	_check_for_fall()
	_handle_movement(delta)
	_handle_wall_jump()
	_handle_wall_grab()

	player.move_and_slide()

# --- Logic split below ---

func _start_wall_slide() -> void:
	anim_tree.get("parameters/playback").travel("WallSlide")
	_update_wall_direction()

func _update_wall_direction() -> void:
	if wall_detector.is_colliding():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
	else:
		wall_direction = 0

func _update_wall_collision() -> void:
	if not wall_detector.is_colliding():
		Transitioned.emit(self, "fall")

func _apply_gravity(delta: float) -> void:
	if player.velocity.y > 0 and player.velocity.y < 50:
		player.velocity.y += min(gravity * wall_control_component.SLIDE_FACTOR * delta, 10)
	else:
		player.velocity.y += gravity * delta
	player.velocity.y = min(player.velocity.y, 100)
	player.velocity.x = -wall_direction * 2

func _check_for_fall() -> void:
	if player.is_on_floor():
		jump_component.refill_bonus_jump()
		Transitioned.emit(self, "run")

func _handle_movement(_delta: float) -> void:
	if Input.get_axis("move_left", "move_right") != -wall_direction:
		Transitioned.emit(self, "fall")

func _handle_wall_jump() -> void:
	if jump_component.has_buffered_jump():
		jump_component.refill_bonus_jump(1)
		if Input.get_axis("move_left", "move_right") != 0:
			player.velocity.x = wall_direction * jump_component.JUMP_FORCE / 2.0
		else:
			player.velocity.x = wall_direction * jump_component.JUMP_FORCE / 4.0
		sprite.scale.x = -sprite.scale.x
		player.move_and_slide()
		Transitioned.emit(self, "jump")

func _handle_wall_grab() -> void:
	if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
		AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
		Transitioned.emit(self, "wallgrab")
