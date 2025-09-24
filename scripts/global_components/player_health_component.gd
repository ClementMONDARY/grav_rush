extends HealthComponent
class_name PlayerHealthComponent

@export var player: CharacterBody2D

func spiked() -> void:
	var last_checkpoint: Checkpoint = PlayerManager.last_checkpoint
	var checkpoint_screen: ScreenData = last_checkpoint.from_screen
	var camera: PlayerCamera = player.get_node("PlayerCamera")
	damage(1)
	player.global_position = last_checkpoint.global_position
	camera.engage_transition_animation(checkpoint_screen, true)
