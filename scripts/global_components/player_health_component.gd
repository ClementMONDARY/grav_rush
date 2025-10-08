extends HealthComponent
class_name PlayerHealthComponent

@export var player: CharacterBody2D

func spiked() -> void:
	var last_checkpoint: Checkpoint = PlayerManager.last_checkpoint
	var checkpoint_screen: ScreenData = last_checkpoint.from_screen
	var camera: PlayerCamera = player.get_node("PlayerCamera")
	var player_camera_shake_effect: CameraShakeScript = camera.get_node("CameraShakeEffect")
	damage(1)
	player_camera_shake_effect.shake(0.5, 7)
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_SWORD_ATTACK_HIT_ENNEMY)
	PlayerHud.get_node("AnimationPlayer").play("spiked")
	await get_tree().create_timer(0.1).timeout
	player.global_position = last_checkpoint.global_position
	camera.engage_transition_animation(checkpoint_screen, true)
