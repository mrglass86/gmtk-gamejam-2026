extends Node3D
class_name DinnerPet

## Time-indexed patrol with noise-only alert, investigate, and bark overrides.

signal state_changed(state_name: StringName)
signal alert_started()
signal bark_started()

enum State {
	BASE,
	ALERT,
	INVESTIGATE,
	BARK,
}

@export_group("Scene References")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("NavigationAgent3D") var navigation_agent_path: NodePath = NodePath("NavigationAgent3D")
@export_node_path("MeshInstance3D") var body_path: NodePath = NodePath("Body")

@export_group("Patrol")
@export var patrol_speed: float = 1.5
@export var initial_sleep_duration: float = 30.0
@export var patrol_cycle_duration: float = 60.0
@export var patrol_repath_distance: float = 0.05
@export var navigation_path_desired_distance: float = 0.55
@export var navigation_target_desired_distance: float = 0.02
@export var wake_exit_position: Vector3 = Vector3(4.2, 0.42, -3.8)
@export var wake_exit_distance: float = 0.08
@export var facing_turn_speed: float = 6.0
@export var patrol_rows: Array[Dictionary] = [
	{
		"time": 0.0,
		"position": Vector3(5.5, 0.42, -4.2),
		"dwell": 0.0,
	},
	{
		"time": 15.0,
		"position": Vector3(3.0, 0.42, -3.8),
		"dwell": 5.0,
	},
	{
		"time": 30.0,
		"position": Vector3(7.4, 0.42, -1.5),
		"dwell": 5.0,
	},
	{
		"time": 50.0,
		"position": Vector3(5.5, 0.42, -4.2),
		"dwell": 10.0,
	},
	{
		"time": 60.0,
		"position": Vector3(5.5, 0.42, -4.2),
		"dwell": 0.0,
	},
]

@export_group("Alert")
@export var alert_radius: float = 6.0
@export var alert_duration: float = 1.0

@export_group("Investigate")
@export var investigate_speed: float = 1.8
@export var bark_player_distance: float = 2.0
@export var investigate_look_duration: float = 4.0
@export var investigate_hard_timeout: float = 10.0
@export var repeat_cooldown_duration: float = 8.0
@export var repeat_cooldown_distance: float = 2.0

@export_group("Bark")
@export var bark_loudness: float = 5.0
@export var bark_duration: float = 0.6

@export_group("Readability")
@export var base_color: Color = Color(0.63, 0.56, 0.82, 1.0)
@export var investigate_color: Color = Color(1.0, 0.82, 0.2, 1.0)
@export var bark_color: Color = Color(1.0, 0.15, 0.12, 1.0)
@export var alert_scale: Vector3 = Vector3(0.9, 1.2, 0.9)

var _state: State = State.BASE
var _player: DinnerPlayer
var _navigation_agent: NavigationAgent3D
var _body: MeshInstance3D
var _body_material: StandardMaterial3D
var _body_base_scale: Vector3 = Vector3.ONE
var _navigation_ready: bool = false
var _last_navigation_target: Vector3
var _has_navigation_target: bool = false
var _noise_target: Vector3
var _alert_elapsed: float = 0.0
var _investigate_elapsed: float = 0.0
var _investigate_look_elapsed: float = 0.0
var _bark_elapsed: float = 0.0
var _repeat_cooldown_remaining: float = 0.0
var _last_checked_position: Vector3
var _has_checked_position: bool = false
var _has_left_bed: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_navigation_agent = get_node_or_null(navigation_agent_path) as NavigationAgent3D
	_body = get_node_or_null(body_path) as MeshInstance3D
	_setup_body_material()
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)
	_finish_navigation_setup.call_deferred()


func _physics_process(delta: float) -> void:
	_repeat_cooldown_remaining = maxf(_repeat_cooldown_remaining - delta, 0.0)
	match _state:
		State.BASE:
			_update_base(delta)
		State.ALERT:
			_update_alert(delta)
		State.INVESTIGATE:
			_update_investigate(delta)
		State.BARK:
			_update_bark(delta)


func get_base_target(time_elapsed: float) -> Vector3:
	if patrol_rows.is_empty():
		return global_position
	if patrol_cycle_duration <= 0.0:
		return _row_position(patrol_rows[0])
	var cycle_time: float = fmod(maxf(time_elapsed, 0.0), patrol_cycle_duration)
	if cycle_time <= _row_time(patrol_rows[0]):
		return _row_position(patrol_rows[0])

	for row_index in range(patrol_rows.size() - 1):
		var current_row: Dictionary = patrol_rows[row_index]
		var next_row: Dictionary = patrol_rows[row_index + 1]
		var departure_time: float = _row_time(current_row) + _row_dwell(current_row)
		var arrival_time: float = _row_time(next_row)
		if cycle_time <= departure_time:
			return _row_position(current_row)
		if cycle_time < arrival_time:
			var travel_duration: float = arrival_time - departure_time
			if travel_duration <= 0.0:
				return _row_position(next_row)
			var travel_weight: float = (cycle_time - departure_time) / travel_duration
			return _row_position(current_row).lerp(_row_position(next_row), travel_weight)

	return _row_position(patrol_rows.back())


func get_state_name() -> StringName:
	return State.keys()[_state]


func _finish_navigation_setup() -> void:
	await get_tree().physics_frame
	if _navigation_agent != null:
		while (
			NavigationServer3D.map_get_iteration_id(
				_navigation_agent.get_navigation_map()
			)
			<= 0
		):
			await get_tree().physics_frame
		_navigation_agent.path_desired_distance = navigation_path_desired_distance
		_navigation_agent.target_desired_distance = navigation_target_desired_distance
	_navigation_ready = true
	_set_navigation_target(_get_live_base_target(), true)


func _update_base(delta: float) -> void:
	var target: Vector3 = _get_live_base_target()
	_set_navigation_target(target)
	if _is_initially_sleeping():
		return
	_move_along_path(patrol_speed, delta)


func _update_alert(delta: float) -> void:
	_alert_elapsed += delta
	if _alert_elapsed < alert_duration:
		return
	_set_state(State.INVESTIGATE)
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_set_navigation_target(_noise_target, true)


func _update_investigate(delta: float) -> void:
	_investigate_elapsed += delta
	if _investigate_elapsed >= investigate_hard_timeout:
		_finish_investigate()
		return
	if not _can_query_navigation():
		return

	_set_navigation_target(_noise_target)
	if _move_along_path(investigate_speed, delta):
		_investigate_look_elapsed = 0.0
		return

	if _player != null and _player.global_position.distance_to(global_position) <= bark_player_distance:
		_begin_bark()
		return
	_investigate_look_elapsed += delta
	if _investigate_look_elapsed >= investigate_look_duration:
		_finish_investigate()


func _update_bark(delta: float) -> void:
	_bark_elapsed += delta
	if _bark_elapsed >= bark_duration:
		_mark_target_checked()
		_resume_base()


func _on_noise_emitted(pos: Vector3, _loudness: float, source: Node) -> void:
	if source == self or _state == State.BARK:
		return
	if global_position.distance_to(pos) > alert_radius:
		return
	if _is_repeat_target_suppressed(pos):
		return

	_noise_target = pos
	match _state:
		State.BASE:
			_alert_elapsed = 0.0
			_set_state(State.ALERT)
			alert_started.emit()
		State.ALERT:
			pass
		State.INVESTIGATE:
			_set_navigation_target(_noise_target, true)


func _begin_bark() -> void:
	_bark_elapsed = 0.0
	_set_state(State.BARK)
	NoiseSystem.emit_noise(global_position, bark_loudness, self)
	bark_started.emit()


func _finish_investigate() -> void:
	_mark_target_checked()
	_resume_base()


func _mark_target_checked() -> void:
	_last_checked_position = _noise_target
	_has_checked_position = true
	_repeat_cooldown_remaining = repeat_cooldown_duration


func _resume_base() -> void:
	_set_state(State.BASE)
	_set_navigation_target(_get_live_base_target(), true)


func _is_repeat_target_suppressed(target: Vector3) -> bool:
	return (
		_has_checked_position
		and _repeat_cooldown_remaining > 0.0
		and _last_checked_position.distance_to(target) <= repeat_cooldown_distance
	)


func _move_along_path(speed: float, delta: float) -> bool:
	if not _has_left_bed:
		if _move_toward_wake_exit(speed, delta):
			return true
		_has_left_bed = true
		_set_navigation_target(_last_navigation_target, true)
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


func _move_toward_wake_exit(speed: float, delta: float) -> bool:
	var movement: Vector3 = wake_exit_position - global_position
	movement.y = 0.0
	if movement.length() <= wake_exit_distance:
		return false
	var movement_distance: float = minf(speed * delta, movement.length())
	var movement_direction: Vector3 = movement.normalized()
	global_position += movement_direction * movement_distance
	_face_direction(movement_direction, delta)
	return true


func _set_navigation_target(target: Vector3, force: bool = false) -> void:
	if _navigation_agent == null:
		return
	if not force and _has_navigation_target and _last_navigation_target.distance_to(target) < patrol_repath_distance:
		return
	_navigation_agent.target_position = target
	_last_navigation_target = target
	_has_navigation_target = true


func _can_query_navigation() -> bool:
	if not _navigation_ready or _navigation_agent == null:
		return false
	return NavigationServer3D.map_get_iteration_id(_navigation_agent.get_navigation_map()) > 0


func _face_direction(direction: Vector3, delta: float) -> void:
	var flat_direction: Vector3 = direction
	flat_direction.y = 0.0
	if flat_direction.length_squared() <= 0.0:
		return
	var target_yaw: float = atan2(-flat_direction.x, -flat_direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, clampf(facing_turn_speed * delta, 0.0, 1.0))


func _set_state(next_state: State) -> void:
	if _state == next_state:
		return
	_state = next_state
	_apply_state_visual()
	state_changed.emit(get_state_name())


func _setup_body_material() -> void:
	if _body == null:
		return
	_body_base_scale = _body.scale
	var source_material: Material = _body.material_override
	if source_material == null and _body.mesh != null and _body.mesh.get_surface_count() > 0:
		source_material = _body.mesh.surface_get_material(0)
	if source_material is StandardMaterial3D:
		_body_material = source_material.duplicate() as StandardMaterial3D
	else:
		_body_material = StandardMaterial3D.new()
	_body.material_override = _body_material
	_apply_state_visual()


func _apply_state_visual() -> void:
	if _body == null or _body_material == null:
		return
	_body.scale = _body_base_scale
	match _state:
		State.BASE:
			_body_material.albedo_color = base_color
		State.ALERT:
			_body.scale = _body_base_scale * alert_scale
			_body_material.albedo_color = investigate_color
		State.INVESTIGATE:
			_body_material.albedo_color = investigate_color
		State.BARK:
			_body_material.albedo_color = bark_color


func _get_clock_elapsed() -> float:
	return maxf(GameClock.run_length - GameClock.time_remaining, 0.0)


func _get_patrol_elapsed() -> float:
	return maxf(_get_clock_elapsed() - initial_sleep_duration, 0.0)


func _get_live_base_target() -> Vector3:
	return get_base_target(_get_patrol_elapsed())


func _is_initially_sleeping() -> bool:
	return _get_clock_elapsed() < initial_sleep_duration


func _row_time(row: Dictionary) -> float:
	return float(row.get("time", 0.0))


func _row_position(row: Dictionary) -> Vector3:
	return row.get("position", global_position) as Vector3


func _row_dwell(row: Dictionary) -> float:
	return float(row.get("dwell", 0.0))
