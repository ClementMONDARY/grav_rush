extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var stamina_component: StaminaComponent
@export var dash_component: DashComponent
@export var wall_detector: RayCast2D
@export var ground_control_component: GroundControlComponent

func Enter() -> void:
	animation_manager.play("run")
	stamina_component.refill_stamina()
	dash_component.refill_dash()

func Physics_Update(delta: float) -> void:
	if not player.is_on_floor():
		Transitioned.emit(self, "jump")
		return

	var input_dir = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return

	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "grounddash")
		return

	if input_dir == 0:
		# Appliquer un glissement naturel vers l'arrêt
		player.velocity.x = move_toward(player.velocity.x, 0, ground_control_component.slide_friction * 3.0 * delta)
	else:
		# Contrôle actif
		player.velocity.x = input_dir * speed_component.speed
		if input_dir > 0:
			animation_manager.flip_sprite(false)
		elif input_dir < 0:
			animation_manager.flip_sprite(true)

	player.move_and_slide()

	# Wall grab
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		Transitioned.emit(self, "wallgrab")
		return

	# Transition vers idle si la vitesse devient très faible
	if abs(player.velocity.x) < 5.0 and input_dir == 0:
		Transitioned.emit(self, "idle")
