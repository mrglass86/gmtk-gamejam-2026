extends Control
class_name DinnerInteractHUD

## Universal nearby-interaction affordance. Doors expose hold progress through
## their public openness value; instant switches intentionally never draw it.

@export var player_path: NodePath = NodePath("../../Player")
@export var prompt_offset: Vector2 = Vector2(0.0, -122.0)
@export var prompt_radius: float = 27.0

var _player: DinnerPlayer
var _nearest: Node3D
var _show_progress: bool = false
var _progress: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_player = get_node_or_null(player_path) as DinnerPlayer
	set_process(true)


func _process(_delta: float) -> void:
	_nearest = _find_nearest_interactable()
	_show_progress = (
		_nearest is DinnerDoor
		and Input.is_action_pressed("interact")
	)
	_progress = (
		clampf((_nearest as DinnerDoor).openness, 0.0, 1.0)
		if _show_progress
		else 0.0
	)
	visible = _nearest != null and _player != null and not _player.input_locked
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var center: Vector2 = size * 0.5 + prompt_offset
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


func _find_nearest_interactable() -> Node3D:
	if _player == null:
		return null
	var best: Node3D
	var best_distance: float = INF
	for candidate: Node in get_tree().get_nodes_in_group("interactable"):
		if not candidate is Node3D:
			continue
		var interactable: Node3D = candidate as Node3D
		var radius: float = float(interactable.get("interaction_radius"))
		var distance: float = _player.global_position.distance_to(
			interactable.global_position
		)
		if distance <= radius and distance < best_distance:
			best = interactable
			best_distance = distance
	return best
