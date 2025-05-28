extends Camera2D

@export var initial_screen: NodePath

@onready var level_screens: Array = get_tree().get_nodes_in_group("screen").map(func(n): return n as ScreenData)
@onready var actual_screen: ScreenData = get_node_or_null(initial_screen)
@onready var actual_screen_name: String = actual_screen.name

const SCREEN_WIDTH := 576.0
const SCREEN_HEIGHT := 324.0
const TRANSITION_DURATION := 0.6

func _ready() -> void:
	print(level_screens)
	if actual_screen:
		update_camera_limits_from_screen(actual_screen)

func update_camera_limits_from_screen(screen: ScreenData) -> void:
	var top_left := screen.global_position + Vector2(screen.local_camera_limit_left, screen.local_camera_limit_top)
	var bottom_right := screen.global_position + Vector2(screen.local_camera_limit_right, screen.local_camera_limit_bottom)
	
	set_camera_limits(Vector4(
		top_left.x,
		top_left.y,
		bottom_right.x,
		bottom_right.y
	))

func set_camera_limits(limits: Vector4) -> void:
	limit_left = limits.x
	limit_top = limits.y
	limit_right = limits.z
	limit_bottom = limits.w

func set_borders_enabled(enabled_value: bool) -> void:
	for border in $CameraBorders.get_children():
		if border is Area2D:
			border.set_deferred("monitoring", enabled_value)

func _process(_delta: float) -> void:
	$CameraBorders.global_position = get_screen_center_position()

# ---- BORDERS LOGIC ----
func _on_right_border_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	print("right border entered!")
	transition_to_screen(Vector2(1, 0))

func _on_left_border_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	print("left border entered!")
	transition_to_screen(Vector2(-1, 0))

func _on_top_border_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	print("top border entered!")
	transition_to_screen(Vector2(0, -1))

func _on_bottom_border_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	print("bottom border entered!")
	transition_to_screen(Vector2(0, 1))

# ---- MAIN TRANSITION LOGIC ----
func transition_to_screen(direction: Vector2) -> void:
	var current_coords := actual_screen_name.replace("Screen_", "").split("_")
	var next_x := int(current_coords[0]) + int(direction.x)
	var next_y := int(current_coords[1]) + int(direction.y)
	var target_name := "Screen_%d_%d" % [next_x, next_y]
	
	var target_screen: ScreenData = level_screens.filter(func(screen: ScreenData) -> bool:
		return screen.name == target_name
	).front()
	
	if target_screen == null:
		push_warning("Target screen %s not found!" % target_name)
		return
	
	set_borders_enabled(false)
	update_camera_limits_from_screen(target_screen)
	await get_tree().create_timer(TRANSITION_DURATION).timeout
	_on_transition_complete(target_screen)


func _on_transition_complete(new_screen: ScreenData) -> void:
	actual_screen = new_screen
	actual_screen_name = new_screen.name
	set_borders_enabled(true)
