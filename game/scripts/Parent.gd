extends Node3D
class_name DinnerParent

## Time-indexed parent routine with investigate and carry overrides.
## Routine coordinates are placeholders until the A0.2 relayout is committed.

signal state_changed(state_name: StringName)
signal player_caught(catch_position: Vector3)

enum State {
	ROUTINE,
	INVESTIGATE,
	CARRY,
}

@export_group("Scene References")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("NavigationAgent3D") var navigation_agent_path: NodePath = NodePath("NavigationAgent3D")
@export_node_path("MeshInstance3D") var vision_cone_path: NodePath = NodePath("VisionCone")
@export_node_path("Node3D") var crib_path: NodePath = NodePath("../Crib")
@export_node_path("Node3D") var snack_path: NodePath = NodePath("../Snack")

@export_group("Routine")
@export var routine_duration: float = 300.0
@export var routine_speed: float = 1.5
@export var routine_repath_distance: float = 0.25
@export var facing_turn_speed: float = 5.0
@export var routine_rows: Array[Dictionary] = [
	{
		"time": 0.0,
		"position": Vector3(1.5, 0.7, -7.0),
		"dwell": 60.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 90.0,
		"position": Vector3(10.0, 0.7, -2.5),
		"dwell": 15.0,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
	{
		"time": 130.0,
		"position": Vector3(1.5, 0.7, -7.0),
		"dwell": 70.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 240.0,
		"position": Vector3(-7.0, 0.7, 3.5),
		"dwell": 60.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
]

@export_group("Vision")
@export var vision_range: float = 7.0
@export var routine_cone_angle_degrees: float = 60.0
@export var investigate_cone_angle_degrees: float = 35.0
@export var found_cone_angle_degrees: float = 90.0
@export var sweep_angle_degrees: float = 35.0
@export var sweep_period_seconds: float = 4.0
@export var brightness_threshold: float = 0.35
@export var eye_height: float = 0.45
@export var player_aim_height: float = 0.35
@export var cone_floor_offset: float = -0.65
@export_flags_3d_physics var vision_collision_mask: int = 1

@export_group("Suspicion")
@export var suspicion_max: float = 100.0
@export var investigate_threshold: float = 50.0
@export var noise_suspicion_multiplier: float = 10.0
@export var hearing_radius: float = 8.0
@export var seen_suspicion_per_second: float = 25.0
@export var suspicion_decay_per_second: float = 8.0

@export_group("Investigate")
@export var investigate_speed: float = 1.8
@export var investigate_alert_pause: float = 0.6
@export var investigate_look_duration: float = 4.0
@export var investigate_hard_timeout: float = 10.0
@export var repeat_cooldown_duration: float = 8.0
@export var repeat_cooldown_distance: float = 2.0

@export_group("Carry")
@export var carry_speed: float = 2.6
@export var carry_arrival_distance: float = 0.5
@export var carry_offset: Vector3 = Vector3(0.55, 0.35, 0.0)
@export var crib_player_offset: Vector3 = Vector3(0.0, 0.65, 0.0)

@export_group("Readability")
@export var cone_base_color: Color = Color(0.68, 0.56, 0.92, 0.24)
@export var cone_suspicious_color: Color = Color(1.0, 0.68, 0.18, 0.34)
@export var cone_found_color: Color = Color(1.0, 0.12, 0.12, 0.45)

var suspicion: float = 0.0

var _state: State = State.ROUTINE
var _player: DinnerPlayer
var _navigation_agent: NavigationAgent3D
var _vision_cone: MeshInstance3D
var _crib: Node3D
var _snack: DinnerSnack
var _cone_material: StandardMaterial3D
var _navigation_ready: bool = false
var _last_navigation_target: Vector3
var _has_navigation_target: bool = false
var _sweep_time: float = 0.0
var _cone_yaw_degrees: float = 0.0
var _rendered_cone_angle: float = -1.0
var _heard_since_last_tick: bool = false
var _last_known_position: Vector3
var _investigate_elapsed: float = 0.0
var _investigate_look_elapsed: float = 0.0
var _repeat_cooldown_remaining: float = 0.0
var _last_checked_position: Vector3
var _has_checked_position: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_navigation_agent = get_node_or_null(navigation_agent_path) as NavigationAgent3D
	_vision_cone = get_node_or_null(vision_cone_path) as MeshInstance3D
	_crib = get_node_or_null(crib_path) as Node3D
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_setup_cone()
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)
	_finish_navigation_setup.call_deferred()


func _physics_process(delta: float) -> void:
	_repeat_cooldown_remaining = maxf(_repeat_cooldown_remaining - delta, 0.0)
	_update_sweep(delta)
	_update_perception(delta)

	match _state:
		State.ROUTINE:
			_update_routine(delta)
		State.INVESTIGATE:
			_update_investigate(delta)
		State.CARRY:
			_update_carry(delta)

	_update_readability()
	_heard_since_last_tick = false


func get_base_target(time_elapsed: float) -> Vector3:
	if routine_rows.is_empty():
		return global_position
	if time_elapsed <= _row_time(routine_rows[0]):
		return _row_position(routine_rows[0])

	for row_index in range(routine_rows.size() - 1):
		var current_row: Dictionary = routine_rows[row_index]
		var next_row: Dictionary = routine_rows[row_index + 1]
		var departure_time: float = _row_time(current_row) + _row_dwell(current_row)
		var arrival_time: float = _row_time(next_row)
		if time_elapsed <= departure_time:
			return _row_position(current_row)
		if time_elapsed < arrival_time:
			var travel_duration: float = arrival_time - departure_time
			if travel_duration <= 0.0:
				return _row_position(next_row)
			var travel_weight: float = (time_elapsed - departure_time) / travel_duration
			return _row_position(current_row).lerp(_row_position(next_row), travel_weight)

	return _row_position(routine_rows.back())


func get_base_facing(time_elapsed: float) -> Vector3:
	if routine_rows.is_empty():
		return -global_transform.basis.z
	for row_index in range(routine_rows.size() - 1):
		var current_row: Dictionary = routine_rows[row_index]
		var next_row: Dictionary = routine_rows[row_index + 1]
		var departure_time: float = _row_time(current_row) + _row_dwell(current_row)
		var arrival_time: float = _row_time(next_row)
		if time_elapsed <= departure_time:
			return _row_facing(current_row)
		if time_elapsed < arrival_time:
			var travel_direction: Vector3 = _row_position(next_row) - _row_position(current_row)
			travel_direction.y = 0.0
			return travel_direction.normalized() if travel_direction.length_squared() > 0.0 else _row_facing(next_row)
	return _row_facing(routine_rows.back())


func get_state_name() -> StringName:
	return State.keys()[_state]


func _finish_navigation_setup() -> void:
	await get_tree().physics_frame
	_navigation_ready = true
	_set_navigation_target(get_base_target(_get_routine_time()), true)


func _update_routine(delta: float) -> void:
	var routine_time: float = _get_routine_time()
	var target: Vector3 = get_base_target(routine_time)
	_set_navigation_target(target)
	if not _move_along_path(routine_speed, delta):
		_face_direction(get_base_facing(routine_time), delta)


func _update_investigate(delta: float) -> void:
	_investigate_elapsed += delta
	if _investigate_elapsed >= investigate_hard_timeout:
		_finish_investigate()
		return
	if _investigate_elapsed < investigate_alert_pause:
		return
	if not _can_query_navigation():
		return

	_set_navigation_target(_last_known_position)
	if _move_along_path(investigate_speed, delta):
		_investigate_look_elapsed = 0.0
		return

	_investigate_look_elapsed += delta
	if _investigate_look_elapsed >= investigate_look_duration:
		_finish_investigate()


func _update_carry(delta: float) -> void:
	if _crib == null or _player == null:
		_finish_carry()
		return
	if not _can_query_navigation():
		return
	_set_navigation_target(_crib.global_position)
	_move_along_path(carry_speed, delta)
	if global_position.distance_to(_crib.global_position) <= carry_arrival_distance:
		_finish_carry()


func _move_along_path(speed: float, delta: float) -> bool:
	if not _can_query_navigation() or _navigation_agent.is_navigation_finished():
		return false
	var next_path_position: Vector3 = _navigation_agent.get_next_path_position()
	var movement: Vector3 = next_path_position - global_position
	movement.y = 0.0
	if movement.length_squared() <= 0.0:
		return false
	var movement_distance: float = minf(speed * delta, movement.length())
	var movement_direction: Vector3 = movement.normalized()
	global_position += movement_direction * movement_distance
	_face_direction(movement_direction, delta)
	return true


func _set_navigation_target(target: Vector3, force: bool = false) -> void:
	if _navigation_agent == null:
		return
	if not force and _has_navigation_target and _last_navigation_target.distance_to(target) < routine_repath_distance:
		return
	_navigation_agent.target_position = target
	_last_navigation_target = target
	_has_navigation_target = true


func _can_query_navigation() -> bool:
	if not _navigation_ready or _navigation_agent == null:
		return false
	return NavigationServer3D.map_get_iteration_id(_navigation_agent.get_navigation_map()) > 0


func _update_perception(delta: float) -> void:
	if _state == State.CARRY or _player == null:
		return

	var sees_player: bool = _can_see_player()
	if sees_player:
		_last_known_position = _player.global_position
		suspicion += seen_suspicion_per_second * delta
		if suspicion >= suspicion_max:
			_begin_carry()
		elif suspicion >= investigate_threshold:
			_begin_or_update_investigate(_last_known_position)
	elif not _heard_since_last_tick:
		suspicion -= suspicion_decay_per_second * delta
	suspicion = clampf(suspicion, 0.0, suspicion_max)


func _can_see_player() -> bool:
	var to_player: Vector3 = _player.global_position - global_position
	to_player.y = 0.0
	var distance_to_player: float = to_player.length()
	if distance_to_player <= 0.0 or distance_to_player > vision_range:
		return false

	var cone_angle: float = _get_current_cone_angle()
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized().rotated(Vector3.UP, deg_to_rad(_cone_yaw_degrees))
	if rad_to_deg(forward.angle_to(to_player.normalized())) > cone_angle * 0.5:
		return false
	if LightSystem.get_brightness_at(_player.global_position) <= brightness_threshold:
		return false
	return _has_clear_line_of_sight()


func _has_clear_line_of_sight() -> bool:
	var ray_start: Vector3 = global_position + Vector3.UP * eye_height
	var ray_end: Vector3 = _player.global_position + Vector3.UP * player_aim_height
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		ray_start, ray_end, vision_collision_mask
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return result.is_empty() or result.get("collider") == _player


func _on_noise_emitted(pos: Vector3, loudness: float, source: Node) -> void:
	if source == self or _state == State.CARRY:
		return
	var distance_to_noise: float = global_position.distance_to(pos)
	if distance_to_noise >= hearing_radius:
		return
	var falloff: float = 1.0 - distance_to_noise / hearing_radius
	suspicion = clampf(
		suspicion + loudness * noise_suspicion_multiplier * falloff,
		0.0,
		suspicion_max
	)
	_heard_since_last_tick = true
	_last_known_position = pos
	if suspicion >= suspicion_max:
		_begin_carry()
	elif suspicion >= investigate_threshold:
		_begin_or_update_investigate(pos)


func _begin_or_update_investigate(target: Vector3) -> void:
	if _is_repeat_target_suppressed(target):
		return
	_last_known_position = target
	if _state == State.INVESTIGATE:
		_set_navigation_target(target, true)
		return
	_state = State.INVESTIGATE
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_set_navigation_target(target, true)
	state_changed.emit(get_state_name())


func _finish_investigate() -> void:
	_last_checked_position = _last_known_position
	_has_checked_position = true
	_repeat_cooldown_remaining = repeat_cooldown_duration
	_state = State.ROUTINE
	_set_navigation_target(get_base_target(_get_routine_time()), true)
	state_changed.emit(get_state_name())


func _is_repeat_target_suppressed(target: Vector3) -> bool:
	return (
		_has_checked_position
		and _repeat_cooldown_remaining > 0.0
		and _last_checked_position.distance_to(target) <= repeat_cooldown_distance
	)


func _begin_carry() -> void:
	if _state == State.CARRY or _player == null:
		return
	var catch_position: Vector3 = _player.global_position
	if _player.carrying_snack:
		if _snack != null:
			_snack.drop_at(catch_position)
		else:
			_player.set_carrying_snack(false)
	_player.attach_to_carrier(self, carry_offset)
	suspicion = 0.0
	_state = State.CARRY
	if _crib != null:
		_set_navigation_target(_crib.global_position, true)
	state_changed.emit(get_state_name())
	player_caught.emit(catch_position)


func _finish_carry() -> void:
	if _player != null:
		var player_drop_position: Vector3 = global_position
		if _crib != null:
			player_drop_position = _crib.global_position + crib_player_offset
		_player.detach_from_carrier(player_drop_position)
	_state = State.ROUTINE
	_set_navigation_target(get_base_target(_get_routine_time()), true)
	state_changed.emit(get_state_name())


func _get_routine_time() -> float:
	return clampf(routine_duration - GameClock.time_remaining, 0.0, routine_duration)


func _update_sweep(delta: float) -> void:
	if _state != State.ROUTINE or sweep_period_seconds <= 0.0:
		_cone_yaw_degrees = 0.0
	else:
		_sweep_time += delta
		_cone_yaw_degrees = sin(_sweep_time * TAU / sweep_period_seconds) * sweep_angle_degrees
	if _vision_cone != null:
		_vision_cone.rotation_degrees.y = _cone_yaw_degrees


func _update_readability() -> void:
	if _vision_cone == null or _cone_material == null:
		return
	var cone_angle: float = _get_current_cone_angle()
	if not is_equal_approx(cone_angle, _rendered_cone_angle):
		_build_cone_mesh(cone_angle)
	var suspicion_weight: float = clampf(suspicion / suspicion_max, 0.0, 1.0)
	if _state == State.CARRY:
		_cone_material.albedo_color = cone_found_color
	else:
		_cone_material.albedo_color = cone_base_color.lerp(cone_suspicious_color, suspicion_weight)


func _get_current_cone_angle() -> float:
	match _state:
		State.INVESTIGATE:
			return investigate_cone_angle_degrees
		State.CARRY:
			return found_cone_angle_degrees
		_:
			return routine_cone_angle_degrees


func _setup_cone() -> void:
	if _vision_cone == null:
		return
	_cone_material = StandardMaterial3D.new()
	_cone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_cone_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_cone_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_cone_material.albedo_color = cone_base_color
	_vision_cone.position.y = cone_floor_offset
	_build_cone_mesh(_get_current_cone_angle())


func _build_cone_mesh(cone_angle_degrees: float) -> void:
	if _vision_cone == null or _cone_material == null:
		return
	var half_width: float = tan(deg_to_rad(cone_angle_degrees * 0.5)) * vision_range
	var cone_mesh: ImmediateMesh = ImmediateMesh.new()
	cone_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _cone_material)
	cone_mesh.surface_add_vertex(Vector3.ZERO)
	cone_mesh.surface_add_vertex(Vector3(-half_width, 0.0, -vision_range))
	cone_mesh.surface_add_vertex(Vector3(half_width, 0.0, -vision_range))
	cone_mesh.surface_end()
	_vision_cone.mesh = cone_mesh
	_rendered_cone_angle = cone_angle_degrees


func _face_direction(direction: Vector3, delta: float) -> void:
	var flat_direction: Vector3 = direction
	flat_direction.y = 0.0
	if flat_direction.length_squared() <= 0.0:
		return
	var target_yaw: float = atan2(-flat_direction.x, -flat_direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, clampf(facing_turn_speed * delta, 0.0, 1.0))


func _row_time(row: Dictionary) -> float:
	return float(row.get("time", 0.0))


func _row_position(row: Dictionary) -> Vector3:
	return row.get("position", global_position) as Vector3


func _row_dwell(row: Dictionary) -> float:
	return float(row.get("dwell", 0.0))


func _row_facing(row: Dictionary) -> Vector3:
	var facing: Vector3 = row.get("facing", Vector3.FORWARD) as Vector3
	facing.y = 0.0
	return facing.normalized() if facing.length_squared() > 0.0 else Vector3.FORWARD
