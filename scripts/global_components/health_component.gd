extends Node2D
class_name HealthComponent

@export var max_hp: int = 1

var current_hp: int = max_hp
var dmg_multiplier: int = 1

func damage(value: int) -> void:
	current_hp -= value * dmg_multiplier
	if current_hp <= 0:
		print("dead")
		current_hp = max_hp
