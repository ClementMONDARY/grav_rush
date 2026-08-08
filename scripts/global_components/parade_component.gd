class_name ParadeComponent extends Node2D

@export var parry_window_seconds: float = 0.25

@onready var parry_timer: Timer = $ParryTimer

var is_parrying: bool = false

func _ready() -> void:
	parry_timer.one_shot = true
	parry_timer.wait_time = parry_window_seconds

func start_parry() -> void:
	parry_timer.start()
	is_parrying = true

func stop_parying() -> void:
	parry_timer.stop()
	is_parrying = false

func can_parry_attack() -> bool:
	if parry_timer.time_left > 0.0 and is_parrying:
		return true
	return false
