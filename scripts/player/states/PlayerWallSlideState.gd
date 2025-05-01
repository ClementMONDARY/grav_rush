extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var stamina_component: StaminaComponent
@export var jump_component: JumpComponent
@export var wall_detector: RayCast2D

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
	animation_manager.play("wall_slide")
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
	if player.velocity.y > 0:
		player.velocity.y = min(player.velocity.y + gravity * 0.1 * delta, 200)
	else:
		player.velocity.y += gravity * delta
	player.velocity.x = -wall_direction * 2

func _check_for_fall() -> void:
	if player.is_on_floor():
		Transitioned.emit(self, "idle")

func _handle_movement(delta: float) -> void:
	if Input.get_axis("move_left", "move_right") != -wall_direction:
		Transitioned.emit(self, "fall")

func _handle_wall_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_component.jumps_remaining += 1
		if Input.get_axis("move_left", "move_right") != 0:
			player.velocity.x = wall_direction * jump_component.jump_force
		else:
			player.velocity.x = wall_direction * jump_component.jump_force / 2.0
		animation_manager.flip_sprite(true, false)
		player.move_and_slide()
		Transitioned.emit(self, "jump")

func _handle_wall_grab() -> void:
	if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
		Transitioned.emit(self, "wallgrab")
