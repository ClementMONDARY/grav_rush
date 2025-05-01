extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var dash_component: DashComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	_start_dash()

func Exit() -> void:
	# Nothing to clean up for now
	pass

func Physics_Update(delta: float) -> void:
	_update_dash_timer(delta)
	_check_for_jump()
	_check_for_dash_end()
	player.move_and_slide()

# --- Logic split below ---

func _start_dash() -> void:
	dash_component.use_dash()
	animation_manager.play("ground_dash")
	dash_timer = dash_component.dash_duration
	dash_direction = 1 if !animation_manager.animated_sprite.flip_h else -1
	player.velocity.x = dash_direction * dash_component.dash_speed

func _update_dash_timer(delta: float) -> void:
	dash_timer -= delta

func _check_for_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		player.velocity.x *= 1.5
		Transitioned.emit(self, "jump")
		return

func _check_for_dash_end() -> void:
	if dash_timer <= 0:
		Transitioned.emit(self, "run")
		return
