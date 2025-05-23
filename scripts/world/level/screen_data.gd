extends Node2D
class_name ScreenData

@export var camera_zoom: float = 2.0

@export_group("Limits")
@export var local_camera_limit_left: float = 0.0
@export var local_camera_limit_top: float = 0.0
@export var local_camera_limit_right: float = 0.0
@export var local_camera_limit_bottom: float = 0.0

@export_group("Adjascent Screens")
@export var adjascent_left_screen: NodePath
@export var adjascent_top_screen: NodePath
@export var adjascent_right_screen: NodePath
@export var adjascent_bottom_screen: NodePath

@onready var left_screen: ScreenData = get_node_or_null(adjascent_left_screen)
@onready var top_screen: ScreenData = get_node_or_null(adjascent_top_screen)
@onready var right_screen: ScreenData = get_node_or_null(adjascent_right_screen)
@onready var bottom_screen: ScreenData = get_node_or_null(adjascent_bottom_screen)

func _on_left_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
	return

func _on_top_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
		get_world_2d()
	return

func _on_right_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
	return

func _on_bottom_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
	return
