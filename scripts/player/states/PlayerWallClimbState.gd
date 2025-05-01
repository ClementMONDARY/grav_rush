extends State

@export var animation_manager: AnimationManager
@export var jump_component: JumpComponent
@export var player: CharacterBody2D
@export var stamina_component: StaminaComponent
@export var climb_speed: float = 100.0
@export var wall_detector: RayCast2D

var wall_direction: int = 0
const CLIMB_STAMINA_MULTIPLIER := 1.5
var current_animation_state := ""

func Enter() -> void:
	player.velocity = Vector2.ZERO
	current_animation_state = ""

	# Déterminer la direction du mur via le RayCast
	if wall_detector.is_colliding():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
	else:
		wall_direction = 0

func Physics_Update(_delta: float) -> void:
	# Sortir si le mur n'est plus détecté ou si on relâche l'action
	if not wall_detector.is_colliding() or Input.is_action_just_released("wall_grab"):
		Transitioned.emit(self, "fall")
		return

	var input_dir = Input.get_axis("move_up", "move_down")
	player.velocity.y = input_dir * climb_speed
	player.velocity.x = -wall_direction * 2

	# Gérer la stamina
	if input_dir < 0:  # Monter
		stamina_component.drain_stamina(stamina_component.stamina_drain_value * CLIMB_STAMINA_MULTIPLIER)
	elif input_dir > 0:  # Descendre
		stamina_component.drain_stamina(0.0)
	else:
		Transitioned.emit(self, "wallgrab")
		return

	if stamina_component.stamina <= 0:
		Transitioned.emit(self, "wallgrab")
		return

	# Animation selon direction
	var new_animation_state = ""
	if input_dir < 0:
		new_animation_state = "wall_climb"
	elif input_dir > 0:
		new_animation_state = "wall_climb_down"

	if new_animation_state != current_animation_state:
		current_animation_state = new_animation_state
		if input_dir < 0:
			animation_manager.play("wall_climb")
		elif input_dir > 0:
			animation_manager.play("wall_climb", true)

	# Wall jump
	if Input.is_action_just_pressed("jump"):
		jump_component.jumps_remaining += 1
		player.velocity.x = wall_direction * jump_component.jump_force / 2.0
		animation_manager.flip_sprite(false if wall_direction == 1 else true)
		player.move_and_slide()
		Transitioned.emit(self, "jump")
		return
	
	player.move_and_slide()
