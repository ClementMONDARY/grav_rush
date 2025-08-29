extends Area2D

@export var item_id: String = "Diamond_1"
@export var max_follow_speed: float = 300.0
@export var acceleration_duration: float = 1.0
signal diamond_collected

var player: Node2D = null
var is_following: bool = false
var time_following: float = 0.0

func _ready() -> void:
	if DiamondManager.has_collected(item_id):
		queue_free()
	set_process(false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_following:
		await get_tree().create_timer(0.1).timeout
		player = body
		is_following = true
		set_monitoring(false)
		set_process(true)

func _process(delta: float) -> void:
	if is_following and player:
		time_following += delta

		# Calcul de la vitesse interpolée : de 0 à max
		var speed_factor: float = clamp(time_following / acceleration_duration, 0.0, 1.0)
		var current_speed: float = max_follow_speed * speed_factor

		var to_player = player.global_position - Vector2(0, 12) - global_position
		var distance = to_player.length()

		# Se déplacer progressivement vers le joueur
		if distance > 1.0:
			global_position += to_player.normalized() * current_speed * delta

		# Si proche du joueur, collecter
		if distance <= 5.0:
			DiamondManager.collect(item_id)
			AudioManager.create_2d_audio_at_location(get_global_position(), SoundEffect.SOUND_EFFECT_TYPE.ON_ITEM_PICKUP)
			diamond_collected.emit()
			queue_free()
