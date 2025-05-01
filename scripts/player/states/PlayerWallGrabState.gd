extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var jump_component: JumpComponent
@export var stamina_component: StaminaComponent
@export var wall_detector: RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0

func Enter() -> void:
	animation_manager.play("wall_grab")
	player.velocity = Vector2.ZERO
	
	# Détermination de la direction du mur selon la position du point de collision
	if wall_detector.is_colliding():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
	else:
		wall_direction = 0

func Physics_Update(_delta: float) -> void:
	if not wall_detector.is_colliding() or Input.is_action_just_released("wall_grab"):
		Transitioned.emit(self, "fall")
		return

	# Drain stamina
	stamina_component.drain_stamina()
	if stamina_component.stamina <= 0:
		Transitioned.emit(self, "wallslide")
		return
	else:
		player.velocity = Vector2.ZERO
	
	# Wall jump
	if Input.is_action_just_pressed("jump"):
		jump_component.jumps_remaining += 1
		if Input.get_axis("move_left", "move_right") == -wall_direction:
			player.velocity.x = wall_direction * jump_component.jump_force
			stamina_component.drain_stamina(200.0)
		else:
			player.velocity.x = wall_direction * jump_component.jump_force / 2.0
		animation_manager.flip_sprite(true, false)
		player.move_and_slide()
		Transitioned.emit(self, "jump")
		return
	
	# Let go of wall
	if Input.get_axis("move_left", "move_right") == wall_direction:
		animation_manager.play_sprite_animation("wall_slide")
		if Input.is_action_just_pressed("dash"):
			animation_manager.flip_sprite(true, false)
			Transitioned.emit(self, "airdash")
			return
	else:
		animation_manager.play_sprite_animation("wall_grab")
	
	# Wall climb
	var vertical_input = Input.get_axis("move_up", "move_down")
	if vertical_input != 0 and stamina_component.stamina > 0:
		Transitioned.emit(self, "wallclimb")
		return
		
	player.move_and_slide()
