extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var jump_force: float = 400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter() -> void:
	animation_manager.play("jump")
	player.velocity.y = -jump_force

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	if player.velocity.y != 0:
		Transitioned.emit(self, "fall")
