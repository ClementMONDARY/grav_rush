extends State

@export var animation_manager: AnimationManager
@export var player: CharacterBody2D
@export var move_speed: float = 150.0

func Enter() -> void:
	animation_manager.play("run")

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	if not player.is_on_floor():
		Transitioned.emit(self, "jump")
		return
		
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		Transitioned.emit(self, "idle")
		return
		
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return
		
	player.velocity.x = input_dir * move_speed
	
	# Flip sprite based on direction
	if input_dir > 0:
		animation_manager.flip_sprite(false)
	elif input_dir < 0:
		animation_manager.flip_sprite(true)
		
	player.move_and_slide()
