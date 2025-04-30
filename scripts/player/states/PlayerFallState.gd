extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent

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
	
	# Horizontal movement
	var input_dir = Input.get_axis("move_left", "move_right")
	player.velocity.x = input_dir * speed_component.speed
	
	# Flip sprite based on direction
	if input_dir > 0:
		animation_manager.flip_sprite(false)
	elif input_dir < 0:
		animation_manager.flip_sprite(true)
	
	player.move_and_slide()
	
	# Transition to idle or run when landing
	if player.is_on_floor():
		if input_dir == 0:
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
