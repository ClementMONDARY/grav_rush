extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var dash_component: DashComponent

var dash_timer: float = 0.0
var dash_direction: float = 0.0

func Enter() -> void:
	dash_component.use_dash()
	animation_manager.play("ground_dash")
	dash_timer = dash_component.dash_duration
	
	# Get dash direction from input
	dash_direction = 1 if !animation_manager.animated_sprite.flip_h else -1
	
	# Set initial dash velocity
	player.velocity.x = dash_direction * dash_component.dash_speed

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(delta: float) -> void:
	dash_timer -= delta
	
	if dash_timer <= 0:
		if dash_direction != 0:
			Transitioned.emit(self, "run")
		else:
			Transitioned.emit(self, "idle")
		return
	
	player.move_and_slide()
