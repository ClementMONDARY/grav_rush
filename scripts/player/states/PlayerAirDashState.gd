extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var dash_component: DashComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	_start_airdash()

func Exit() -> void:
	# Nothing to clean up for now
	pass

func Physics_Update(delta: float) -> void:
	_update_dash_timer(delta)
	_check_for_dash_end()
	player.move_and_slide()

# --- Logic split below ---

func _start_airdash() -> void:
	dash_component.use_dash()
	animation_manager.play("air_dash")
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_DASH)
	dash_timer = dash_component.dash_duration
	dash_direction = 1 if !animation_manager.sprite.flip_h else -1
	player.velocity.x = dash_direction * dash_component.dash_speed
	player.velocity.y = 0  # Cancel vertical momentum

func _update_dash_timer(delta: float) -> void:
	dash_timer -= delta

func _check_for_dash_end() -> void:
	if dash_timer <= 0:
		Transitioned.emit(self, "fall")
		return
