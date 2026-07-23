extends Node3D
class_name DinnerDoor

## Reusable bedroom, pantry, and fridge hold-to-open interaction.
## Risk is based only on the current openness rate: a paused door is silent and
## the fridge creates no analytical spill while it is paused.

signal fully_closed()

enum DoorKind {
	BEDROOM,
	PANTRY,
	FRIDGE,
}

@export_group("Identity")
@export var door_kind: DoorKind = DoorKind.BEDROOM
@export var provides_snack: bool = false

@export_group("Interaction")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("Node3D") var snack_path: NodePath = NodePath("../Snack")
@export var interaction_radius: float = 1.6
@export_range(0.0, 1.0) var snack_open_threshold: float = 0.6
@export var sneak_open_duration: float = 5.0
@export var rush_open_duration: float = 1.0
@export var close_duration: float = 1.0

@export_group("Creak")
@export var creak_loudness_per_open_rate: float = 4.0
@export var creak_emit_interval: float = 0.12

@export_group("Fridge Spill")
@export var fridge_light_id: String = "fridge"
@export var fridge_spill_radius_per_open_rate: float = 4.0
@export var fridge_spill_energy_per_open_rate: float = 1.0

@export_group("Doorway Blocker")
@export_range(0.0, 1.0) var blocker_disable_openness: float = 0.35
@export var bedroom_blocker_size: Vector3 = Vector3(2.3, 1.2, 0.12)
@export var pantry_blocker_size: Vector3 = Vector3(3.4, 2.0, 0.12)
@export var fridge_blocker_size: Vector3 = Vector3(2.4, 2.1, 0.12)
@export var blocker_center_offset: Vector3 = Vector3.ZERO
@export_flags_3d_physics var blocker_collision_layer: int = 1
@export_flags_3d_physics var blocker_collision_mask: int = 1

@export_group("Optional Visual")
@export_node_path("Node3D") var door_visual_path: NodePath = NodePath("DoorVisual")
@export var open_rotation_degrees: Vector3 = Vector3(0.0, -90.0, 0.0)

var openness: float = 0.0

var _player: DinnerPlayer
var _snack: DinnerSnack
var _door_visual: Node3D
var _closed_rotation_degrees: Vector3
var _creak_elapsed: float = 0.0
var _blocker_shape: CollisionShape3D
var _blocker_disabled: bool = false
var _snack_revealed: bool = false
var _closing_requested: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_door_visual = get_node_or_null(door_visual_path) as Node3D
	if _door_visual != null:
		_closed_rotation_degrees = _door_visual.rotation_degrees
		_disable_visual_collision(_door_visual)
	_spawn_blocker()
	_apply_visual()
	_update_blocker_collision(true)
	if door_kind == DoorKind.FRIDGE:
		_register_fridge_light()
		_set_fridge_spill(0.0)


func _physics_process(delta: float) -> void:
	var previous_openness: float = openness
	if _closing_requested:
		if close_duration <= 0.0:
			openness = 0.0
		else:
			openness = maxf(openness - delta / close_duration, 0.0)
		if is_zero_approx(openness):
			openness = 0.0
			_closing_requested = false
			fully_closed.emit()
	elif _can_open():
		var open_duration: float = rush_open_duration if Input.is_action_pressed("run") else sneak_open_duration
		if open_duration > 0.0:
			openness = minf(openness + delta / open_duration, 1.0)

	var openness_rate: float = 0.0
	if delta > 0.0:
		openness_rate = absf(openness - previous_openness) / delta
	_apply_visual()
	_update_blocker_collision()
	_apply_risk(openness_rate, delta)
	_try_reveal_snack()


func close() -> void:
	if is_zero_approx(openness):
		openness = 0.0
		_closing_requested = false
		return
	_closing_requested = true


func is_closing() -> bool:
	return _closing_requested


func _can_open() -> bool:
	return (
		openness < 1.0
		and _is_player_in_range()
		and not _player.input_locked
		and Input.is_action_pressed("interact")
	)


func _is_player_in_range() -> bool:
	return _player != null and _player.global_position.distance_to(global_position) <= interaction_radius


func _apply_risk(openness_rate: float, delta: float) -> void:
	if door_kind == DoorKind.FRIDGE:
		_set_fridge_spill(openness_rate)
		return
	_emit_creak(openness_rate, delta)


func _emit_creak(openness_rate: float, delta: float) -> void:
	if openness_rate <= 0.0:
		_creak_elapsed = 0.0
		return
	if creak_emit_interval <= 0.0:
		return

	_creak_elapsed += delta
	if _creak_elapsed < creak_emit_interval:
		return
	_creak_elapsed = fmod(_creak_elapsed, creak_emit_interval)

	var raw_loudness: float = openness_rate * creak_loudness_per_open_rate
	var mask: float = clampf(NoiseSystem.get_mask_at(global_position), 0.0, 1.0)
	var loudness: float = raw_loudness * (1.0 - mask)
	if loudness > 0.0:
		NoiseSystem.emit_noise(global_position, loudness, self)


func _register_fridge_light() -> void:
	if LightSystem.has_method("register_dynamic_light"):
		LightSystem.call("register_dynamic_light", fridge_light_id, global_position)


func _set_fridge_spill(openness_rate: float) -> void:
	if not LightSystem.has_method("set_dynamic_light"):
		return
	var radius: float = openness_rate * fridge_spill_radius_per_open_rate
	var energy: float = openness_rate * fridge_spill_energy_per_open_rate
	LightSystem.call("set_dynamic_light", fridge_light_id, radius, energy)


func _try_reveal_snack() -> void:
	if not provides_snack or openness < snack_open_threshold or _snack == null:
		return
	if not _snack_revealed:
		_snack.reveal_at(global_position)
		_snack_revealed = true
	if _snack.available_for_pickup and _is_player_in_range():
		_snack.pick_up(_player)


func _apply_visual() -> void:
	if _door_visual == null:
		return
	_door_visual.rotation_degrees = _closed_rotation_degrees.lerp(open_rotation_degrees, openness)


func _disable_visual_collision(node: Node) -> void:
	if node is CollisionObject3D:
		var collision_object: CollisionObject3D = node as CollisionObject3D
		collision_object.collision_layer = 0
		collision_object.collision_mask = 0
	if node is CollisionShape3D:
		(node as CollisionShape3D).set_deferred("disabled", true)
	for child in node.get_children():
		_disable_visual_collision(child)


func _spawn_blocker() -> void:
	var blocker: StaticBody3D = StaticBody3D.new()
	blocker.name = "Blocker"
	blocker.collision_layer = blocker_collision_layer
	blocker.collision_mask = blocker_collision_mask
	add_child(blocker)

	var blocker_size: Vector3 = _get_blocker_size()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = blocker_size
	_blocker_shape = CollisionShape3D.new()
	_blocker_shape.name = "CollisionShape3D"
	_blocker_shape.shape = box_shape
	_blocker_shape.position = blocker_center_offset + Vector3.UP * blocker_size.y * 0.5
	blocker.add_child(_blocker_shape)


func _update_blocker_collision(force: bool = false) -> void:
	if _blocker_shape == null:
		return
	var should_disable: bool = openness >= blocker_disable_openness
	if not force and should_disable == _blocker_disabled:
		return
	_blocker_disabled = should_disable
	_blocker_shape.set_deferred("disabled", should_disable)


func _get_blocker_size() -> Vector3:
	match door_kind:
		DoorKind.PANTRY:
			return pantry_blocker_size
		DoorKind.FRIDGE:
			return fridge_blocker_size
		_:
			return bedroom_blocker_size
