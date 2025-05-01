extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent
@export var air_control_component: AirControlComponent
@export var stamina_component: StaminaComponent
@export var wall_detector: RayCast2D

var wall_direction: int = 0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	animation_manager.play("fall")

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(delta: float) -> void:
	# Apply gravity
	player.velocity.y += gravity * delta

	# Horizontal air control
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		var target_velocity = input_dir * speed_component.speed
		player.velocity.x = lerp(player.velocity.x, target_velocity, air_control_component.acceleration * delta)
	else:
		# Apply horizontal air friction
		player.velocity.x = move_toward(player.velocity.x, 0, air_control_component.friction * delta)

	# Flip sprite based on direction
	if input_dir > 0:
		animation_manager.animated_sprite.flip_h = false
	elif input_dir < 0:
		animation_manager.animated_sprite.flip_h = true

	player.move_and_slide()

	# Check for wall
	if wall_detector.is_colliding():
		# Grab if pressed and stamina up
		if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
			Transitioned.emit(self, "wallgrab")
			return
		# Else slide
		elif input_dir != 0:
			Transitioned.emit(self, "wallslide")
			return
		# Else jump if pressed
		elif Input.is_action_just_pressed("jump"):
			var collision_pos = wall_detector.get_collision_point()
			wall_direction = sign(player.global_position.x - collision_pos.x)
			jump_component.jumps_remaining += 1
			player.velocity.x = wall_direction * jump_component.jump_force / 2.0
			animation_manager.flip_sprite(true, false)
			player.move_and_slide()
			Transitioned.emit(self, "jump")
			return
	
	# Double jump check
	if Input.is_action_just_pressed("jump") and jump_component.jumps_remaining > 0:
		Transitioned.emit(self, "jump")
		return

	# Air dash transition
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "airdash")
		return

	# Transition to idle or run on landing
	if player.is_on_floor():
		jump_component.jumps_remaining = jump_component.max_jumps
		dash_component.remaining_dashs = dash_component.max_dash
		if input_dir == 0:
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
