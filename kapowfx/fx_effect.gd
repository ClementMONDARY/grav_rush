class_name FxEffect
extends Node2D
## Base class for all KapowFX effects.
##
## Every effect is a self-contained Node2D you can drop anywhere (or spawn via
## the [code]Fx[/code] autoload). Tweak the exported properties in the
## Inspector — colors, size and speed apply without touching any shader code.

signal finished

## Play automatically the moment the effect enters the tree.
@export var auto_play: bool = true
## Free the node automatically once the effect has fully finished.
@export var auto_free: bool = true
## Looping effects (auras, rain, trails) never emit [signal finished] on their
## own — call [method stop] when you're done with them.
@export var loop: bool = false
## Overall size multiplier.
@export_range(0.1, 8.0, 0.05) var size: float = 1.0
## Playback speed multiplier (2.0 = twice as fast).
@export_range(0.1, 4.0, 0.05) var speed: float = 1.0
## Primary color of the effect.
@export var color_main: Color = Color("#ffd23f")
## Secondary / accent color of the effect.
@export var color_accent: Color = Color("#ff6b35")

var _playing := false
var _build_done := false

func _ready() -> void:
	if not _build_done:
		_build()
		_build_done = true
	if auto_play:
		play()

## (Re)play the effect from the start.
func play() -> void:
	if not _build_done:
		_build()
		_build_done = true
	if _playing:
		_reset()
	_playing = true
	scale = Vector2.ONE * size
	_apply_colors()
	_play()
	if not loop:
		var total := _duration() / maxf(speed, 0.01)
		get_tree().create_timer(total).timeout.connect(_on_done, CONNECT_ONE_SHOT)

## Stop a looping effect gracefully (fades emitters, then finishes).
func stop(fade_time: float = 0.4) -> void:
	if not _playing:
		return
	_stop()
	get_tree().create_timer(fade_time).timeout.connect(_on_done, CONNECT_ONE_SHOT)

## Override for looping effects: stop emitters so particles die out.
func _stop() -> void:
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = false

func _on_done() -> void:
	_playing = false
	finished.emit()
	if auto_free:
		queue_free()

# --- Override points -------------------------------------------------------

## Build child nodes (called once). Override in each effect.
func _build() -> void:
	pass

## Start emitters / tweens. Override in each effect.
func _play() -> void:
	pass

## Re-arm state before replaying. Optional override.
func _reset() -> void:
	pass

## Total effect duration in seconds (before speed scaling). Override.
func _duration() -> float:
	return 1.0

## Push exported colors into child nodes. Optional override.
func _apply_colors() -> void:
	pass

# --- Shared helpers --------------------------------------------------------

## A soft radial dot texture (white core fading out) — the workhorse particle texture.
static func make_dot_texture(psize: int = 64) -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = psize
	t.height = psize
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	return t

## An elongated streak texture (for velocity-aligned sparks).
static func make_streak_texture(w: int = 16, h: int = 64) -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = w
	t.height = h
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	return t

## A plain white quad texture (canvas for SDF shaders).
static func make_white_texture(psize: int = 64) -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color.WHITE, Color.WHITE])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = psize
	t.height = psize
	return t

## Build a GradientTexture1D color ramp from a list of colors (evenly spaced).
static func make_ramp(colors: Array[Color]) -> GradientTexture1D:
	var g := Gradient.new()
	var cols := PackedColorArray()
	var offs := PackedFloat32Array()
	for i in colors.size():
		cols.append(colors[i])
		offs.append(float(i) / maxf(colors.size() - 1, 1))
	g.colors = cols
	g.offsets = offs
	var t := GradientTexture1D.new()
	t.gradient = g
	return t

## Build a CurveTexture from control points [[x, y], ...].
static func make_curve(points: Array) -> CurveTexture:
	var c := Curve.new()
	for p in points:
		c.add_point(Vector2(p[0], p[1]))
	var t := CurveTexture.new()
	t.curve = c
	return t

## Additive canvas material (glow look).
static func make_add_material() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m

## A small star-flash sprite driven by the spark_star shader.
## Returns the Sprite2D; its material is a ShaderMaterial you can animate
## ("shader_parameter/progress", "shader_parameter/tint").
static func make_star_sprite(points: int = 4, sharpness: float = 22.0) -> Sprite2D:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://kapowfx/common/shaders/spark_star.gdshader")
	mat.set_shader_parameter("points", points)
	mat.set_shader_parameter("sharpness", sharpness)
	var s := Sprite2D.new()
	s.texture = make_white_texture(64)
	s.material = mat
	return s
