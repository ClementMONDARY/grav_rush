extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree: AnimationTree = %AnimationTreeSprite
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D

@onready var jump_component: JumpComponent = %JumpComponent
@onready var stamina_component: StaminaComponent = %StaminaComponent
@onready var wall_control_component: WallControlComponent = %WallControlComponent

const CLIMB_STAMINA_MULTIPLIER := 1.5

var wall_direction: int = 0
var current_animation_state: String = ""
var input_dir = Input.get_axis("move_up", "move_down")

func Enter() -> void:
	_start_wall_climb()

func Physics_Update(_delta: float) -> void:
	_handle_climb_movement()
	_handle_stamina()
	_handle_wall_jump()
	_check_wall_climb_conditions()

	player.move_and_slide()

# --- Logic split below ---

func _start_wall_climb() -> void:
	player.velocity = Vector2.ZERO
	input_dir = Input.get_axis("move_up", "move_down")
	anim_tree.set("parameters/WallClimb/InputDir/blend_position", -1.0 if input_dir < 0 else 1.0)
	anim_tree.get("parameters/playback").travel("WallClimb")
	_update_wall_direction()

func _update_wall_direction() -> void:
	if wall_detector.is_colliding():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
	else:
		wall_direction = 0

func _handle_climb_movement() -> void:
	input_dir = Input.get_axis("move_up", "move_down")
	player.velocity.y = input_dir * wall_control_component.CLIMBING_SPEED
	player.velocity.x = -wall_direction * 2

func _handle_stamina() -> void:
	if input_dir < 0:
		stamina_component.drain_stamina(stamina_component.stamina_drain_value * stamina_component.CLIMB_STAMINA_MULTIPLIER)
	elif input_dir > 0:
		stamina_component.drain_stamina(0.0)
	else:  # Ne bouge pas
		Transitioned.emit(self, "wallgrab")
		return

	if stamina_component.stamina <= 0:
		Transitioned.emit(self, "wallgrab")

func _handle_wall_jump() -> void:
	if jump_component.has_buffered_jump():
		jump_component.refill_bonus_jump(1)
		player.velocity.x = wall_direction * jump_component.JUMP_FORCE / 2.0
		sprite.scale.x = -sprite.scale.x
		player.move_and_slide()
		Transitioned.emit(self, "jump")

func _check_wall_climb_conditions() -> void:
	if not wall_detector.is_colliding() or Input.is_action_just_released("wall_grab"):
		Transitioned.emit(self, "fall")
