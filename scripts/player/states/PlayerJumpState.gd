extends State

@export var sprite: AnimatedSprite2D
@export var anim_tree: AnimationTree
@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent
@export var stamina_component: StaminaComponent
@export var air_control_component: AirControlComponent
@export var wall_detector: RayCast2D

var wall_direction: int = 0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	_play_jump_animation()
	_apply_initial_jump_velocity()
	jump_component.jumps_remaining -= 1
	dash_component.add_dash()

func Physics_Update(delta: float) -> void:
	_apply_gravity(delta)
	if _handle_double_jump():
		return
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

func _play_jump_animation() -> void:
	if player.is_on_floor():
		anim_tree.set("parameters/Jump/FloorContext/blend_position", -1.0)
	else:
		anim_tree.set("parameters/Jump/FloorContext/blend_position", 1.0)
	anim_tree.get("parameters/playback").travel("Jump")

func _apply_initial_jump_velocity() -> void:
	player.velocity.y = -jump_component.jump_force

func _apply_gravity(delta: float) -> void:
	player.velocity.y += gravity * delta

func _handle_double_jump() -> bool:
	if Input.is_action_just_pressed("jump") and jump_component.jumps_remaining > 0:
		Transitioned.emit(self, "jump")
		return true
	return false

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
		sprite.flip_h = false
	elif input_dir < 0:
		sprite.flip_h = true

func _handle_wall_interaction() -> bool:
	if wall_detector.is_colliding():
		if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
			AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
			Transitioned.emit(self, "wallgrab")
			return true
		elif Input.is_action_just_pressed("jump"):
			_handle_wall_jump()
			return true
		elif Input.get_axis("move_left", "move_right") != 0:
			Transitioned.emit(self, "wallslide")
			return true
	return false

func _handle_wall_jump() -> void:
	var collision_pos = wall_detector.get_collision_point()
	wall_direction = sign(player.global_position.x - collision_pos.x)
	jump_component.jumps_remaining += 1
	player.velocity.x = wall_direction * jump_component.jump_force / 2.0
	animation_manager.flip_sprite(true)
	player.move_and_slide()
	Transitioned.emit(self, "jump")

func _handle_air_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_fall_transition() -> bool:
	if player.velocity.y > 0:
		Transitioned.emit(self, "fall")
		return true
	return false
