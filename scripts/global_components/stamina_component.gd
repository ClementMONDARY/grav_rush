extends Node2D
class_name StaminaComponent

@export var max_stamina: float = 500.0
@export var stamina_drain_per_second: float = 100.0  # Drain 100 stamina per second
var stamina_drain_value: float:
	get:
		return stamina_drain_per_second * get_physics_process_delta_time()

var stamina := max_stamina

func drain_stamina(drain_value := stamina_drain_value) -> void:
	stamina -= drain_value

func refill_stamina() -> void:
	stamina = max_stamina
