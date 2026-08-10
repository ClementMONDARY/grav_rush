extends TileMapLayer
# To edit "BreakBound" shape, enable "Editable Chidlren" parameter and make shape as unique

const DEBRIS_PARTICULES_SCENE = preload("uid://wq4xrfptlgjy")

@export var structures_health: int = 1

var break_area: Area2D
var collision_shape: CollisionShape2D

func _ready() -> void:
	var rect := get_break_rect()

	break_area = Area2D.new()
	break_area.collision_mask = 6
	break_area.body_entered.connect(_on_body_entered)

	collision_shape = CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = rect.size
	collision_shape.shape = rect_shape
	collision_shape.position = rect.get_center()

	break_area.add_child(collision_shape)
	add_child(break_area)

func get_break_rect() -> Rect2:
	var bounds := $BreakBounds as CollisionShape2D
	var shape := bounds.shape as RectangleShape2D
	var half := shape.size / 2.0
	return Rect2(bounds.position - half, shape.size)

func _get_configuration_warnings() -> PackedStringArray:
	var bounds := get_node_or_null("BreakBounds")
	if bounds == null or not (bounds is CollisionShape2D) or not (bounds.shape is RectangleShape2D):
		return ["Un enfant CollisionShape2D nommé \"BreakBounds\" avec une RectangleShape2D est requis."]
	return []

func _on_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(2):
		AudioManager.create_2d_audio_at_location(collision_shape.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_WALL_CRACK_STONE)
		structures_health -= 1
		if structures_health <= 0:
			_on_break()

func _on_break():
	AudioManager.create_2d_audio_at_location(collision_shape.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_WALL_BREAK_STONE)

	var rect := get_break_rect()
	var debris = DEBRIS_PARTICULES_SCENE.instantiate()
	debris.position = to_global(rect.get_center())

	# Ajuste la box d'émission et le nombre de particules
	if debris.process_material is ParticleProcessMaterial:
		var mat = debris.process_material
		mat.emission_box_extents = Vector3(rect.size.x / 2.0, rect.size.y / 2.0, 0)

	# Nombre de tiles recouvertes
	var tile_count = (rect.size.x / tile_set.tile_size.x) * (rect.size.y / tile_set.tile_size.y) * 20
	debris.amount = int(abs(tile_count))
	debris.emitting = true
	get_tree().current_scene.add_child(debris)

	queue_free()
