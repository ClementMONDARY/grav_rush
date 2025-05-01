extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var jump_component: JumpComponent
@export var stamina_component: StaminaComponent
@export var wall_detector: RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0
var current_animation: String = ""

func Enter() -> void:
	_start_wall_grab()

func Physics_Update(_delta: float) -> void:
	_handle_stamina()
	_handle_wall_release()
	_handle_wall_climb()
	_handle_wall_jump()
	_check_wall_grab_conditions()

	player.move_and_slide()

# --- Logic split below ---

func _start_wall_grab() -> void:
	animation_manager.play("wall_grab")
	player.velocity = Vector2.ZERO
	_update_wall_direction()

func _update_wall_direction() -> void:
	if wall_detector.is_colliding():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
	else:
		wall_direction = 0

func _handle_stamina() -> void:
	stamina_component.drain_stamina()
	if stamina_component.stamina <= 0:
		Transitioned.emit(self, "wallslide")

func _handle_wall_release() -> void:
	if Input.get_axis("move_left", "move_right") == wall_direction:
		_play_animation("wall_slide")
		if Input.is_action_just_pressed("dash"):
			animation_manager.flip_sprite(true, false)
			Transitioned.emit(self, "airdash")
	else:
		_play_animation("wall_grab")

func _handle_wall_climb() -> void:
	var vertical_input = Input.get_axis("move_up", "move_down")
	if vertical_input != 0 and stamina_component.stamina > 0:
		Transitioned.emit(self, "wallclimb")

func _handle_wall_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_component.jumps_remaining += 1
		if Input.get_axis("move_left", "move_right") == -wall_direction:
			player.velocity.x = wall_direction * jump_component.jump_force
			stamina_component.drain_stamina(200.0)
		else:
			player.velocity.x = wall_direction * jump_component.jump_force / 2.0
		animation_manager.flip_sprite(true, false)
		player.move_and_slide()
		Transitioned.emit(self, "jump")

func _check_wall_grab_conditions() -> void:
	if not wall_detector.is_colliding() or Input.is_action_just_released("wall_grab"):
		Transitioned.emit(self, "fall")

func _play_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		current_animation = anim_name
		animation_manager.play_sprite_animation(anim_name)
