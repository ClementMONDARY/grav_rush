extends Area2D

@onready var health_component: PlayerHealthComponent = %HealthComponent

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("spikes"):
		health_component.spiked()
