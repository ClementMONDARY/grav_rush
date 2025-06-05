extends Node2D
class_name JumpComponent

@export var JUMP_FORCE: float = 405.0
@export var MAX_DB_JUMPS: int = 1
@export var JUMP_BUFFER_TIME: float = 0.1
@export var COYOTE_TIME_TIME: float = 0.1

@onready var wall_detector: RayCast2D = %WallDetector
@onready var PLAYER: CharacterBody2D = $"../.."
@onready var JUMP_BUFFER_TIMER: Timer = $JumpBufferTimer
@onready var COYOTE_TIME_TIMER: Timer = $CoyoteTimeTimer

var remaining_bonus_jumps: int = MAX_DB_JUMPS

func _ready() -> void:
	JUMP_BUFFER_TIMER.one_shot = true
	JUMP_BUFFER_TIMER.wait_time = JUMP_BUFFER_TIME
	
	COYOTE_TIME_TIMER.one_shot = true
	COYOTE_TIME_TIMER.wait_time = COYOTE_TIME_TIME

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		JUMP_BUFFER_TIMER.start()
	
	if PLAYER.is_on_floor() or wall_detector.is_colliding():
		COYOTE_TIME_TIMER.start()

func refill_bonus_jump(value: int = MAX_DB_JUMPS) -> void:
	remaining_bonus_jumps = mini(remaining_bonus_jumps + value, MAX_DB_JUMPS)

func use_bonus_jump(value: int = 1) -> void:
	remaining_bonus_jumps = maxi(remaining_bonus_jumps - value, 0)

func consume_coyote_time() -> void:
	COYOTE_TIME_TIMER.stop()

func consume_jump_buffer() -> void:
	JUMP_BUFFER_TIMER.stop()

func has_coyote_time() -> bool:
	return COYOTE_TIME_TIMER.time_left > 0.0

func has_buffered_jump() -> bool:
	return JUMP_BUFFER_TIMER.time_left > 0.0 and Input.is_action_pressed("jump")

func can_double_jump() -> bool:
	return remaining_bonus_jumps > 0
