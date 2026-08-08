class_name ParadeComponent extends Node2D

enum PARRY_LEVEL {
	BLOCK,
	LIGHT,
	MEDIUM,
	HEAVY
}

@export var parry_window_seconds: float = 0.25
@export var rest_time_before_next_parry_seconds: float = 0.1

@onready var parry_timer: Timer = $ParryTimer
@onready var rest_timer: Timer = $RestTimer

var is_parrying: bool = false

func _ready() -> void:
	parry_timer.one_shot = true
	rest_timer.one_shot = true
	parry_timer.wait_time = parry_window_seconds
	rest_timer.wait_time = rest_time_before_next_parry_seconds

func start_parry() -> void:
	parry_timer.start()
	is_parrying = true

func _process(delta: float) -> void:
	if is_parrying:
		print(str(rest_timer.time_left))

func stop_parying() -> void:
	parry_timer.stop()
	rest_timer.stop()
	is_parrying = false

func can_parry_attack() -> bool:
	if parry_timer.time_left > 0.0 and rest_timer.is_stopped() and is_parrying:
		return true
	return false

func get_parry_level(attack_source: Area2D) -> PARRY_LEVEL:
	if not can_parry_attack(): return PARRY_LEVEL.BLOCK
	var attack_source_component: AttackSourceComponent = attack_source.get_node_or_null("AttackSourceComponent")
	if attack_source_component == null: return PARRY_LEVEL.BLOCK
	rest_timer.start()
	return attack_source_component.parry_level
