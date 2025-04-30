extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var jump_component: JumpComponent
@export var stamina_component: StaminaComponent

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0

func Enter() -> void:
	animation_manager.play("wall_grab")
	player.velocity = Vector2.ZERO
	wall_direction = sign(player.get_wall_normal().x)

func Physics_Update(delta: float) -> void:
	if not player.is_on_wall():
		Transitioned.emit(self, "fall")
		return
	
	if player.is_on_floor():
		Transitioned.emit(self, "idle")
		return
	
	# Drain stamina
	stamina_component.drain_stamina()
	if stamina_component.stamina <= 0:
		player.velocity.y += gravity * 0.3 * delta
		player.velocity.x = -wall_direction * 50
	else:
		player.velocity = Vector2.ZERO
	
	# Wall jump
	if Input.is_action_just_pressed("jump"):
		jump_component.jumps_remaining += 1
		Transitioned.emit(self, "jump")
		return
	
	# Let go of wall
	if Input.get_axis("move_left", "move_right") == wall_direction:
		Transitioned.emit(self, "fall")
		return
	
	# Wall climb
	var vertical_input = Input.get_axis("move_up", "move_down")
	if vertical_input != 0 and stamina_component.stamina > 0:
		Transitioned.emit(self, "wallclimb")
		return
		
	player.move_and_slide()
