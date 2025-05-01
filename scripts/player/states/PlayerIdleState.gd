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
	if _handle_airborne():
		return

	_apply_slide(delta)

	if _handle_run():
		return
	if _handle_jump():
		return
	if _handle_dash():
		return
	if _handle_wall_grab():
		return

	player.move_and_slide()

# --- Logic split below ---

func _handle_airborne() -> bool:
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return true
	return false

func _apply_slide(delta: float) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		player.velocity.x = move_toward(player.velocity.x, 0, ground_control_component.slide_friction * delta)

func _handle_run() -> bool:
	if Input.get_axis("move_left", "move_right") != 0:
		Transitioned.emit(self, "run")
		return true
	return false

func _handle_jump() -> bool:
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash() -> bool:
	if Input.is_action_just_pressed("dash") and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "grounddash")
		return true
	return false

func _handle_wall_grab() -> bool:
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		Transitioned.emit(self, "wallgrab")
		return true
	return false
