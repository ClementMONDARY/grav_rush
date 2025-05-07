extends Node2D
class_name JumpComponent

@export var jump_force: float = 400.0
@export var max_jumps: int = 2
@export var jump_buffer_time: float = 0.2
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

var jumps_remaining: int = max_jumps

func _ready() -> void:
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.wait_time = jump_buffer_time

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

func has_buffered_jump() -> bool:
	return jump_buffer_timer.time_left > 0.0

func consume_jump_buffer() -> void:
	jump_buffer_timer.stop()
