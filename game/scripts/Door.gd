extends Node3D
class_name DinnerDoor

## Reusable bedroom, pantry, and fridge hold-to-open interaction.
## Risk is based only on the current openness rate: a paused door is silent and
## the fridge creates no analytical spill while it is paused.

signal fully_closed()
signal openness_rate_changed(rate: float)

enum DoorKind {
	BEDROOM,
	PANTRY,
	FRIDGE,
}

@export_group("Identity")
@export var door_kind: DoorKind = DoorKind.BEDROOM
@export var provides_snack: bool = false
@export var snack_type: StringName = &""

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
@export var creak_slow_rate: float = 0.2
@export var creak_fast_rate: float = 1.0
@export var creak_slow_pitch_scale: float = 0.85
@export var creak_fast_pitch_scale: float = 1.15
@export var creak_quiet_volume_db: float = -18.0
@export var creak_rush_volume_db: float = -7.0

@export_group("Fridge Spill")
@export var fridge_light_id: String = "fridge"
@export var fridge_spill_radius_per_open_rate: float = 4.0
@export var fridge_spill_energy_per_open_rate: float = 1.0

@export_group("Doorway Blocker")
## The doorway slab is stationary and switches off wholesale, while the panel
## it stands in for swings; below this openness the player was walking through
## a visibly-closed door (2026-07-25 director report). The clear gap a swung
## panel leaves is `width * (1 - cos(90 * openness))`, so it first exceeds the
## 0.68 m player capsule diameter at openness 0.50 on the 2.30 m bedroom door,
## 0.44 on the 2.95 m bathroom door and 0.40 on the 3.55 m pantry door; 0.55
## clears the narrowest of those by 0.13 m.
## HARD CEILING 0.70 — do not raise this above it. Two parent states stand and
## wait on `openness >= blocker_disable_openness` with no timeout:
## `_update_post_deposit_room_enter` (which only commands
## `post_deposit_room_entry_openness` = 0.70) and `_is_waiting_for_routine_door`
## (which commands `bathroom_door_open_openness` = 0.85). Exceeding 0.70
## soft-locks the capture epilogue.
@export_range(0.0, 1.0) var blocker_disable_openness: float = 0.55
@export var bedroom_blocker_size: Vector3 = Vector3(2.3, 1.2, 0.25)
@export var pantry_blocker_size: Vector3 = Vector3(3.55, 1.2, 0.25)
@export var fridge_blocker_size: Vector3 = Vector3(2.4, 2.2, 0.12)
@export var blocker_center_offset: Vector3 = Vector3.ZERO
@export_flags_3d_physics var blocker_collision_layer: int = 1
@export_flags_3d_physics var blocker_collision_mask: int = 1

@export_group("Optional Visual")
@export_node_path("Node3D") var door_visual_path: NodePath = NodePath("DoorVisual")
@export var open_rotation_degrees: Vector3 = Vector3(0.0, -90.0, 0.0)

@export_group("Visual Dressing")
## Closed swing doors block the A21 over-door spill band (panel top to the
## doorway opening height); the shadow-only extension rides the panel, so an
## opening door releases light with the swing (2026-07-25 playtest).
@export var panel_shadow_extension_top: float = 2.4
@export var panel_knob_radius: float = 0.05
@export var panel_knob_height: float = 0.55
@export var panel_knob_inset: float = 0.2
@export var fridge_handle_length: float = 1.15
@export var fridge_handle_edge_inset: float = 0.16

var openness: float = 0.0
var openness_rate: float = 0.0

var _player: DinnerPlayer
var _snack: DinnerSnack
var _door_visual: Node3D
var _closed_rotation_degrees: Vector3
var _creak_elapsed: float = 0.0
var _blocker_shape: CollisionShape3D
var _blocker_disabled: bool = false
var _snack_revealed: bool = false
var _closing_requested: bool = false
var _programmatic_open_target: float = -1.0


func _ready() -> void:
	add_to_group("interactable")
	if provides_snack and snack_type == &"":
		snack_type = _get_default_snack_type()
	_player = get_node_or_null(player_path) as DinnerPlayer
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_door_visual = get_node_or_null(door_visual_path) as Node3D
	if _door_visual != null:
		_closed_rotation_degrees = _door_visual.rotation_degrees
		_disable_visual_collision(_door_visual)
		_decorate_door_visual()
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
	elif _programmatic_open_target >= 0.0:
		if sneak_open_duration <= 0.0:
			openness = _programmatic_open_target
		else:
			openness = minf(
				openness + delta / sneak_open_duration,
				_programmatic_open_target
			)
		if openness >= _programmatic_open_target:
			openness = _programmatic_open_target
			_programmatic_open_target = -1.0
	elif _can_open():
		var open_duration: float = rush_open_duration if Input.is_action_pressed("run") else sneak_open_duration
		if open_duration > 0.0:
			openness = minf(openness + delta / open_duration, 1.0)

	openness_rate = 0.0
	if delta > 0.0:
		openness_rate = absf(openness - previous_openness) / delta
	openness_rate_changed.emit(openness_rate)
	_apply_visual()
	_update_blocker_collision()
	_apply_risk(openness_rate, delta)
	_try_reveal_snack()


func close() -> void:
	_programmatic_open_target = -1.0
	if is_zero_approx(openness):
		openness = 0.0
		_closing_requested = false
		return
	_closing_requested = true


func close_immediately() -> void:
	_closing_requested = false
	_programmatic_open_target = -1.0
	openness = 0.0
	openness_rate = 0.0
	_apply_visual()
	_update_blocker_collision()
	if door_kind == DoorKind.FRIDGE:
		_set_fridge_spill(0.0)
	fully_closed.emit()


func open_to(target_openness: float) -> void:
	_closing_requested = false
	var clamped_target: float = clampf(target_openness, 0.0, 1.0)
	if clamped_target <= openness:
		_programmatic_open_target = -1.0
		return
	_programmatic_open_target = clamped_target


func is_closing() -> bool:
	return _closing_requested


func is_opening_to_target() -> bool:
	return _programmatic_open_target >= 0.0


func get_creak_rate_weight() -> float:
	return clampf(
		inverse_lerp(creak_slow_rate, creak_fast_rate, openness_rate),
		0.0,
		1.0
	)


func get_creak_pitch_scale() -> float:
	return lerpf(
		creak_slow_pitch_scale,
		creak_fast_pitch_scale,
		get_creak_rate_weight()
	)


func get_creak_volume_db() -> float:
	return lerpf(
		creak_quiet_volume_db,
		creak_rush_volume_db,
		get_creak_rate_weight()
	)


func get_hold_seconds_remaining(is_rushing: bool = false) -> float:
	var duration: float = rush_open_duration if is_rushing else sneak_open_duration
	return maxf((1.0 - openness) * duration, 0.0)


func get_hinge_global_position() -> Vector3:
	return (
		_door_visual.global_position
		if _door_visual != null
		else global_position
	)


func _can_open() -> bool:
	return (
		openness < 1.0
		and _is_player_in_range()
		and not _player.input_locked
		and _player.is_interaction_target(self)
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
	var hinge_position: Vector3 = get_hinge_global_position()
	var mask: float = clampf(NoiseSystem.get_mask_at(hinge_position), 0.0, 1.0)
	var loudness: float = raw_loudness * (1.0 - mask)
	if loudness > 0.0:
		NoiseSystem.emit_noise(hinge_position, loudness, self)


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
		_snack.reveal_at(global_position, snack_type)
		_snack_revealed = true
	if _snack.available_for_pickup and _is_player_in_range():
		_snack.pick_up(_player)


func _apply_visual() -> void:
	if _door_visual == null:
		return
	_door_visual.rotation_degrees = _closed_rotation_degrees.lerp(open_rotation_degrees, openness)


func _decorate_door_visual() -> void:
	var panel: MeshInstance3D = (
		_door_visual.get_node_or_null("Panel") as MeshInstance3D
	)
	if panel == null:
		return
	if door_kind == DoorKind.FRIDGE:
		_add_fridge_handle(panel)
		return
	var panel_top: float = panel.position.y + panel.scale.y * 0.5
	if panel_top < panel_shadow_extension_top - 0.05:
		var extension: MeshInstance3D = MeshInstance3D.new()
		extension.name = "PanelShadowExtension"
		extension.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		)
		var extension_mesh: BoxMesh = BoxMesh.new()
		extension_mesh.size = Vector3(
			panel.scale.x,
			panel_shadow_extension_top - panel_top,
			panel.scale.z
		)
		extension.position = Vector3(
			panel.position.x,
			panel_top + extension_mesh.size.y * 0.5,
			panel.position.z
		)
		extension.mesh = extension_mesh
		_door_visual.add_child(extension)
	var knob: MeshInstance3D = MeshInstance3D.new()
	knob.name = "Knob"
	knob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var knob_mesh: CylinderMesh = CylinderMesh.new()
	knob_mesh.top_radius = panel_knob_radius
	knob_mesh.bottom_radius = panel_knob_radius
	knob_mesh.height = panel.scale.z + 0.16
	knob_mesh.radial_segments = 12
	knob.rotation_degrees.x = 90.0
	knob.position = Vector3(
		panel.position.x
		+ (panel.scale.x * 0.5 - panel_knob_inset) * signf(panel.position.x),
		panel_knob_height,
		panel.position.z
	)
	knob.mesh = knob_mesh
	var knob_material: StandardMaterial3D = StandardMaterial3D.new()
	knob_material.albedo_color = Color("#c8c6c0")
	knob_material.roughness = 0.6
	knob.material_override = knob_material
	_door_visual.add_child(knob)


func _add_fridge_handle(panel: MeshInstance3D) -> void:
	# Long vertical bar on the door's free (west) edge so the appliance reads
	# as a fridge at a glance (2026-07-25 director request). Child of the
	# visual, so it swings with the panel.
	var handle: MeshInstance3D = MeshInstance3D.new()
	handle.name = "FridgeHandle"
	handle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var handle_mesh: BoxMesh = BoxMesh.new()
	handle_mesh.size = Vector3(0.09, fridge_handle_length, 0.09)
	handle.position = Vector3(
		panel.position.x
		+ (panel.scale.x * 0.5 - fridge_handle_edge_inset)
		* signf(panel.position.x),
		panel.position.y,
		panel.position.z + panel.scale.z * 0.5 + 0.07
	)
	handle.mesh = handle_mesh
	var handle_material: StandardMaterial3D = StandardMaterial3D.new()
	handle_material.albedo_color = Color("#c8c6c0")
	handle_material.roughness = 0.5
	handle.material_override = handle_material
	_door_visual.add_child(handle)


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


func _get_default_snack_type() -> StringName:
	match door_kind:
		DoorKind.FRIDGE:
			return DinnerSnack.TYPE_ICE_CREAM
		DoorKind.PANTRY:
			return DinnerSnack.TYPE_CHIPS
		_:
			return &""
