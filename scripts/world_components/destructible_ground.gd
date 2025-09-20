extends TileMapLayer

@export var structures_health: int = 1

@export_group("Limits")
@export var furthest_left_tile_unit: int = 0
@export var furthest_top_tile_unit: int = 0
@export var furthest_right_tile_unit: int = 0
@export var furthest_bottom_tile_unit: int = 0

var tile_size: Vector2i
var break_area: Area2D

func _ready() -> void:
	tile_size = tile_set.tile_size
	
	break_area = Area2D.new()
	break_area.collision_mask = 6
	break_area.body_entered.connect(_on_body_entered)

	var left = furthest_left_tile_unit * tile_size.x
	var top = furthest_top_tile_unit * tile_size.y
	var right = furthest_right_tile_unit * tile_size.x
	var bottom = furthest_bottom_tile_unit * tile_size.y

	var width = right + left + 2
	var height = bottom + top + 2

	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(abs(width), abs(height))
	collision_shape.shape = rect_shape

	collision_shape.position = Vector2((right - left) / 2.0 , (bottom - top) / 2.0)

	break_area.add_child(collision_shape)
	add_child(break_area)

func _on_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(2):
		structures_health -= 1
		if structures_health <= 0:
			_on_break()

func _on_break():
	queue_free()
