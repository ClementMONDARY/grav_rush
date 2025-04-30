extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	if jump_component.jumps_remaining == jump_component.max_jumps:
		animation_manager.play("jump")
	else:
		animation_manager.play("double_jump")
	player.velocity.y = -jump_component.jump_force
	jump_component.jumps_remaining -= 1
	dash_component.add_dash()

func Physics_Update(delta: float) -> void:
	# Apply gravity
	player.velocity.y += gravity * delta
	
	# Double jump check
	if Input.is_action_just_pressed("jump") and jump_component.jumps_remaining > 0:
		animation_manager.play("double_jump")
		player.velocity.y = -jump_component.jump_force
		jump_component.jumps_remaining -= 1
		dash_component.add_dash()
	
	# Horizontal movement
	var input_dir = Input.get_axis("move_left", "move_right")
	player.velocity.x = input_dir * speed_component.speed
	
	if input_dir > 0:
		animation_manager.flip_sprite(false)
	elif input_dir < 0:
		animation_manager.flip_sprite(true)
	
	player.move_and_slide()
	
	# Air dash transition
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "airdash")
		return
	
	# Transition to fall state when velocity is positive (falling)
	if player.velocity.y > 0:
		Transitioned.emit(self, "fall")
