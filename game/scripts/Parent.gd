extends Node3D
class_name DinnerParent

## Time-indexed parent routine with investigate, found chase, and carry overrides.

signal state_changed(state_name: StringName)
signal player_caught(catch_position: Vector3)

enum State {
	ROUTINE,
	INVESTIGATE,
	FOUND,
	CARRY,
	POST_DEPOSIT_EXIT,
	POST_DEPOSIT_CLOSE_BEHIND,
	POST_DEPOSIT_HALL_WALK,
	POST_DEPOSIT_REOPEN,
	POST_DEPOSIT_PEEK,
	POST_DEPOSIT_RECLOSE,
	POST_DEPOSIT_KITCHEN,
}

@export_group("Scene References")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("NavigationAgent3D") var navigation_agent_path: NodePath = NodePath("NavigationAgent3D")
@export_node_path("MeshInstance3D") var vision_cone_path: NodePath = NodePath("VisionCone")
@export_node_path("Node3D") var crib_path: NodePath = NodePath("../Crib")
@export_node_path("Node3D") var snack_path: NodePath = NodePath("../Snack")
@export_node_path("DinnerDoor") var bedroom_door_path: NodePath = NodePath("../BedroomDoor")

@export_group("Routine")
## Zero follows GameClock.run_length. Set positive only to override/cap the routine timeline.
@export var routine_duration: float = 0.0
@export var routine_speed: float = 1.5
@export var routine_repath_distance: float = 0.05
@export var navigation_path_desired_distance: float = 0.8
@export var navigation_target_desired_distance: float = 0.02
@export var facing_turn_speed: float = 5.0
@export var routine_rows: Array[Dictionary] = [
	{
		"time": 0.0,
		"position": Vector3(-0.2, 0.7, -4.6),
		"dwell": 53.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 60.0,
		"position": Vector3(9.5, 0.7, -3.8),
		"dwell": 15.0,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
	{
		"time": 82.0,
		"position": Vector3(-0.2, 0.7, -4.6),
		"dwell": 98.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	# Phase 3: leave through the living opening, cross the middle band, and
	# enter the bathroom through its open south side.
	{
		"time": 182.8,
		"position": Vector3(0.8, 0.7, -0.8),
		"dwell": 0.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 187.5,
		"position": Vector3(-5.8, 0.7, -0.8),
		"dwell": 0.0,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
	{
		"time": 189.4,
		"position": Vector3(-5.8, 0.7, -3.5),
		"dwell": 15.0,
		"facing": Vector3(1.0, 0.0, 0.0),
	},
	{
		"time": 206.3,
		"position": Vector3(-5.8, 0.7, -0.8),
		"dwell": 0.0,
		"facing": Vector3(1.0, 0.0, 0.0),
	},
	{
		"time": 211.0,
		"position": Vector3(0.8, 0.7, -0.8),
		"dwell": 0.0,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
	{
		"time": 213.8,
		"position": Vector3(-0.2, 0.7, -4.6),
		"dwell": 26.2,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	# Phase 4: leave at exactly 240 s elapsed, cross the dining band west to
	# east, then visit the kitchen and alcove lamps before the kid-door check.
	{
		"time": 242.8,
		"position": Vector3(0.8, 0.7, -0.8),
		"dwell": 0.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 244.8,
		"position": Vector3(-2.0, 0.7, -0.8),
		"dwell": 2.0,
		"facing": Vector3(1.0, 0.0, 0.0),
	},
	{
		"time": 251.9,
		"position": Vector3(5.2, 0.7, -0.8),
		"dwell": 2.0,
		"facing": Vector3(1.0, 0.0, 0.0),
	},
	{
		"time": 258.0,
		"position": Vector3(10.5, 0.7, -3.0),
		"dwell": 5.0,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
	{
		"time": 268.9,
		"position": Vector3(8.0, 0.7, 4.8),
		"dwell": 5.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 289.3,
		"position": Vector3(-12.75, 0.7, -0.8),
		"dwell": 10.7,
		"facing": Vector3(0.0, 0.0, -1.0),
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
@export_range(10, 12, 1) var cone_raycast_count: int = 11
@export_flags_3d_physics var vision_collision_mask: int = 1

@export_group("Suspicion")
@export var suspicion_max: float = 100.0
@export var investigate_threshold: float = 50.0
@export var noise_suspicion_multiplier: float = 10.0
@export var hearing_radius: float = 8.0
@export var seen_suspicion_per_second: float = 25.0
@export var suspicion_decay_per_second: float = 5.0
@export var event_alert_threshold: float = 25.0
@export var seen_full_rate_distance: float = 4.0
@export var seen_max_multiplier_distance: float = 2.5
@export var seen_max_proximity_multiplier: float = 3.0

@export_group("Investigate")
@export var investigate_speed: float = 2.2
@export var investigate_alert_pause: float = 0.6
@export var investigate_look_duration: float = 4.0
@export var investigate_hard_timeout: float = 10.0
@export var repeat_cooldown_duration: float = 8.0
@export var repeat_cooldown_distance: float = 2.0

@export_group("Found Chase")
@export var found_speed: float = 3.8
@export var grab_distance: float = 1.1
@export var found_lose_sight_duration: float = 5.0
@export var found_escape_suspicion: float = 60.0

@export_group("Carry")
@export var carry_speed: float = 3.0
@export var carry_arrival_distance: float = 0.5
@export var carry_hard_timeout: float = 20.0
@export var carry_offset: Vector3 = Vector3(0.55, 0.35, 0.0)
@export var crib_player_offset: Vector3 = Vector3(0.0, 0.65, 0.0)

@export_group("Post Deposit")
@export var post_deposit_exit_position: Vector3 = Vector3(-12.75, 0.7, -0.8)
@export var post_deposit_exit_speed: float = 2.2
@export var post_deposit_arrival_distance: float = 0.45
@export var post_deposit_door_closed_openness: float = 0.01
@export var post_deposit_hall_direction: Vector3 = Vector3(1.0, 0.0, 0.0)
@export var post_deposit_hall_walk_distance: float = 3.5
@export var post_deposit_hall_walk_speed: float = 1.5
@export var post_deposit_reopen_openness: float = 0.35
@export var post_deposit_peek_duration: float = 1.5
@export var post_deposit_kitchen_position: Vector3 = Vector3(9.5, 0.7, -3.8)
@export var post_deposit_kitchen_speed: float = 2.2

@export_group("Readability")
@export var cone_base_color: Color = Color(0.68, 0.56, 0.92, 0.24)
@export var cone_suspicious_color: Color = Color(1.0, 0.68, 0.18, 0.34)
@export var cone_found_color: Color = Color(1.0, 0.12, 0.12, 0.45)

@export_group("B6 Runtime Verification")
@export var verify_time_scale: float = 20.0
@export var verify_physics_ticks_per_second: int = 1200
@export var verify_warmup_frames: int = 12
@export var verify_max_physics_frames: int = 12000
@export var verify_parent_duration: float = 120.0
@export var verify_pet_duration: float = 60.0
@export var verify_parent_min_displacement: float = 5.0
@export var verify_kitchen_waypoint: Vector3 = Vector3(9.5, 0.7, -3.8)
@export var verify_waypoint_tolerance: float = 1.5
@export var verify_pet_sleep_tolerance: float = 0.25
@export var verify_pet_min_displacement: float = 2.0
@export var verify_observer_parking_position: Vector3 = Vector3(-30.0, 0.6, -20.0)
@export var verify_point_blank_parent_position: Vector3 = Vector3(-0.2, 0.7, -4.6)
@export var verify_point_blank_facing: Vector3 = Vector3(-1.0, 0.0, 0.0)
@export var verify_point_blank_distance: float = 2.0
@export var verify_point_blank_duration: float = 3.0
@export var verify_point_blank_suspicion: float = 90.0

@export_group("B7 Runtime Verification")
@export var verify_carry_parent_position: Vector3 = Vector3(-11.2, 0.7, -3.0)
@export var verify_catch_offset: Vector3 = Vector3(0.5, -0.1, 0.0)
@export var verify_carry_cycle_duration: float = 40.0
@export var verify_failsafe_margin: float = 0.5
@export var verify_bark_parent_position: Vector3 = Vector3(-0.2, 0.7, -4.6)
@export var verify_bark_pet_position: Vector3 = Vector3(5.5, 0.42, -4.2)
@export var verify_bark_mask_id: String = "b7_tv_mask_at_dog_bed"
@export var verify_bark_mask_radius: float = 4.0
@export var verify_bark_mask_strength: float = 0.6
@export var verify_bark_min_mask: float = 0.5
@export var verify_bark_min_suspicion: float = 35.0

@export_group("B8 Runtime Verification")
@export var verify_b8_cycle_duration: float = 40.0
@export var verify_snack_drop_observation_duration: float = 1.0
@export var verify_snack_drop_tolerance: float = 0.25
@export var verify_snack_player_clearance: float = 1.0
@export var verify_toy_event_distance: float = 3.0
@export var verify_toy_event_loudness: float = 4.0
@export var verify_b8_kitchen_tolerance: float = 1.0
@export var verify_decay_start_suspicion: float = 10.0
@export var verify_decay_duration: float = 1.0
@export var verify_decay_tolerance: float = 0.75

var suspicion: float = 0.0

var _state: State = State.ROUTINE
var _player: DinnerPlayer
var _navigation_agent: NavigationAgent3D
var _vision_cone: MeshInstance3D
var _crib: Node3D
var _snack: DinnerSnack
var _bedroom_door: DinnerDoor
var _cone_material: StandardMaterial3D
var _navigation_ready: bool = false
var _last_navigation_target: Vector3
var _has_navigation_target: bool = false
var _sweep_time: float = 0.0
var _cone_yaw_degrees: float = 0.0
var _moved_along_path_this_frame: bool = false
var _heard_since_last_tick: bool = false
var _last_known_position: Vector3
var _investigate_elapsed: float = 0.0
var _investigate_look_elapsed: float = 0.0
var _found_no_sight_elapsed: float = 0.0
var _repeat_cooldown_remaining: float = 0.0
var _last_checked_position: Vector3
var _has_checked_position: bool = false
var _carry_elapsed: float = 0.0
var _carry_path_started: bool = false
var _post_deposit_elapsed: float = 0.0
var _post_deposit_path_started: bool = false
var _verify_b8_door_creak_heard: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_navigation_agent = get_node_or_null(navigation_agent_path) as NavigationAgent3D
	_vision_cone = get_node_or_null(vision_cone_path) as MeshInstance3D
	_crib = get_node_or_null(crib_path) as Node3D
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_bedroom_door = get_node_or_null(bedroom_door_path) as DinnerDoor
	_setup_cone()
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)
	_finish_navigation_setup.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b6"):
		_run_b6_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b7"):
		_run_b7_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b8"):
		_run_b8_live_verification.call_deferred()


func _physics_process(delta: float) -> void:
	_repeat_cooldown_remaining = maxf(_repeat_cooldown_remaining - delta, 0.0)
	_moved_along_path_this_frame = false
	_update_perception(delta)

	match _state:
		State.ROUTINE:
			_update_routine(delta)
		State.INVESTIGATE:
			_update_investigate(delta)
		State.FOUND:
			_update_found(delta)
		State.CARRY:
			_update_carry(delta)
		State.POST_DEPOSIT_EXIT:
			_update_post_deposit_exit(delta)
		State.POST_DEPOSIT_CLOSE_BEHIND:
			_update_post_deposit_close_behind()
		State.POST_DEPOSIT_HALL_WALK:
			_update_post_deposit_hall_walk(delta)
		State.POST_DEPOSIT_REOPEN:
			_update_post_deposit_reopen(delta)
		State.POST_DEPOSIT_PEEK:
			_update_post_deposit_peek(delta)
		State.POST_DEPOSIT_RECLOSE:
			_update_post_deposit_reclose()
		State.POST_DEPOSIT_KITCHEN:
			_update_post_deposit_kitchen(delta)

	_update_sweep(delta)
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


func _set_state(next_state: State) -> void:
	if _state == next_state:
		return
	_state = next_state
	state_changed.emit(get_state_name())


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
	_carry_elapsed += delta
	if _carry_elapsed >= carry_hard_timeout:
		_finish_carry()
		return
	if _crib == null or _player == null:
		_finish_carry()
		return
	if not _can_query_navigation():
		return
	_set_navigation_target(_crib.global_position)
	_move_along_path(carry_speed, delta)
	if not _navigation_agent.is_navigation_finished():
		_carry_path_started = true
	if not _carry_path_started:
		return
	var reachable_crib_position: Vector3 = _navigation_agent.get_final_position()
	var arrival_delta: Vector3 = reachable_crib_position - global_position
	arrival_delta.y = 0.0
	if (
		arrival_delta.length() <= carry_arrival_distance
		or _navigation_agent.is_navigation_finished()
	):
		_finish_carry()


func _update_post_deposit_exit(delta: float) -> void:
	_set_navigation_target(post_deposit_exit_position)
	_move_along_path(post_deposit_exit_speed, delta)
	if not _navigation_agent.is_navigation_finished():
		_post_deposit_path_started = true
	if not _post_deposit_path_started:
		return
	if _has_reached_post_deposit_target(post_deposit_exit_position):
		_set_state(State.POST_DEPOSIT_CLOSE_BEHIND)


func _update_post_deposit_close_behind() -> void:
	if _bedroom_door != null:
		_bedroom_door.close_immediately()
	_post_deposit_path_started = false
	var hall_target: Vector3 = _get_post_deposit_hall_target()
	_set_navigation_target(hall_target, true)
	_set_state(State.POST_DEPOSIT_HALL_WALK)


func _update_post_deposit_hall_walk(delta: float) -> void:
	var hall_target: Vector3 = _get_post_deposit_hall_target()
	_set_navigation_target(hall_target)
	_move_along_path(post_deposit_hall_walk_speed, delta)
	if not _navigation_agent.is_navigation_finished():
		_post_deposit_path_started = true
	if not _post_deposit_path_started:
		return
	if _has_reached_post_deposit_target(hall_target):
		_post_deposit_elapsed = 0.0
		_set_state(State.POST_DEPOSIT_REOPEN)
		if _bedroom_door != null:
			_bedroom_door.open_to(post_deposit_reopen_openness)


func _update_post_deposit_reopen(delta: float) -> void:
	_face_bedroom_door(delta)
	if (
		_bedroom_door == null
		or (
			_bedroom_door.openness >= post_deposit_reopen_openness
			and not _bedroom_door.is_opening_to_target()
		)
	):
		_post_deposit_elapsed = 0.0
		_set_state(State.POST_DEPOSIT_PEEK)


func _update_post_deposit_peek(delta: float) -> void:
	_post_deposit_elapsed += delta
	_face_bedroom_door(delta)
	if _post_deposit_elapsed >= post_deposit_peek_duration:
		_set_state(State.POST_DEPOSIT_RECLOSE)


func _update_post_deposit_reclose() -> void:
	if _bedroom_door != null:
		_bedroom_door.close_immediately()
	_post_deposit_path_started = false
	_set_navigation_target(post_deposit_kitchen_position, true)
	_set_state(State.POST_DEPOSIT_KITCHEN)


func _update_post_deposit_kitchen(delta: float) -> void:
	_set_navigation_target(post_deposit_kitchen_position)
	_move_along_path(post_deposit_kitchen_speed, delta)
	if not _navigation_agent.is_navigation_finished():
		_post_deposit_path_started = true
	if not _post_deposit_path_started:
		return
	if _has_reached_post_deposit_target(post_deposit_kitchen_position):
		_resume_routine_after_deposit()


func _has_reached_post_deposit_target(target: Vector3) -> bool:
	var arrival_delta: Vector3 = target - global_position
	arrival_delta.y = 0.0
	return (
		arrival_delta.length() <= post_deposit_arrival_distance
		or _navigation_agent.is_navigation_finished()
	)


func _get_post_deposit_hall_target() -> Vector3:
	var hall_direction: Vector3 = post_deposit_hall_direction
	hall_direction.y = 0.0
	if hall_direction.length_squared() <= 0.0:
		return post_deposit_exit_position
	return (
		post_deposit_exit_position
		+ hall_direction.normalized() * post_deposit_hall_walk_distance
	)


func _face_bedroom_door(delta: float) -> void:
	if _bedroom_door == null:
		return
	_face_direction(_bedroom_door.global_position - global_position, delta)


func _update_found(delta: float) -> void:
	if _player == null:
		_escape_found()
		return
	if global_position.distance_to(_player.global_position) <= grab_distance:
		_begin_carry()
		return

	if _has_clear_line_of_sight():
		_last_known_position = _player.global_position
		_found_no_sight_elapsed = 0.0
	else:
		_found_no_sight_elapsed += delta
		if _found_no_sight_elapsed >= found_lose_sight_duration:
			_escape_found()
			return

	_set_navigation_target(_player.global_position)
	if _can_query_navigation():
		if not _move_along_path(found_speed, delta):
			_face_direction(_player.global_position - global_position, delta)


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
	_moved_along_path_this_frame = movement_distance > 0.0
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
	if (
		_state == State.FOUND
		or _state == State.CARRY
		or _is_post_deposit_state()
		or _player == null
	):
		return

	var sees_player: bool = _can_see_player()
	if sees_player:
		_last_known_position = _player.global_position
		suspicion += seen_suspicion_per_second * _get_seen_rate_multiplier() * delta
		if suspicion >= suspicion_max:
			_begin_found_or_carry()
		elif suspicion >= investigate_threshold:
			_begin_or_update_investigate(_last_known_position)
	elif not _heard_since_last_tick:
		suspicion -= suspicion_decay_per_second * delta
	suspicion = clampf(suspicion, 0.0, suspicion_max)


func _get_seen_rate_multiplier() -> float:
	if _player == null:
		return 1.0
	var distance_to_player: float = global_position.distance_to(_player.global_position)
	if distance_to_player >= seen_full_rate_distance:
		return 1.0
	if distance_to_player <= seen_max_multiplier_distance:
		return maxf(seen_max_proximity_multiplier, 1.0)
	var distance_span: float = seen_full_rate_distance - seen_max_multiplier_distance
	if distance_span <= 0.0:
		return maxf(seen_max_proximity_multiplier, 1.0)
	var proximity_weight: float = (
		seen_full_rate_distance - distance_to_player
	) / distance_span
	return lerpf(1.0, maxf(seen_max_proximity_multiplier, 1.0), proximity_weight)


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
	if source == self or _state == State.CARRY or _is_post_deposit_state():
		return
	var distance_to_noise: float = global_position.distance_to(pos)
	if distance_to_noise >= hearing_radius:
		return
	var falloff: float = 1.0 - distance_to_noise / hearing_radius
	var event_contribution: float = loudness * noise_suspicion_multiplier * falloff
	if source is DinnerPet:
		event_contribution = maxf(event_contribution, event_alert_threshold)
	suspicion = clampf(
		suspicion + event_contribution,
		0.0,
		suspicion_max
	)
	_heard_since_last_tick = true
	_last_known_position = pos
	if _state == State.FOUND:
		return
	if suspicion >= suspicion_max:
		_begin_found_or_carry()
	elif event_contribution >= event_alert_threshold:
		_begin_or_update_investigate(pos, true)
	elif suspicion >= investigate_threshold:
		_begin_or_update_investigate(pos)


func _is_post_deposit_state() -> bool:
	return (
		_state == State.POST_DEPOSIT_EXIT
		or _state == State.POST_DEPOSIT_CLOSE_BEHIND
		or _state == State.POST_DEPOSIT_HALL_WALK
		or _state == State.POST_DEPOSIT_REOPEN
		or _state == State.POST_DEPOSIT_PEEK
		or _state == State.POST_DEPOSIT_RECLOSE
		or _state == State.POST_DEPOSIT_KITCHEN
	)


func _begin_or_update_investigate(
	target: Vector3,
	ignore_repeat_cooldown: bool = false
) -> void:
	if not ignore_repeat_cooldown and _is_repeat_target_suppressed(target):
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


func _begin_found_or_carry() -> void:
	if _player == null:
		return
	if global_position.distance_to(_player.global_position) <= grab_distance:
		_begin_carry()
	else:
		_begin_found()


func _begin_found() -> void:
	if _player == null or _state == State.CARRY:
		return
	suspicion = suspicion_max
	_last_known_position = _player.global_position
	_found_no_sight_elapsed = 0.0
	_state = State.FOUND
	_set_navigation_target(_player.global_position, true)
	state_changed.emit(get_state_name())


func _escape_found() -> void:
	suspicion = clampf(found_escape_suspicion, 0.0, suspicion_max)
	_state = State.INVESTIGATE
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_set_navigation_target(_last_known_position, true)
	state_changed.emit(get_state_name())


func _begin_carry() -> void:
	if _state == State.CARRY or _player == null:
		return
	if global_position.distance_to(_player.global_position) > grab_distance:
		return
	var catch_position: Vector3 = _player.global_position
	if _player.carrying_snack:
		if _snack != null:
			_snack.drop_at(catch_position)
		else:
			_player.set_carrying_snack(false)
	_player.attach_to_carrier(self, carry_offset)
	suspicion = 0.0
	_carry_elapsed = 0.0
	_carry_path_started = false
	_set_state(State.CARRY)
	if _crib != null:
		_set_navigation_target(_crib.global_position, true)
	player_caught.emit(catch_position)


func _finish_carry() -> void:
	if _player != null:
		var player_drop_position: Vector3 = global_position
		if _crib != null:
			player_drop_position = _crib.global_position + crib_player_offset
		_player.detach_from_carrier(player_drop_position)
	_post_deposit_elapsed = 0.0
	_post_deposit_path_started = false
	_set_state(State.POST_DEPOSIT_EXIT)
	_set_navigation_target(post_deposit_exit_position, true)


func _resume_routine_after_deposit() -> void:
	_set_state(State.ROUTINE)
	_set_navigation_target(get_base_target(_get_routine_time()), true)


func _get_routine_time() -> float:
	var clock_duration: float = GameClock.run_length
	var timeline_duration: float = routine_duration if routine_duration > 0.0 else clock_duration
	var elapsed: float = clock_duration - GameClock.time_remaining
	return clampf(elapsed, 0.0, timeline_duration)


func _update_sweep(delta: float) -> void:
	if (
		_state != State.ROUTINE
		or not _moved_along_path_this_frame
		or sweep_period_seconds <= 0.0
	):
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
	_build_cone_mesh(cone_angle)
	var suspicion_weight: float = clampf(suspicion / suspicion_max, 0.0, 1.0)
	if _state == State.FOUND or _state == State.CARRY:
		_cone_material.albedo_color = cone_found_color
	else:
		_cone_material.albedo_color = cone_base_color.lerp(cone_suspicious_color, suspicion_weight)


func _get_current_cone_angle() -> float:
	match _state:
		State.INVESTIGATE:
			return investigate_cone_angle_degrees
		State.FOUND:
			return found_cone_angle_degrees
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
	var ray_count: int = maxi(cone_raycast_count, 2)
	var half_angle_radians: float = deg_to_rad(cone_angle_degrees * 0.5)
	var ray_points: Array[Vector3] = []
	for ray_index in range(ray_count):
		var ray_weight: float = float(ray_index) / float(ray_count - 1)
		var ray_angle: float = lerpf(-half_angle_radians, half_angle_radians, ray_weight)
		var local_direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, ray_angle)
		var world_direction: Vector3 = _vision_cone.global_transform.basis * local_direction
		world_direction.y = 0.0
		world_direction = world_direction.normalized()
		var clipped_distance: float = _get_static_hit_distance(world_direction)
		ray_points.append(local_direction * clipped_distance)

	var cone_mesh: ImmediateMesh = ImmediateMesh.new()
	cone_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _cone_material)
	for point_index in range(ray_points.size() - 1):
		cone_mesh.surface_add_vertex(Vector3.ZERO)
		cone_mesh.surface_add_vertex(ray_points[point_index])
		cone_mesh.surface_add_vertex(ray_points[point_index + 1])
	cone_mesh.surface_end()
	_vision_cone.mesh = cone_mesh


func _get_static_hit_distance(world_direction: Vector3) -> float:
	var ray_start: Vector3 = global_position + Vector3.UP * eye_height
	var ray_end: Vector3 = ray_start + world_direction * vision_range
	var excluded_rids: Array[RID] = []
	if _player is CollisionObject3D:
		excluded_rids.append((_player as CollisionObject3D).get_rid())

	while true:
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			ray_start, ray_end, vision_collision_mask
		)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.exclude = excluded_rids
		var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		if result.is_empty():
			return vision_range

		var collider: Object = result.get("collider") as Object
		if collider is StaticBody3D:
			var hit_position: Vector3 = result.get("position", ray_end) as Vector3
			return minf(ray_start.distance_to(hit_position), vision_range)
		if collider is CollisionObject3D:
			var collider_rid: RID = (collider as CollisionObject3D).get_rid()
			if excluded_rids.has(collider_rid):
				return vision_range
			excluded_rids.append(collider_rid)
			continue
		return vision_range
	return vision_range


func _face_direction(direction: Vector3, delta: float) -> void:
	var flat_direction: Vector3 = direction
	flat_direction.y = 0.0
	if flat_direction.length_squared() <= 0.0:
		return
	var target_yaw: float = atan2(-flat_direction.x, -flat_direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, clampf(facing_turn_speed * delta, 0.0, 1.0))


func _run_b6_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = _player != null and _player.is_physics_processing()
	var parent_start: Vector3 = global_position
	var pet_start: Vector3 = pet.global_position if pet != null else Vector3.ZERO
	var parent_max_displacement: float = 0.0
	var kitchen_min_distance: float = INF
	var pet_sleep_max_displacement: float = 0.0
	var pet_max_displacement: float = 0.0
	var reached_parent_duration: bool = false

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	if _player != null:
		_player.set_input_locked(true)
		_player.set_physics_process(false)
		_player.global_position = verify_observer_parking_position

	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	GameClock.start()
	for _frame_index in range(verify_max_physics_frames):
		await get_tree().physics_frame
		var clock_elapsed: float = GameClock.run_length - GameClock.time_remaining
		parent_max_displacement = maxf(
			parent_max_displacement,
			parent_start.distance_to(global_position)
		)
		kitchen_min_distance = minf(
			kitchen_min_distance,
			global_position.distance_to(verify_kitchen_waypoint)
		)
		if pet != null and clock_elapsed <= verify_pet_duration:
			var pet_displacement: float = pet_start.distance_to(pet.global_position)
			pet_max_displacement = maxf(pet_max_displacement, pet_displacement)
			if clock_elapsed <= pet.initial_sleep_duration:
				pet_sleep_max_displacement = maxf(
					pet_sleep_max_displacement,
					pet_displacement
				)
		if clock_elapsed >= verify_parent_duration:
			reached_parent_duration = true
			break

	var point_blank_lit: bool = false
	var point_blank_triggered: bool = false
	var point_blank_max_suspicion: float = 0.0
	var reached_point_blank_duration: bool = false
	if _player != null:
		_prepare_point_blank_verification()
		GameClock.start()
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			var clock_elapsed: float = GameClock.run_length - GameClock.time_remaining
			var brightness: float = LightSystem.get_brightness_at(_player.global_position)
			point_blank_lit = point_blank_lit or brightness > brightness_threshold
			point_blank_max_suspicion = maxf(point_blank_max_suspicion, suspicion)
			point_blank_triggered = (
				point_blank_triggered
				or suspicion >= verify_point_blank_suspicion
				or _state == State.FOUND
			)
			if clock_elapsed >= verify_point_blank_duration:
				reached_point_blank_duration = true
				break

	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		_player.set_physics_process(player_was_processing)

	var parent_moved: bool = parent_max_displacement >= verify_parent_min_displacement
	var reached_kitchen: bool = kitchen_min_distance <= verify_waypoint_tolerance
	var pet_slept: bool = (
		pet != null
		and pet_sleep_max_displacement <= verify_pet_sleep_tolerance
	)
	var pet_patrolled: bool = (
		pet != null
		and pet_max_displacement >= verify_pet_min_displacement
	)
	var verification_passed: bool = (
		reached_parent_duration
		and parent_moved
		and reached_kitchen
		and pet_slept
		and pet_patrolled
		and reached_point_blank_duration
		and point_blank_lit
		and point_blank_triggered
	)
	print(
		(
			"B6 live metrics: parent displacement=%.2f m, kitchen closest=%.2f m, "
			+ "pet sleep drift=%.2f m, pet displacement=%.2f m, "
			+ "point-blank max suspicion=%.1f."
		)
		% [
			parent_max_displacement,
			kitchen_min_distance,
			pet_sleep_max_displacement,
			pet_max_displacement,
			point_blank_max_suspicion,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(reached_parent_duration, "B6 clock did not tick through the 120 s routine check.")
	assert(parent_moved, "B6 parent stayed immobile during the live routine check.")
	assert(reached_kitchen, "B6 parent never reached the kitchen waypoint.")
	assert(pet_slept, "B6 pet moved during its initial sleep window.")
	assert(pet_patrolled, "B6 pet did not patrol after waking.")
	assert(reached_point_blank_duration, "B6 clock did not tick through the 3 s detection check.")
	assert(point_blank_lit, "B6 planted player was not observably lit.")
	assert(point_blank_triggered, "B6 point-blank player did not reach 90 suspicion or FOUND.")
	print("B6 live SceneTree verification passed.")


func _run_b7_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = _player != null and _player.is_physics_processing()

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	var catch_started: bool = false
	var saw_post_exit: bool = false
	var saw_door_close: bool = false
	var saw_hall_wait: bool = false
	var saw_peek: bool = false
	var carry_cycle_completed: bool = false
	var carry_cycle_elapsed: float = 0.0
	if _player != null and _crib != null and _bedroom_door != null:
		_player.set_physics_process(true)
		_bedroom_door.openness = 1.0
		global_position = verify_carry_parent_position
		_state = State.ROUTINE
		suspicion = 0.0
		_set_navigation_target(global_position, true)
		var catch_position: Vector3 = global_position + verify_catch_offset
		_player.detach_from_carrier(catch_position)
		_begin_found_or_carry()
		catch_started = (
			_state == State.CARRY
			and _player.is_attached_to_carrier()
			and _player.input_locked
		)

		GameClock.start()
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			carry_cycle_elapsed = GameClock.run_length - GameClock.time_remaining
			saw_post_exit = saw_post_exit or _state == State.POST_DEPOSIT_EXIT
			saw_door_close = (
				saw_door_close
				or _state == State.POST_DEPOSIT_CLOSE_BEHIND
				or _state == State.POST_DEPOSIT_RECLOSE
			)
			saw_hall_wait = saw_hall_wait or _state == State.POST_DEPOSIT_HALL_WALK
			saw_peek = saw_peek or _state == State.POST_DEPOSIT_PEEK
			if _state == State.ROUTINE:
				carry_cycle_completed = true
				break
			if carry_cycle_elapsed >= verify_carry_cycle_duration:
				break

	var player_released: bool = (
		_player != null
		and not _player.is_attached_to_carrier()
		and not _player.input_locked
	)
	var bedroom_door_closed: bool = (
		_bedroom_door != null
		and _bedroom_door.openness <= post_deposit_door_closed_openness
	)

	var failsafe_started: bool = false
	var failsafe_released: bool = false
	var failsafe_elapsed: float = 0.0
	if _player != null:
		global_position = verify_carry_parent_position
		_state = State.ROUTINE
		suspicion = 0.0
		_navigation_ready = false
		var failsafe_catch_position: Vector3 = global_position + verify_catch_offset
		_player.detach_from_carrier(failsafe_catch_position)
		_begin_found_or_carry()
		failsafe_started = _state == State.CARRY and _player.is_attached_to_carrier()

		GameClock.start()
		var failsafe_test_duration: float = carry_hard_timeout + verify_failsafe_margin
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			failsafe_elapsed = GameClock.run_length - GameClock.time_remaining
			if not _player.is_attached_to_carrier() and not _player.input_locked:
				failsafe_released = true
				break
			if failsafe_elapsed >= failsafe_test_duration:
				break
		_navigation_ready = true

	var tv_mask_active: bool = false
	var bark_alarm_triggered: bool = false
	var bark_max_suspicion: float = 0.0
	if pet != null and _player != null:
		_player.set_physics_process(false)
		_player.detach_from_carrier(verify_observer_parking_position)
		global_position = verify_bark_parent_position
		_state = State.ROUTINE
		suspicion = 0.0
		_has_checked_position = false
		_repeat_cooldown_remaining = 0.0
		_set_navigation_target(global_position, true)
		pet.global_position = verify_bark_pet_position
		GameClock.start()
		NoiseSystem.register_ambient_source(
			verify_bark_mask_id,
			verify_bark_pet_position,
			verify_bark_mask_radius,
			verify_bark_mask_strength
		)
		tv_mask_active = (
			NoiseSystem.get_mask_at(verify_bark_pet_position) >= verify_bark_min_mask
		)
		pet.bark()
		bark_max_suspicion = suspicion
		await get_tree().physics_frame
		bark_max_suspicion = maxf(bark_max_suspicion, suspicion)
		bark_alarm_triggered = (
			bark_max_suspicion >= verify_bark_min_suspicion
			or _state == State.INVESTIGATE
		)
		NoiseSystem.unregister_ambient_source(verify_bark_mask_id)

	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		_player.set_physics_process(player_was_processing)

	var verification_passed: bool = (
		catch_started
		and carry_cycle_completed
		and carry_cycle_elapsed <= verify_carry_cycle_duration
		and player_released
		and bedroom_door_closed
		and saw_post_exit
		and saw_door_close
		and saw_hall_wait
		and saw_peek
		and failsafe_started
		and failsafe_released
		and tv_mask_active
		and bark_alarm_triggered
	)
	print(
		(
			"B7 live metrics: carry cycle=%.2f s, door openness=%.3f, "
			+ "failsafe release=%.2f s, bark suspicion=%.1f."
		)
		% [
			carry_cycle_elapsed,
			_bedroom_door.openness if _bedroom_door != null else -1.0,
			failsafe_elapsed,
			bark_max_suspicion,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(catch_started, "B7 catch did not attach and lock the player.")
	assert(carry_cycle_completed, "B7 parent did not complete the capture epilogue.")
	assert(player_released, "B7 deposit did not detach and unlock the player.")
	assert(bedroom_door_closed, "B7 post-deposit sequence did not close the bedroom door.")
	assert(saw_post_exit and saw_door_close, "B7 parent skipped the exit or door-close beat.")
	assert(saw_hall_wait and saw_peek, "B7 parent skipped the hall walk or peek beat.")
	assert(failsafe_started and failsafe_released, "B7 20 s carry failsafe did not release.")
	assert(tv_mask_active, "B7 TV mask was not active during the bark check.")
	assert(bark_alarm_triggered, "B7 unmasked bark did not trigger alarm investigation.")
	print("B7 live SceneTree verification passed.")


func _run_b8_live_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var flow: DinnerGameFlow = get_parent().get_node_or_null("GameFlow") as DinnerGameFlow
	var snack_visual: Node3D = (
		_snack.get_node_or_null("Visual") as Node3D
		if _snack != null
		else null
	)
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = _player != null and _player.is_physics_processing()

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	var catch_started: bool = false
	var catch_position: Vector3 = Vector3.ZERO
	var snack_drop_observed: bool = false
	var snack_dropped_at_catch: bool = false
	var snack_visual_detached: bool = false
	var snack_player_clearance: float = 0.0
	var player_released: bool = false
	var deposit_did_not_win: bool = false
	var epilogue_completed: bool = false
	var saw_close_behind: bool = false
	var saw_hall_walk: bool = false
	var saw_reopen: bool = false
	var saw_peek: bool = false
	var saw_reclose: bool = false
	var saw_kitchen_walk: bool = false
	var door_max_reopen_openness: float = 0.0
	var kitchen_min_distance: float = INF
	var capture_elapsed: float = 0.0

	if (
		_player != null
		and _snack != null
		and _crib != null
		and _bedroom_door != null
		and flow != null
	):
		_player.set_physics_process(true)
		_bedroom_door.openness = 1.0
		global_position = verify_carry_parent_position
		_state = State.ROUTINE
		suspicion = 0.0
		_set_navigation_target(global_position, true)
		catch_position = global_position + verify_catch_offset
		_player.detach_from_carrier(catch_position)
		_snack.reveal_at(catch_position)
		_snack.pick_up(_player)
		flow.state = DinnerGameFlow.State.PLAYING
		GameClock.start()
		_verify_b8_door_creak_heard = false
		if not NoiseSystem.noise_emitted.is_connected(_capture_b8_noise):
			NoiseSystem.noise_emitted.connect(_capture_b8_noise)
		_begin_found_or_carry()
		catch_started = (
			_state == State.CARRY
			and _player.is_attached_to_carrier()
			and _player.input_locked
		)

		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			capture_elapsed = GameClock.run_length - GameClock.time_remaining
			if (
				not snack_drop_observed
				and capture_elapsed >= verify_snack_drop_observation_duration
			):
				snack_drop_observed = true
				snack_dropped_at_catch = (
					not _player.carrying_snack
					and _snack.carried_by == null
					and _snack.available_for_pickup
					and _flat_distance(_snack.global_position, catch_position)
					<= verify_snack_drop_tolerance
				)
				snack_visual_detached = (
					snack_visual != null
					and snack_visual.visible
					and _flat_distance(snack_visual.global_position, catch_position)
					<= verify_snack_drop_tolerance
					and _flat_distance(_player.global_position, catch_position)
					>= verify_snack_player_clearance
				)
				snack_player_clearance = _flat_distance(
					_player.global_position,
					catch_position
				)

			if not _player.is_attached_to_carrier() and not _player.input_locked:
				player_released = true
				deposit_did_not_win = flow.state == DinnerGameFlow.State.PLAYING

			saw_close_behind = (
				saw_close_behind or _state == State.POST_DEPOSIT_CLOSE_BEHIND
			)
			saw_hall_walk = (
				saw_hall_walk or _state == State.POST_DEPOSIT_HALL_WALK
			)
			saw_reopen = saw_reopen or _state == State.POST_DEPOSIT_REOPEN
			saw_peek = saw_peek or _state == State.POST_DEPOSIT_PEEK
			saw_reclose = saw_reclose or _state == State.POST_DEPOSIT_RECLOSE
			saw_kitchen_walk = (
				saw_kitchen_walk or _state == State.POST_DEPOSIT_KITCHEN
			)
			if _state == State.POST_DEPOSIT_REOPEN or _state == State.POST_DEPOSIT_PEEK:
				door_max_reopen_openness = maxf(
					door_max_reopen_openness,
					_bedroom_door.openness
				)
			if _state == State.POST_DEPOSIT_KITCHEN:
				kitchen_min_distance = minf(
					kitchen_min_distance,
					global_position.distance_to(post_deposit_kitchen_position)
				)
			if _state == State.ROUTINE:
				epilogue_completed = true
				break
			if capture_elapsed >= verify_b8_cycle_duration:
				break

	if NoiseSystem.noise_emitted.is_connected(_capture_b8_noise):
		NoiseSystem.noise_emitted.disconnect(_capture_b8_noise)

	var bedroom_door_closed: bool = (
		_bedroom_door != null
		and _bedroom_door.openness <= post_deposit_door_closed_openness
	)
	var reached_kitchen: bool = kitchen_min_distance <= verify_b8_kitchen_tolerance
	var run_continued: bool = (
		flow != null
		and flow.state == DinnerGameFlow.State.PLAYING
		and GameClock.running
	)

	var dog_bark_investigated: bool = false
	var dog_bark_suspicion: float = 0.0
	if pet != null and _player != null:
		_player.set_physics_process(false)
		_player.detach_from_carrier(verify_observer_parking_position)
		global_position = verify_bark_parent_position
		_state = State.ROUTINE
		suspicion = 0.0
		_has_checked_position = false
		_repeat_cooldown_remaining = 0.0
		_set_navigation_target(global_position, true)
		pet.global_position = verify_bark_pet_position
		GameClock.start()
		NoiseSystem.register_ambient_source(
			verify_bark_mask_id,
			verify_bark_pet_position,
			verify_bark_mask_radius,
			verify_bark_mask_strength
		)
		pet.bark()
		dog_bark_suspicion = suspicion
		dog_bark_investigated = _state == State.INVESTIGATE
		NoiseSystem.unregister_ambient_source(verify_bark_mask_id)

	var toy_investigated: bool = false
	var toy_suspicion: float = 0.0
	var toy_position: Vector3 = Vector3.ZERO
	if _player != null:
		global_position = Vector3(0.0, verify_carry_parent_position.y, 0.0)
		_state = State.ROUTINE
		suspicion = 0.0
		_has_checked_position = false
		_repeat_cooldown_remaining = 0.0
		_set_navigation_target(global_position, true)
		toy_position = global_position + Vector3.RIGHT * verify_toy_event_distance
		NoiseSystem.emit_noise(toy_position, verify_toy_event_loudness, _player)
		toy_suspicion = suspicion
		toy_investigated = (
			_state == State.INVESTIGATE
			and _last_known_position.distance_to(toy_position)
			<= routine_repath_distance
		)

	var decay_observed: bool = false
	var decayed_suspicion: float = suspicion
	if _player != null:
		_player.global_position = verify_observer_parking_position
		_state = State.ROUTINE
		suspicion = verify_decay_start_suspicion
		GameClock.start()
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			var decay_elapsed: float = GameClock.run_length - GameClock.time_remaining
			if decay_elapsed >= verify_decay_duration:
				break
		decayed_suspicion = suspicion
		var expected_decay_suspicion: float = maxf(
			verify_decay_start_suspicion
			- suspicion_decay_per_second * verify_decay_duration,
			0.0
		)
		decay_observed = (
			absf(decayed_suspicion - expected_decay_suspicion)
			<= verify_decay_tolerance
		)

	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		_player.set_physics_process(player_was_processing)

	var verification_passed: bool = (
		catch_started
		and snack_drop_observed
		and snack_dropped_at_catch
		and snack_visual_detached
		and player_released
		and deposit_did_not_win
		and run_continued
		and epilogue_completed
		and saw_close_behind
		and saw_hall_walk
		and saw_reopen
		and saw_peek
		and saw_reclose
		and saw_kitchen_walk
		and bedroom_door_closed
		and reached_kitchen
		and _verify_b8_door_creak_heard
		and door_max_reopen_openness >= post_deposit_reopen_openness
		and dog_bark_investigated
		and toy_investigated
		and decay_observed
	)
	print(
		(
			"B8 live metrics: capture=%.2f s, snack/player clearance=%.2f m, "
			+ "door peak=%.2f, kitchen closest=%.2f m, "
			+ "bark/toy/decayed suspicion=%.1f/%.1f/%.1f."
		)
		% [
			capture_elapsed,
			snack_player_clearance,
			door_max_reopen_openness,
			kitchen_min_distance,
			dog_bark_suspicion,
			toy_suspicion,
			decayed_suspicion,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(catch_started, "B8 catch did not begin from a snack-carrying player.")
	assert(snack_dropped_at_catch, "B8 catch did not clear and drop the snack.")
	assert(snack_visual_detached, "B8 snack presenter followed the carried player.")
	assert(player_released, "B8 crib deposit did not release the player.")
	assert(deposit_did_not_win and run_continued, "B8 snackless deposit ended the run.")
	assert(epilogue_completed, "B8 capture epilogue did not resume routine.")
	assert(
		saw_close_behind and saw_hall_walk and saw_reopen and saw_peek,
		"B8 capture epilogue skipped its first four directed beats."
	)
	assert(
		saw_reclose and saw_kitchen_walk and bedroom_door_closed and reached_kitchen,
		"B8 capture epilogue skipped reclose or kitchen."
	)
	assert(_verify_b8_door_creak_heard, "B8 slow peek-open emitted no door creak.")
	assert(dog_bark_investigated, "B8 dog bark did not immediately investigate.")
	assert(toy_investigated, "B8 nearby toy event did not immediately investigate.")
	assert(decay_observed, "B8 suspicion did not decay at 5 points per second.")
	print("B8 live SceneTree verification passed.")


func _capture_b8_noise(_pos: Vector3, loudness: float, source: Node) -> void:
	if source == _bedroom_door and loudness > 0.0:
		_verify_b8_door_creak_heard = true


func _flat_distance(first: Vector3, second: Vector3) -> float:
	var difference: Vector3 = first - second
	difference.y = 0.0
	return difference.length()


func _prepare_point_blank_verification() -> void:
	suspicion = 0.0
	_state = State.ROUTINE
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_found_no_sight_elapsed = 0.0
	_repeat_cooldown_remaining = 0.0
	_has_checked_position = false
	global_position = verify_point_blank_parent_position
	var facing: Vector3 = verify_point_blank_facing
	facing.y = 0.0
	facing = facing.normalized() if facing.length_squared() > 0.0 else Vector3.FORWARD
	rotation.y = atan2(-facing.x, -facing.z)
	_cone_yaw_degrees = 0.0
	_set_navigation_target(global_position, true)
	var player_position: Vector3 = global_position + facing * verify_point_blank_distance
	player_position.y = verify_observer_parking_position.y
	_player.global_position = player_position
	for zone: String in LightSystem.VALID_ZONES:
		LightSystem.set_zone_enabled(zone, true)


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
