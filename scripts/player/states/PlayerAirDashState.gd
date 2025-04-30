extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var speed_component: SpeedComponent
@export var dash_component: DashComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	animation_manager.play("air_dash")
	dash_timer = dash_component.dash_duration
	
	# Get dash direction from input
	dash_direction = Input.get_axis("move_left", "move_right")
	if dash_direction == 0:
		dash_direction = 1 if not animation_manager.animated_sprite.flip_h else -1
	
	# Set initial dash velocity
	player.velocity.x = dash_direction * dash_component.dash_speed
	player.velocity.y = 0  # Cancel vertical momentum
	
	# Flip sprite based on dash direction
	animation_manager.flip_sprite(dash_direction < 0)

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(delta: float) -> void:
	dash_timer -= delta
	
	if dash_timer <= 0:
		dash_component.can_dash = false
		Transitioned.emit(self, "fall")
		return
	
	player.move_and_slide()
