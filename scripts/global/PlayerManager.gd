extends Node

var last_checkpoint: Checkpoint:
	get = get_last_checkpoint, set = set_last_checkpoint

var can_attack: bool = true
var can_dash: bool = true

func get_last_checkpoint() -> Checkpoint:
	return last_checkpoint

func set_last_checkpoint(value: Checkpoint) -> void:
	last_checkpoint = value
	print("New checkpoint from : ", last_checkpoint.from_screen)
