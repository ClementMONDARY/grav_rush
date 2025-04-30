extends Node2D
class_name JumpComponent

@export var jump_force: float = 400.0
@export var max_jumps: int = 2

var jumps_remaining: int = max_jumps
