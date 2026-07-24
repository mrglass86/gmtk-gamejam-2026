extends Control
class_name DinnerInteractHUD

## Universal nearby-interaction affordance. Doors expose hold progress through
## their public openness value; instant switches intentionally never draw it.

@export var player_path: NodePath = NodePath("../../Player")
@export var prompt_offset: Vector2 = Vector2(0.0, -30.0)
@export var world_anchor_height: float = 1.1
@export var prompt_radius: float = 27.0

var _player: DinnerPlayer
var _nearest: Node3D
var _show_progress: bool = false
var _progress: float = 0.0
var _seconds_remaining: float = 0.0
var _prompt_center: Vector2
var _has_screen_anchor: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_player = get_node_or_null(player_path) as DinnerPlayer
	set_process(true)


func _process(_delta: float) -> void:
	_nearest = (
		_player.get_nearest_interactable()
		if _player != null
		else null
	)
	_show_progress = (
		_nearest is DinnerDoor
		and Input.is_action_pressed("interact")
	)
	_progress = (
		clampf((_nearest as DinnerDoor).openness, 0.0, 1.0)
		if _show_progress
		else 0.0
	)
	_seconds_remaining = (
		(_nearest as DinnerDoor).get_hold_seconds_remaining(
			Input.is_action_pressed("run")
		)
		if _show_progress
		else 0.0
	)
	_has_screen_anchor = _update_prompt_center()
	visible = (
		_nearest != null
		and _player != null
		and not _player.input_locked
		and _has_screen_anchor
	)
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var center: Vector2 = _prompt_center
	draw_circle(center, prompt_radius, Color(0.035, 0.045, 0.065, 0.88))
	draw_arc(
		center,
		prompt_radius,
		0.0,
		TAU,
		48,
		Color(0.72, 0.78, 0.88, 0.8),
		2.5,
		true
	)
	if _show_progress:
		draw_arc(
			center,
			prompt_radius + 7.0,
			-PI * 0.5,
			-PI * 0.5 + TAU * _progress,
			48,
			Color("#d889de"),
			5.0,
			true
		)
	var font: Font = ThemeDB.fallback_font
	var text_size: Vector2 = font.get_string_size("E", HORIZONTAL_ALIGNMENT_LEFT, -1, 25)
	draw_string(
		font,
		center - Vector2(text_size.x * 0.5, -text_size.y * 0.35),
		"E",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		25,
		Color("#f0f3f8")
	)
	if _show_progress:
		var seconds_text: String = "%.1fs" % _seconds_remaining
		var seconds_size: Vector2 = font.get_string_size(
			seconds_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			19
		)
		draw_string(
			font,
			center + Vector2(-seconds_size.x * 0.5, prompt_radius + 27.0),
			seconds_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			19,
			Color("#f0f3f8")
		)


func get_current_interactable() -> Node3D:
	return _nearest


func get_prompt_center() -> Vector2:
	return _prompt_center


func get_seconds_remaining() -> float:
	return _seconds_remaining


func _update_prompt_center() -> bool:
	if _nearest == null:
		return false
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return false
	var world_anchor: Vector3 = (
		_nearest.global_position + Vector3.UP * world_anchor_height
	)
	if camera.is_position_behind(world_anchor):
		return false
	_prompt_center = camera.unproject_position(world_anchor) + prompt_offset
	return true
