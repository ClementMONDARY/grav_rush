extends Node2D
class_name JumpComponent

@export var JUMP_FORCE: float = 400.0
@export var MAX_DB_JUMPS: int = 1
@export var JUMP_BUFFER_TIME: float = 0.2

@onready var JUMP_BUFFER_TIMEr: Timer = $JumpBufferTimer

var remaining_bonus_jumps: int = MAX_DB_JUMPS

func _ready() -> void:
	JUMP_BUFFER_TIMEr.one_shot = true
	JUMP_BUFFER_TIMEr.wait_time = JUMP_BUFFER_TIME

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		JUMP_BUFFER_TIMEr.start()

func refill_bonus_jumps(value: int = MAX_DB_JUMPS) -> void:
	remaining_bonus_jumps = mini(remaining_bonus_jumps + value, MAX_DB_JUMPS)

func use_bonus_jumps(value: int = 1) -> void:
	remaining_bonus_jumps = maxi(remaining_bonus_jumps - value, 0)

func has_buffered_jump() -> bool:
	return JUMP_BUFFER_TIMEr.time_left > 0.0 and Input.is_action_pressed("jump")

func consume_jump_buffer() -> void:
	JUMP_BUFFER_TIMEr.stop()

func canDoubleJump() -> bool:
	return remaining_bonus_jumps > 0
