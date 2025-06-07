extends Node

var collected_items: Dictionary = {}  # ex: { "Strawberry_1": true }

func has_collected(item_id: String) -> bool:
	return collected_items.has(item_id)

func collect(item_id: String) -> void:
	collected_items[item_id] = true

func get_total_collected() -> int:
	return collected_items.size()
