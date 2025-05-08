extends Node2D
class_name StaminaComponent

enum STAMINA_STATE {
	NORMAL,
	LOW,
	EMPTY
}

@export var MAX_STAMINA: float = 500.0
@export var CLIMB_STAMINA_MULTIPLIER: float = 1.5
@export var STAMINA_DRAIN_PER_SECOND: float = 100.0

@export var anim_tree: AnimationTree
var stamina_drain_value: float:
	get:
		return STAMINA_DRAIN_PER_SECOND * get_physics_process_delta_time()
var low_stamina_threshold: float:
	get:
		return MAX_STAMINA * 0.4

var stamina := MAX_STAMINA
var current_state: STAMINA_STATE = STAMINA_STATE.NORMAL

func drain_stamina(drain_value := stamina_drain_value) -> void:
	stamina -= drain_value
	stamina = max(stamina, 0)

	if stamina <= 0.0:
		_set_state(STAMINA_STATE.EMPTY)
	elif stamina <= low_stamina_threshold:
		_set_state(STAMINA_STATE.LOW)
	else:
		_set_state(STAMINA_STATE.NORMAL)

func refill_stamina() -> void:
	stamina = MAX_STAMINA
	_set_state(STAMINA_STATE.NORMAL)

func _set_state(new_state: STAMINA_STATE) -> void:
	if current_state == new_state:
		return

	current_state = new_state

	match new_state:
		STAMINA_STATE.EMPTY:
			anim_tree.get("parameters/playback").travel("EmptyStamina")
		STAMINA_STATE.LOW:
			anim_tree.get("parameters/playback").travel("LowStamina")
		STAMINA_STATE.NORMAL:
			anim_tree.get("parameters/playback").travel("RESET")
