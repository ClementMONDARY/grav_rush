extends State

@export var animation_manager: AnimationManager
@export var stamina_component: StaminaComponent
@export var dash_component: DashComponent
@export var player: CharacterBody2D

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
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return
		
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		Transitioned.emit(self, "run")
		return
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		Transitioned.emit(self, "jump")
		return
	
	# Air dash transition
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "grounddash")
		return
	
	player.move_and_slide()
