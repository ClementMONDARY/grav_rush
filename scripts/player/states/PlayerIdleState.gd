extends State

@export var animation_manager: AnimationManager
@export var stamina_component: StaminaComponent
@export var dash_component: DashComponent
@export var player: CharacterBody2D
@export var wall_detector: RayCast2D
@export var ground_control_component: GroundControlComponent

func Enter() -> void:
	animation_manager.play("idle")
	stamina_component.refill_stamina()
	dash_component.refill_dash()

func Physics_Update(delta: float) -> void:
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return

	var input_dir = Input.get_axis("move_left", "move_right")
	
	# Appliquer le glissement naturel
	if input_dir == 0:
		player.velocity.x = move_toward(player.velocity.x, 0, ground_control_component.slide_friction * delta)
	else:
		Transitioned.emit(self, "run")
		return
	
	# Saut
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return

	# Dash au sol
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "grounddash")
		return

	# Wall grab
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		Transitioned.emit(self, "wallgrab")
		return

	player.move_and_slide()
