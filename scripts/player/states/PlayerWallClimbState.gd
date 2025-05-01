extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var stamina_component: StaminaComponent
@export var climb_speed: float = 100.0

var wall_direction: int = 0
const CLIMB_STAMINA_MULTIPLIER := 1.5
var current_animation_state := ""

func Enter() -> void:
	player.velocity = Vector2.ZERO
	wall_direction = sign(player.get_wall_normal().x)
	current_animation_state = ""  # Reset animation state

func Physics_Update(_delta: float) -> void:
	if not player.is_on_wall() or Input.is_action_just_released("wall_grab"):
		Transitioned.emit(self, "fall")
		return
	
	var input_dir = Input.get_axis("move_up", "move_down")
	player.velocity.y = input_dir * climb_speed
	player.velocity.x = -wall_direction * 2
	
	# Handle stamina drain
	if input_dir < 0:  # Moving up
		stamina_component.drain_stamina(stamina_component.stamina_drain_value * CLIMB_STAMINA_MULTIPLIER)
	elif input_dir > 0:  # Moving down
		stamina_component.drain_stamina(0.0)
	else:
		Transitioned.emit(self, "wallgrab")
	
	# Check if out of stamina
	if stamina_component.stamina <= 0:
		Transitioned.emit(self, "wallgrab")
		return
	
	# Play appropriate animation only when state changes
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
		Transitioned.emit(self, "jump")
		return
	
	player.move_and_slide()
