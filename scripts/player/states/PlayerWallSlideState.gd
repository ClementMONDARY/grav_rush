extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var stamina_component: StaminaComponent
@export var jump_component: JumpComponent
@export var wall_detector: RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_direction: int = 0

func Enter() -> void:
	animation_manager.play("wall_slide")
	# Déterminer la direction du mur via le RayCast
	if wall_detector.is_colliding():
		var collision_pos = wall_detector.get_collision_point()
		wall_direction = sign(player.global_position.x - collision_pos.x)
	else:
		wall_direction = 0

func Physics_Update(delta: float) -> void:
	if not wall_detector.is_colliding():
		Transitioned.emit(self, "fall")
		return
	
	if player.velocity.y > 0:
		player.velocity.y = min(player.velocity.y + gravity * 0.2 * delta, 200)
		player.velocity.x = -wall_direction * 2
	else:
		player.velocity.y += gravity * delta
		player.velocity.x = -wall_direction * 2
	
	if Input.get_axis("move_left", "move_right") != -wall_direction:
		Transitioned.emit(self, "fall")
		return
	
	if Input.is_action_just_pressed("jump"):
		jump_component.jumps_remaining += 1
		player.velocity.x = wall_direction * jump_component.jump_force / 2.0
		animation_manager.flip_sprite(false if wall_direction == 1 else true)
		player.move_and_slide()
		Transitioned.emit(self, "jump")
		return
	
	# Wall grab
	if Input.is_action_pressed("wall_grab") and stamina_component.stamina > 0:
		Transitioned.emit(self, "wallgrab")
		return
	
	player.move_and_slide()
