extends State

@onready var player: CharacterBody2D = $"../.."

@onready var wall_detector: RayCast2D = %WallDetector
@onready var anim_tree: AnimationTree = %AnimationTreeSprite
@onready var sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D
@onready var standing_hitbox: CollisionShape2D = $"../../StandingHitbox"
@onready var crouching_hitbox: CollisionShape2D = $"../../CrouchingHitbox"
@onready var hurtbox: Area2D = $"../../PlayerAnimatedSprite2D/Hitboxes/Hurtbox"

@onready var dash_component: DashComponent = %DashComponent
@onready var jump_component: JumpComponent = %JumpComponent
@onready var parade_component: ParadeComponent = %ParadeComponent
@onready var ground_control_component: GroundControlComponent = %GroundControlComponent

func _ready() -> void:
	hurtbox.area_entered.connect(_try_parry)

func Enter() -> void:
	anim_tree.get("parameters/playback").travel("Parade")
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_DRAW)
	parade_component.start_parry()
	for area in hurtbox.get_overlapping_areas():
		_try_parry(area)

func Exit() -> void:
	player.move_and_slide()
	parade_component.stop_parying()

func _input(event: InputEvent) -> void:
	if _handle_unparry(event) : return

func Physics_Update(delta: float) -> void:
	if _handle_airborne():
		return

	_apply_slide(delta)
	_handle_sprite_flip()

	if _handle_jump():
		return
	if _handle_dash():
		return
	if _handle_wall_grab():
		return
	if _handle_ground_attack():
		return

	player.move_and_slide()

# --- Logic split below ---

func _handle_unparry(event: InputEvent) -> bool:
	if event.is_action_released("parade"):
		Transitioned.emit(self, "idle")
		return true
	return false

func _handle_airborne() -> bool:
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return true
	return false

func _apply_slide(delta: float) -> void:
	# Décélération progressive vers 0
	player.velocity.x = move_toward(
		player.velocity.x,
		0,
		ground_control_component.SLIDE_FRICTION * delta
	)

func _handle_jump() -> bool:
	if jump_component.has_buffered_jump():
		Transitioned.emit(self, "jump")
		return true
	return false

func _handle_dash() -> bool:
	if Input.is_action_just_pressed("dash") and PlayerManager.can_dash and dash_component.remaining_dashs > 0:
		Transitioned.emit(self, "dash")
		return true
	return false

func _handle_wall_grab() -> bool:
	if wall_detector.is_colliding() and Input.is_action_pressed("wall_grab"):
		AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALL_GRAB)
		Transitioned.emit(self, "wallgrab")
		return true
	return false

func _handle_ground_attack() -> bool:
	if Input.is_action_just_pressed("attack") and PlayerManager.can_attack:
		Transitioned.emit(self, "attack")
		return true
	return false

func _handle_sprite_flip() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir > 0:
		sprite.scale.x = 1.0
	elif input_dir < 0:
		sprite.scale.x = -1.0

func _try_parry(area: Area2D) -> void:
	if not parade_component.is_parrying: return
	if not area.is_in_group("parable"): return
	var parry_contact_point = hurtbox.global_position.lerp(area.global_position, 0.5)
	var level = parade_component.get_parry_level(area)
	match level:
		ParadeComponent.PARRY_LEVEL.BLOCK:
			print("Block level : BLOCK")
			ANIM_block(parry_contact_point)
		ParadeComponent.PARRY_LEVEL.LIGHT:
			print("Block level : LIGHT")
			ANIM_light_parry(parry_contact_point)
		ParadeComponent.PARRY_LEVEL.MEDIUM:
			print("Block level : MEDIUM")
			ANIM_medium_parry(parry_contact_point)
		ParadeComponent.PARRY_LEVEL.HEAVY:
			print("Block level : HEAVY")
			ANIM_heavy_parry(parry_contact_point)

func ANIM_block(parry_contact_point: Vector2) -> void:
	AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_BLOCK)
	Fx.spawn("hit_flash", parry_contact_point, {"size": 0.5, "color_main": Color("#555555"), "color_accent": Color("#222222")})

func ANIM_light_parry(parry_contact_point: Vector2) -> void:
	AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_LIGHT_PARRY)
	Fx.spawn("impact_spark", parry_contact_point, {"size": 0.5})
	Fx.shake(1, 0.1)

func ANIM_medium_parry(parry_contact_point: Vector2) -> void:
	AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_MEDIUM_PARRY)
	Fx.spawn("impact_spark", parry_contact_point, {"size": 0.7})
	Fx.shake(5, 0.2)

func ANIM_heavy_parry(parry_contact_point: Vector2) -> void:
	AudioManager.create_2d_audio_at_location_with_culling(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_HEAVY_PARRY)
	Fx.spawn("impact_spark", parry_contact_point, {"size": 0.9})
	Fx.spawn("hit_burst", parry_contact_point, {"size": 0.2})
	Fx.shake(6, 0.3)
	Fx.hitstop(0.15)
