extends Area2D
class_name Checkpoint

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var from_screen: ScreenData = get_parent().get_parent()

@export_group("Segment Collider Params")
@export var a: Vector2
@export var b: Vector2

func _ready() -> void:
	collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
	collision_shape_2d.shape.a = a
	collision_shape_2d.shape.b = b

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and PlayerManager.get_last_checkpoint() != self:
		PlayerManager.set_last_checkpoint(self)
