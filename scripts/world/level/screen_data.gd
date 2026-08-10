extends Node2D
class_name ScreenData

func get_camera_rect() -> Rect2:
	var bounds := $CameraBounds as CollisionShape2D
	var shape := bounds.shape as RectangleShape2D
	var half := shape.size / 2.0
	return Rect2(bounds.position - half, shape.size)
