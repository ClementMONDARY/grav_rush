extends Node2D
class_name StaminaComponent

@export var anim_tree: AnimationTree
@export var max_stamina: float = 500.0
@export var stamina_drain_per_second: float = 100.0  # Drain 100 stamina per second
var stamina_drain_value: float:
	get:
		return stamina_drain_per_second * get_physics_process_delta_time()
var low_stamina_threshold: float:
	get:
		return max_stamina * 0.4

var stamina := max_stamina
var has_passed_threshold := false

func drain_stamina(drain_value := stamina_drain_value) -> void:
	stamina -= drain_value
	if stamina <= low_stamina_threshold && !has_passed_threshold:
		anim_tree.get("parameters/playback").travel("LowStamina")
		has_passed_threshold = true

func refill_stamina() -> void:
	if stamina <= low_stamina_threshold && has_passed_threshold:
		anim_tree.get("parameters/playback").travel("RESET")
		has_passed_threshold = false
	stamina = max_stamina
