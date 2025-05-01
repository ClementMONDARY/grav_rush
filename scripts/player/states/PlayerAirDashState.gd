extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var dash_component: DashComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	dash_component.use_dash()
	animation_manager.play("air_dash")
	dash_timer = dash_component.dash_duration
	
	# Get dash direction from input
	dash_direction = 1 if !animation_manager.animated_sprite.flip_h else -1
	
	# Set initial dash velocity
	player.velocity.x = dash_direction * dash_component.dash_speed
	player.velocity.y = 0  # Cancel vertical momentum

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(delta: float) -> void:
	dash_timer -= delta
	
	if dash_timer <= 0:
		Transitioned.emit(self, "fall")
		return
	
	player.move_and_slide()
