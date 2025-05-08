extends Line2D
class_name Trail

var queue: Array = []
@export var MAX_LENGTH: int = 10
@onready var TRAIL_DURATION_TIMER: Timer = $TrailDurationTimer

var emit_points: bool = true

func _process(_delta: float) -> void:
	if emit_points:
		var pos: Vector2 = _get_position()
		queue.push_front(pos)

	if queue.size() > MAX_LENGTH:
		queue.pop_back()

	clear_points()
	for point in queue:
		add_point(point)

func _get_position() -> Vector2:
	return get_global_mouse_position()
