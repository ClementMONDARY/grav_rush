extends Node2D
class_name DashComponent

@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var max_dash: int = 1

var remaining_dashs := max_dash

func refill_dash(amount: int = max_dash)-> void:
	if remaining_dashs < max_dash:
		remaining_dashs = amount
		remaining_dashs = mini(remaining_dashs, max_dash)

func add_dash(amount: int = 1) -> void:
	remaining_dashs = mini(remaining_dashs + amount, max_dash)

func use_dash() -> void:
	remaining_dashs = maxi(remaining_dashs - 1, 0)
