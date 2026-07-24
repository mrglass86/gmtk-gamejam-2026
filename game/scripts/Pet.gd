extends Node3D
class_name DinnerPet

## Time-indexed patrol with noise-only alert, investigate, and bark overrides.

signal state_changed(state_name: StringName)
signal alert_started()
signal bark_started()

enum State {
	BASE,
	BOWL_MOVE,
	BOWL_EAT,
	ALERT,
	INVESTIGATE,
	BARK,
}

@export_group("Scene References")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("NavigationAgent3D") var navigation_agent_path: NodePath = NodePath("NavigationAgent3D")
@export_node_path("MeshInstance3D") var body_path: NodePath = NodePath("Body")
@export_node_path("Node3D") var kitchen_bowl_path: NodePath = NodePath("../Level/KitchenBowl")

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

@export_group("Bowl Visit")
@export var bowl_visit_interval_min: float = 45.0
@export var bowl_visit_interval_max: float = 90.0
@export var bowl_visit_speed: float = 1.5
@export var bowl_arrival_distance: float = 0.65
@export var bowl_eat_duration: float = 4.0
@export var bowl_clatter_loudness: float = 1.0
@export var bowl_head_bob_height: float = 0.08
@export var bowl_head_bob_frequency: float = 2.5
@export var bowl_random_seed: int = 260723

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

@export_group("Hearing Ring")
@export var hearing_ring_width: float = 0.08
@export_range(24, 96, 1) var hearing_ring_segments: int = 64
@export var hearing_ring_floor_offset: float = -0.41
@export var hearing_ring_calm_color: Color = Color(0.68, 0.56, 0.92, 1.0)
@export var hearing_ring_alert_color: Color = Color(1.0, 0.82, 0.2, 1.0)
@export_range(0.0, 1.0, 0.01) var hearing_ring_calm_alpha: float = 0.05
@export_range(0.0, 1.0, 0.01) var hearing_ring_alert_alpha_min: float = 0.16
@export_range(0.0, 1.0, 0.01) var hearing_ring_alert_alpha_max: float = 0.32
@export var hearing_ring_pulse_frequency: float = 2.5

@export_group("Readability")
@export var base_color: Color = Color(0.63, 0.56, 0.82, 1.0)
@export var investigate_color: Color = Color(1.0, 0.82, 0.2, 1.0)
@export var bark_color: Color = Color(1.0, 0.15, 0.12, 1.0)
@export var alert_scale: Vector3 = Vector3(0.9, 1.2, 0.9)

@export_group("B12 Runtime Verification")
@export var verify_b12_time_scale: float = 20.0
@export var verify_b12_physics_ticks_per_second: int = 1200
@export var verify_b12_warmup_frames: int = 12
@export var verify_b12_max_physics_frames: int = 18000
@export var verify_b12_wake_time: float = 31.0
@export var verify_b12_alpha_tolerance: float = 0.015
@export var verify_b12_radius_tolerance: float = 0.05
@export var verify_b12_pulse_min_spread: float = 0.05

var _state: State = State.BASE
var _player: DinnerPlayer
var _navigation_agent: NavigationAgent3D
var _body: MeshInstance3D
var _kitchen_bowl: Node3D
var _body_material: StandardMaterial3D
var _hearing_ring: MeshInstance3D
var _hearing_ring_material: StandardMaterial3D
var _hearing_ring_built_radius: float = -1.0
var _hearing_ring_built_width: float = -1.0
var _hearing_ring_built_segments: int = -1
var _hearing_ring_pulse_time: float = 0.0
var _body_base_scale: Vector3 = Vector3.ONE
var _body_base_position: Vector3
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
var _bowl_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _next_bowl_visit_elapsed: float = INF
var _bowl_eat_elapsed: float = 0.0
var _bowl_path_started: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_navigation_agent = get_node_or_null(navigation_agent_path) as NavigationAgent3D
	_body = get_node_or_null(body_path) as MeshInstance3D
	_kitchen_bowl = get_node_or_null(kitchen_bowl_path) as Node3D
	_bowl_rng.seed = bowl_random_seed
	_schedule_next_bowl_visit()
	_setup_body_material()
	_setup_hearing_ring()
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)
	_finish_navigation_setup.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b12"):
		_run_b12_verification.call_deferred()


func _physics_process(delta: float) -> void:
	_repeat_cooldown_remaining = maxf(_repeat_cooldown_remaining - delta, 0.0)
	match _state:
		State.BASE:
			_update_base(delta)
		State.BOWL_MOVE:
			_update_bowl_move(delta)
		State.BOWL_EAT:
			_update_bowl_eat(delta)
		State.ALERT:
			_update_alert(delta)
		State.INVESTIGATE:
			_update_investigate(delta)
		State.BARK:
			_update_bark(delta)
	_update_hearing_ring(delta)


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


func bark() -> void:
	_begin_bark()


func schedule_bowl_visit_after(delay: float) -> void:
	_next_bowl_visit_elapsed = _get_clock_elapsed() + maxf(delay, 0.0)


func is_visiting_bowl() -> bool:
	return _state == State.BOWL_MOVE or _state == State.BOWL_EAT


func is_eating_at_bowl() -> bool:
	return _state == State.BOWL_EAT


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
	if _kitchen_bowl != null and _get_clock_elapsed() >= _next_bowl_visit_elapsed:
		_begin_bowl_visit()
		return
	_move_along_path(patrol_speed, delta)


func _begin_bowl_visit() -> void:
	if _kitchen_bowl == null:
		_schedule_next_bowl_visit()
		return
	_bowl_path_started = false
	_set_state(State.BOWL_MOVE)
	_set_navigation_target(_kitchen_bowl.global_position, true)


func _update_bowl_move(delta: float) -> void:
	if _kitchen_bowl == null:
		_schedule_next_bowl_visit()
		_resume_base()
		return
	_set_navigation_target(_kitchen_bowl.global_position)
	if _can_query_navigation() and not _navigation_agent.is_navigation_finished():
		_bowl_path_started = true
	_move_along_path(bowl_visit_speed, delta)
	var bowl_distance: float = _flat_distance(
		global_position,
		_kitchen_bowl.global_position
	)
	if (
		bowl_distance <= bowl_arrival_distance
		or (
			_bowl_path_started
			and _navigation_agent != null
			and _navigation_agent.is_navigation_finished()
		)
	):
		_begin_bowl_eat()


func _begin_bowl_eat() -> void:
	_bowl_eat_elapsed = 0.0
	_set_state(State.BOWL_EAT)
	NoiseSystem.emit_noise(global_position, bowl_clatter_loudness, self)


func _update_bowl_eat(delta: float) -> void:
	_bowl_eat_elapsed += delta
	_apply_bowl_head_bob()
	if _bowl_eat_elapsed < bowl_eat_duration:
		return
	_reset_bowl_visual()
	_schedule_next_bowl_visit()
	_resume_base()


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
		State.BOWL_MOVE, State.BOWL_EAT:
			_reset_bowl_visual()
			_schedule_next_bowl_visit()
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
	# The dog is a house alarm. Ambient masking applies only to player noise.
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
	_body_base_position = _body.position
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
		State.BOWL_MOVE, State.BOWL_EAT:
			_body_material.albedo_color = base_color
		State.ALERT:
			_body.scale = _body_base_scale * alert_scale
			_body_material.albedo_color = investigate_color
		State.INVESTIGATE:
			_body_material.albedo_color = investigate_color
		State.BARK:
			_body_material.albedo_color = bark_color


func _setup_hearing_ring() -> void:
	_hearing_ring = MeshInstance3D.new()
	_hearing_ring.name = "HearingRing"
	_hearing_ring.position.y = hearing_ring_floor_offset
	add_child(_hearing_ring)

	_hearing_ring_material = StandardMaterial3D.new()
	_hearing_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_hearing_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_hearing_ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_hearing_ring_material.albedo_color = _ring_color_with_alpha(
		hearing_ring_calm_color,
		hearing_ring_calm_alpha
	)
	_build_hearing_ring_mesh()
	_update_hearing_ring(0.0)


func _update_hearing_ring(delta: float) -> void:
	if _hearing_ring == null or _hearing_ring_material == null:
		return
	if (
		not is_equal_approx(_hearing_ring_built_radius, alert_radius)
		or not is_equal_approx(_hearing_ring_built_width, hearing_ring_width)
		or _hearing_ring_built_segments != hearing_ring_segments
	):
		_build_hearing_ring_mesh()
	_hearing_ring.position.y = hearing_ring_floor_offset
	_hearing_ring.visible = not _is_initially_sleeping()
	if not _hearing_ring.visible:
		_hearing_ring_pulse_time = 0.0
		return

	var is_alerting: bool = _state == State.ALERT or _state == State.INVESTIGATE
	if not is_alerting:
		_hearing_ring_pulse_time = 0.0
		_hearing_ring_material.albedo_color = _ring_color_with_alpha(
			hearing_ring_calm_color,
			hearing_ring_calm_alpha
		)
		return

	_hearing_ring_pulse_time += delta
	var pulse_weight: float = (
		0.5
		+ 0.5
		* sin(_hearing_ring_pulse_time * maxf(hearing_ring_pulse_frequency, 0.0) * TAU)
	)
	_hearing_ring_material.albedo_color = _ring_color_with_alpha(
		hearing_ring_alert_color,
		lerpf(
			hearing_ring_alert_alpha_min,
			hearing_ring_alert_alpha_max,
			pulse_weight
		)
	)


func _build_hearing_ring_mesh() -> void:
	if _hearing_ring == null or _hearing_ring_material == null:
		return
	var outer_radius: float = maxf(alert_radius, 0.0)
	var ring_width: float = clampf(
		hearing_ring_width,
		0.0,
		outer_radius
	)
	var inner_radius: float = outer_radius - ring_width
	var segment_count: int = maxi(hearing_ring_segments, 3)
	var ring_mesh: ImmediateMesh = ImmediateMesh.new()
	ring_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _hearing_ring_material)
	for segment_index in range(segment_count):
		var angle_a: float = TAU * float(segment_index) / float(segment_count)
		var angle_b: float = TAU * float(segment_index + 1) / float(segment_count)
		var outer_a: Vector3 = Vector3(
			cos(angle_a) * outer_radius,
			0.0,
			sin(angle_a) * outer_radius
		)
		var outer_b: Vector3 = Vector3(
			cos(angle_b) * outer_radius,
			0.0,
			sin(angle_b) * outer_radius
		)
		var inner_a: Vector3 = Vector3(
			cos(angle_a) * inner_radius,
			0.0,
			sin(angle_a) * inner_radius
		)
		var inner_b: Vector3 = Vector3(
			cos(angle_b) * inner_radius,
			0.0,
			sin(angle_b) * inner_radius
		)
		ring_mesh.surface_add_vertex(outer_a)
		ring_mesh.surface_add_vertex(inner_a)
		ring_mesh.surface_add_vertex(outer_b)
		ring_mesh.surface_add_vertex(outer_b)
		ring_mesh.surface_add_vertex(inner_a)
		ring_mesh.surface_add_vertex(inner_b)
	ring_mesh.surface_end()
	_hearing_ring.mesh = ring_mesh
	_hearing_ring_built_radius = alert_radius
	_hearing_ring_built_width = hearing_ring_width
	_hearing_ring_built_segments = hearing_ring_segments


func _ring_color_with_alpha(color: Color, alpha: float) -> Color:
	var result: Color = color
	result.a = clampf(alpha, 0.0, 1.0)
	return result


func _run_b12_verification() -> void:
	var parent_actor: DinnerParent = get_parent().get_node_or_null("Parent") as DinnerParent
	var parent_cone_material: StandardMaterial3D = null
	if parent_actor != null:
		parent_cone_material = parent_actor.get("_cone_material") as StandardMaterial3D
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = _player != null and _player.is_physics_processing()
	var player_was_input_locked: bool = _player != null and _player.input_locked

	Engine.time_scale = maxf(verify_b12_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(
		verify_b12_physics_ticks_per_second,
		60
	)
	if _player != null:
		_player.set_input_locked(true)
		_player.set_physics_process(false)
		_player.global_position = (
			parent_actor.verify_observer_parking_position
			if parent_actor != null
			else Vector3(-30.0, 0.6, -20.0)
		)

	for _frame_index in range(verify_b12_warmup_frames):
		await get_tree().physics_frame

	GameClock.start()
	await get_tree().physics_frame
	var ring_hidden_while_sleeping: bool = (
		_hearing_ring != null
		and not _hearing_ring.visible
	)
	var cone_base_observed_alpha: float = (
		parent_cone_material.albedo_color.a
		if parent_cone_material != null
		else -1.0
	)

	var reached_wake_time: bool = false
	for _frame_index in range(verify_b12_max_physics_frames):
		await get_tree().physics_frame
		if _get_clock_elapsed() >= verify_b12_wake_time:
			reached_wake_time = true
			break

	var ring_visible_after_waking: bool = (
		_hearing_ring != null
		and _hearing_ring.visible
	)
	var ring_observed_radius: float = -1.0
	if _hearing_ring != null and _hearing_ring.mesh != null:
		ring_observed_radius = _hearing_ring.mesh.get_aabb().size.x * 0.5
	var ring_calm_observed_alpha: float = (
		_hearing_ring_material.albedo_color.a
		if _hearing_ring_material != null
		else -1.0
	)

	NoiseSystem.emit_noise(global_position, 1.0, parent_actor)
	var alert_observed: bool = false
	var investigate_observed: bool = false
	var alert_yellow_observed: bool = false
	var pulse_min_alpha: float = INF
	var pulse_max_alpha: float = -INF
	for _frame_index in range(verify_b12_max_physics_frames):
		await get_tree().physics_frame
		var state_name: StringName = get_state_name()
		if state_name == &"ALERT" or state_name == &"INVESTIGATE":
			alert_observed = alert_observed or state_name == &"ALERT"
			investigate_observed = investigate_observed or state_name == &"INVESTIGATE"
			if _hearing_ring_material != null:
				var pulse_color: Color = _hearing_ring_material.albedo_color
				pulse_min_alpha = minf(pulse_min_alpha, pulse_color.a)
				pulse_max_alpha = maxf(pulse_max_alpha, pulse_color.a)
				alert_yellow_observed = (
					alert_yellow_observed
					or pulse_color.r > pulse_color.b
					and pulse_color.g > pulse_color.b
				)
		if (
			investigate_observed
			and pulse_max_alpha - pulse_min_alpha >= verify_b12_pulse_min_spread
		):
			break

	var cone_suspicious_observed_alpha: float = -1.0
	var cone_suspicious_value: float = -1.0
	if parent_actor != null:
		NoiseSystem.emit_noise(parent_actor.global_position, 2.5, self)
		await get_tree().physics_frame
		cone_suspicious_value = parent_actor.suspicion
		if parent_cone_material != null:
			cone_suspicious_observed_alpha = parent_cone_material.albedo_color.a

	var found_observed: bool = false
	var cone_found_observed_alpha: float = -1.0
	if parent_actor != null and _player != null:
		parent_actor.call("_prepare_point_blank_verification")
		GameClock.start()
		for _frame_index in range(verify_b12_max_physics_frames):
			await get_tree().physics_frame
			var parent_state: StringName = parent_actor.get_state_name()
			if parent_state == &"FOUND" or parent_state == &"CARRY":
				found_observed = true
				if parent_cone_material != null:
					cone_found_observed_alpha = parent_cone_material.albedo_color.a
				break
			if _get_clock_elapsed() >= parent_actor.verify_point_blank_duration:
				break

	var expected_suspicious_alpha: float = -1.0
	if parent_actor != null:
		var suspicious_weight: float = clampf(
			cone_suspicious_value / maxf(parent_actor.suspicion_max, 0.001),
			0.0,
			1.0
		)
		expected_suspicious_alpha = lerpf(
			parent_actor.cone_base_alpha,
			parent_actor.cone_suspicious_alpha,
			suspicious_weight
		)

	var ring_radius_matches: bool = absf(
		ring_observed_radius - alert_radius
	) <= verify_b12_radius_tolerance
	var cone_base_matches: bool = (
		parent_actor != null
		and absf(
			cone_base_observed_alpha - parent_actor.cone_base_alpha
		) <= verify_b12_alpha_tolerance
	)
	var cone_suspicious_matches: bool = (
		parent_actor != null
		and cone_suspicious_observed_alpha > cone_base_observed_alpha
		and absf(
			cone_suspicious_observed_alpha - expected_suspicious_alpha
		) <= verify_b12_alpha_tolerance
	)
	var cone_found_matches: bool = (
		parent_actor != null
		and found_observed
		and absf(
			cone_found_observed_alpha - parent_actor.cone_found_alpha
		) <= verify_b12_alpha_tolerance
	)
	var ring_calm_matches: bool = absf(
		ring_calm_observed_alpha - hearing_ring_calm_alpha
	) <= verify_b12_alpha_tolerance
	var ring_pulsed: bool = (
		pulse_min_alpha < INF
		and pulse_max_alpha > -INF
		and pulse_max_alpha - pulse_min_alpha >= verify_b12_pulse_min_spread
	)
	var verification_passed: bool = (
		ring_hidden_while_sleeping
		and reached_wake_time
		and ring_visible_after_waking
		and ring_radius_matches
		and ring_calm_matches
		and alert_observed
		and investigate_observed
		and alert_yellow_observed
		and ring_pulsed
		and cone_base_matches
		and cone_suspicious_matches
		and cone_found_matches
	)

	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		_player.set_physics_process(player_was_processing)
		_player.set_input_locked(player_was_input_locked)

	print(
		(
			"B12 live metrics: cone alpha %.3f -> %.3f -> %.3f; "
			+ "dog ring hidden=%s, radius=%.2f m, calm=%.3f, "
			+ "alert pulse=%.3f..%.3f, investigate=%s."
		)
		% [
			cone_base_observed_alpha,
			cone_suspicious_observed_alpha,
			cone_found_observed_alpha,
			ring_hidden_while_sleeping,
			ring_observed_radius,
			ring_calm_observed_alpha,
			pulse_min_alpha,
			pulse_max_alpha,
			investigate_observed,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(ring_hidden_while_sleeping, "B12 dog hearing ring showed during sleep.")
	assert(reached_wake_time, "B12 clock did not tick through the dog sleep.")
	assert(ring_visible_after_waking, "B12 dog hearing ring stayed hidden after waking.")
	assert(ring_radius_matches, "B12 dog hearing ring did not match alert_radius.")
	assert(ring_calm_matches, "B12 calm dog ring alpha missed its export.")
	assert(
		alert_observed and investigate_observed and alert_yellow_observed,
		"B12 dog ring missed its yellow ALERT/INVESTIGATE states."
	)
	assert(ring_pulsed, "B12 alert dog ring did not visibly pulse.")
	assert(cone_base_matches, "B12 parent base cone alpha missed its export.")
	assert(
		cone_suspicious_matches,
		"B12 parent cone alpha did not rise with suspicion."
	)
	assert(cone_found_matches, "B12 FOUND cone alpha missed its export.")
	print("B12 live SceneTree verification passed.")


func _get_clock_elapsed() -> float:
	return maxf(GameClock.run_length - GameClock.time_remaining, 0.0)


func _get_patrol_elapsed() -> float:
	return maxf(_get_clock_elapsed() - initial_sleep_duration, 0.0)


func _get_live_base_target() -> Vector3:
	return get_base_target(_get_patrol_elapsed())


func _is_initially_sleeping() -> bool:
	return _get_clock_elapsed() < initial_sleep_duration


func _schedule_next_bowl_visit() -> void:
	var interval_min: float = maxf(bowl_visit_interval_min, 0.0)
	var interval_max: float = maxf(bowl_visit_interval_max, interval_min)
	_next_bowl_visit_elapsed = (
		_get_clock_elapsed()
		+ _bowl_rng.randf_range(interval_min, interval_max)
	)


func _apply_bowl_head_bob() -> void:
	if _body == null:
		return
	var bob_phase: float = _bowl_eat_elapsed * bowl_head_bob_frequency * TAU
	_body.position = (
		_body_base_position
		- Vector3.UP * absf(sin(bob_phase)) * bowl_head_bob_height
	)


func _reset_bowl_visual() -> void:
	if _body != null:
		_body.position = _body_base_position


func _flat_distance(first: Vector3, second: Vector3) -> float:
	var difference: Vector3 = first - second
	difference.y = 0.0
	return difference.length()


func _row_time(row: Dictionary) -> float:
	return float(row.get("time", 0.0))


func _row_position(row: Dictionary) -> Vector3:
	return row.get("position", global_position) as Vector3


func _row_dwell(row: Dictionary) -> float:
	return float(row.get("dwell", 0.0))
