extends State

@export var animation_manager: AnimationManager
@export var stamina_component: StaminaComponent
@export var dash_component: DashComponent
@export var player: CharacterBody2D
@export var wall_detector: RayCast2D

func Enter() -> void:
	animation_manager.play("idle")
	player.velocity = Vector2(0, 0)
	stamina_component.refill_stamina()
	dash_component.refill_dash()

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	# Fall transition
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return
		
	# Run transition
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		Transitioned.emit(self, "run")
		return
		
	# Jump transition
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		Transitioned.emit(self, "jump")
		return
	
	# Air dash transition
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "grounddash")
		return
	
	# Check for wall grab using raycasts
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		Transitioned.emit(self, "wallgrab")
		return
