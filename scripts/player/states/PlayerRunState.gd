extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var stamina_component: StaminaComponent
@export var dash_component: DashComponent
@export var wall_detector: RayCast2D

func Enter() -> void:
	animation_manager.play("run")
	stamina_component.refill_stamina()
	dash_component.refill_dash()

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	if not player.is_on_floor():
		Transitioned.emit(self, "jump")
		return

	var input_dir = Input.get_axis("move_left", "move_right")

	if input_dir == 0:
		Transitioned.emit(self, "idle")
		return

	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return

	# Air dash transition
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "grounddash")
		return

	player.velocity.x = input_dir * speed_component.speed

	# Flip sprite based on direction
	if input_dir > 0:
		animation_manager.flip_sprite(false)
	elif input_dir < 0:
		animation_manager.flip_sprite(true)
	
	player.move_and_slide()
	
	# Check for wall grab using raycasts
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		Transitioned.emit(self, "wallgrab")
		return
