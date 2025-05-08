extends Node2D
class_name GroundControlComponent

@export var max_speed: float = 250.0  # Anciennement x_speed
@export var acceleration: float = 2000.0  # Force d'accélération
@export_range(0.0, 1.0) var acceleration_curve: float = 0.2  # Pour ajuster la courbe d'accélération
@export var SLIDE_FRICTION: float = 3000.0  # Plus grand = arrête plus vite
