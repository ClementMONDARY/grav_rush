extends Node2D
class_name DashComponent

@export var DASH_SPEED: float = 600.0
@export var DASH_DURATION: float = 0.2
@export var MAX_DASHS: int = 1

var remaining_dashs := MAX_DASHS

func refill_dash(amount: int = MAX_DASHS)-> void:
	if remaining_dashs < MAX_DASHS:
		remaining_dashs = amount
		remaining_dashs = mini(remaining_dashs, MAX_DASHS)

func add_dash(amount: int = 1) -> void:
	remaining_dashs = mini(remaining_dashs + amount, MAX_DASHS)

func use_dash() -> void:
	remaining_dashs = maxi(remaining_dashs - 1, 0)
