extends TileMapLayer

const DEBRIS_PARTICULES_SCENE = preload("uid://wq4xrfptlgjy")

@export var structures_health: int = 1

@export_group("Limits")
@export var furthest_left_tile_unit: int = 0
@export var furthest_top_tile_unit: int = 0
@export var furthest_right_tile_unit: int = 0
@export var furthest_bottom_tile_unit: int = 0

var tile_size: Vector2i
var break_area: Area2D
var collision_shape: CollisionShape2D

var left
var top
var right
var bottom
var width
var height

func _ready() -> void:
	tile_size = tile_set.tile_size
	
	break_area = Area2D.new()
	break_area.collision_mask = 6
	break_area.body_entered.connect(_on_body_entered)

	left = furthest_left_tile_unit * tile_size.x
	top = furthest_top_tile_unit * tile_size.y
	right = furthest_right_tile_unit * tile_size.x
	bottom = furthest_bottom_tile_unit * tile_size.y

	width = right + left
	height = bottom + top

	collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(abs(width + 2), abs(height + 2))
	collision_shape.shape = rect_shape

	collision_shape.position = Vector2((right - left) / 2.0 , (bottom - top) / 2.0)

	break_area.add_child(collision_shape)
	add_child(break_area)

func _on_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(2):
		AudioManager.create_2d_audio_at_location(collision_shape.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_WALL_CRACK_STONE)
		structures_health -= 1
		if structures_health <= 0:
			_on_break()

func _on_break():
	AudioManager.create_2d_audio_at_location(collision_shape.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_WALL_BREAK_STONE)

	var debris = DEBRIS_PARTICULES_SCENE.instantiate()
	debris.position = to_global(Vector2((right - left) / 2.0 , (bottom - top) / 2.0))

	# Ajuste la box d'émission et le nombre de particules
	if debris.process_material is ParticleProcessMaterial:
		var mat = debris.process_material
		mat.emission_box_extents = Vector3(width / 2.0, height / 2.0, 0)

	# Nombre de tiles recouvertes
	var tile_count = abs(abs(furthest_right_tile_unit) - abs(furthest_left_tile_unit)) * abs(abs(furthest_bottom_tile_unit) - abs(furthest_top_tile_unit)) * 30
	debris.amount = abs(tile_count)
	debris.emitting = true
	print(debris.position)
	get_tree().current_scene.add_child(debris)

	queue_free()
