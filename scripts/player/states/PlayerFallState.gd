extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	animation_manager.play("fall")

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(delta: float) -> void:
	# Double jump check
	if Input.is_action_just_pressed("jump") and jump_component.jumps_remaining > 0:
		Transitioned.emit(self, "jump")
		return

	# Apply gravity
	player.velocity.y += gravity * delta
	
	# Horizontal mvement
	var input_dir = Input.get_axis("move_left", "move_right")
	player.velocity.x = input_dir * speed_component.speed
	
	# Flip sprite based on direction
	if input_dir > 0:
		animation_manager.flip_sprite(false)
	elif input_dir < 0:
		animation_manager.flip_sprite(true)
	 
	player.move_and_slide()
	
	# Air dash transition
	if Input.is_action_just_pressed("dash") and dash_component.can_dash:
		Transitioned.emit(self, "airdash")
		return
	
	# Transition to idle or run when landing
	if player.is_on_floor():
		jump_component.jumps_remaining = jump_component.max_jumps
		if input_dir == 0:
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
