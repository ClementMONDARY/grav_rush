extends Trail

@onready var body: Node2D = get_parent()
@onready var trail_timer: Timer = $TrailDurationTimer
@export var fade_duration: float = 0.2

var emit_duration_active := false

func _ready() -> void:
	clear_points()
	modulate.a = 0.0
	emit_points = false

func _get_position() -> Vector2:
	return body.global_position

func _process(delta: float) -> void:
	super._process(delta)

	if emit_duration_active:
		modulate.a = 1.0
	else:
		modulate.a = move_toward(modulate.a, 0.0, delta / fade_duration)

	emit_points = emit_duration_active or modulate.a > 0.0

	if modulate.a <= 0.0:
		clear_points()
		queue.clear()

func _on_player_dash(new_state_name: String) -> void:
	if new_state_name == "dash":
		emit_duration_active = true
		trail_timer.start()
		modulate.a = 1.0  # Assure l'apparition immédiate

func _on_TrailDurationTimer_timeout() -> void:
	emit_duration_active = false
