extends State

@export var sprite: AnimatedSprite2D
@export var anim_tree: AnimationTree
@export var player: CharacterBody2D
@export var dash_component: DashComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	_start_dash()

func Exit() -> void:
	pass

func Physics_Update(delta: float) -> void:
	_update_dash_timer(delta)
	_check_for_jump()
	_check_for_dash_end()
	player.move_and_slide()

# --- Logic split below ---

func _start_dash() -> void:
	dash_component.use_dash()
	if player.is_on_floor():
		anim_tree.set("parameters/Dash/FloorContext/blend_position", -1.0)
	else:
		anim_tree.set("parameters/Dash/FloorContext/blend_position", 1.0)
	anim_tree.get("parameters/playback").travel("Dash")
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_DASH)
	dash_timer = dash_component.dash_duration
	dash_direction = 1 if !sprite.flip_h else -1
	player.velocity.x = dash_direction * dash_component.dash_speed
	player.velocity.y = 0

func _update_dash_timer(delta: float) -> void:
	dash_timer -= delta

func _check_for_jump() -> void:
	if Input.is_action_just_pressed("jump") && player.is_on_floor():
		player.velocity.x *= 1.5
		Transitioned.emit(self, "jump")
		return

func _check_for_dash_end() -> void:
	if dash_timer <= 0:
		if player.is_on_floor():
			Transitioned.emit(self, "run")
		else:
			Transitioned.emit(self, "fall")
		return
