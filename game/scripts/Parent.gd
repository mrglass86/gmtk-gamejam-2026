extends Node3D
class_name DinnerParent

## Time-indexed parent routine with investigate, found chase, and carry overrides.

signal state_changed(state_name: StringName)
signal curiosity_started(sound_position: Vector3)
signal player_caught(catch_position: Vector3, had_snack: bool)
signal player_deposited()
signal light_anomaly_started(switch_id: StringName)
signal light_anomaly_restored(switch_id: StringName, expected_on: bool)
signal epilogue_room_check_started()
signal epilogue_kid_protest()

enum State {
	ROUTINE,
	CURIOUS,
	INVESTIGATE,
	HUNT,
	FOUND,
	CARRY,
	POST_DEPOSIT_EXIT,
	POST_DEPOSIT_CLOSE_BEHIND,
	POST_DEPOSIT_HALL_WALK,
	POST_DEPOSIT_REOPEN,
	POST_DEPOSIT_PEEK,
	POST_DEPOSIT_RECLOSE,
	POST_DEPOSIT_KITCHEN,
	POST_DEPOSIT_ROOM_ENTER,
	POST_DEPOSIT_ROOM_DWELL,
	POST_DEPOSIT_ROOM_EXIT,
}

@export_group("Scene References")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("NavigationAgent3D") var navigation_agent_path: NodePath = NodePath("NavigationAgent3D")
@export_node_path("MeshInstance3D") var vision_cone_path: NodePath = NodePath("VisionCone")
@export_node_path("Node3D") var crib_path: NodePath = NodePath("../Crib")
@export_node_path("Node3D") var snack_path: NodePath = NodePath("../Snack")
@export_node_path("DinnerDoor") var bedroom_door_path: NodePath = NodePath("../BedroomDoor")
@export_node_path("DinnerDoor") var bathroom_door_path: NodePath = NodePath("../Level/BathroomDoor")
@export_node_path("Node3D") var level_path: NodePath = NodePath("../Level")
@export_node_path("DinnerWorldSwitch") var kid_hall_switch_path: NodePath = NodePath(
	"../Level/KidHallSwitch"
)

@export_group("Routine")
## Zero follows GameClock.run_length. Set positive only to override/cap the routine timeline.
@export var routine_duration: float = 0.0
@export var routine_speed: float = 1.5
@export var routine_repath_distance: float = 0.05
@export var navigation_path_desired_distance: float = 0.8
@export var navigation_target_desired_distance: float = 0.02
@export var facing_turn_speed: float = 5.0
@export var routine_door_arrival_distance: float = 0.75
@export_range(0.35, 1.0) var bathroom_door_open_openness: float = 0.7
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
		"door": &"bathroom",
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
		"dwell": 0.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 271.1,
		"position": Vector3(5.0, 0.7, 4.8),
		"dwell": 1.0,
		"facing": Vector3(1.0, 0.0, 0.0),
	},
	{
		"time": 273.5,
		"position": Vector3(5.8, 0.7, 3.0),
		"dwell": 0.0,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
	{
		"time": 280.8,
		"position": Vector3(-2.0, 0.7, 0.0),
		"dwell": 0.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 283.5,
		"position": Vector3(-5.75, 0.7, 0.0),
		"dwell": 0.0,
		"facing": Vector3(-1.0, 0.0, 0.0),
	},
	{
		"time": 288.5,
		"position": Vector3(-12.75, 0.7, 0.0),
		"dwell": 11.5,
		"facing": Vector3(0.0, 0.0, -1.0),
	},
]

@export_group("Routine Glances")
@export var glance_interval: float = 15.0
@export var glance_duration: float = 2.0
@export var glance_min_offset_degrees: float = 100.0
@export var glance_max_offset_degrees: float = 160.0
@export var glance_random_seed: int = 260724

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
@export var cone_distance_smoothing_speed: float = 15.0

@export_group("Suspicion")
@export var suspicion_max: float = 100.0
@export var investigate_threshold: float = 50.0
@export var noise_suspicion_multiplier: float = 10.0
@export var ring_radius_per_loudness: float = 8.0
@export var ring_radius_cap: float = 20.0
@export var seen_suspicion_per_second: float = 25.0
@export var suspicion_decay_per_second: float = 5.0
@export var event_alert_threshold: float = 25.0
@export var seen_full_rate_distance: float = 4.0
@export var seen_max_multiplier_distance: float = 2.5
@export var seen_max_proximity_multiplier: float = 3.0

@export_group("Hearing Interest")
@export var hearing_source_cooldown: float = 0.4
@export var interest_threshold: float = 10.0
@export var curious_hold_duration: float = 2.0
@export var interest_window_duration: float = 8.0

@export_group("Investigate")
@export var investigate_speed: float = 2.2
@export var investigate_alert_pause: float = 0.6
@export var investigate_look_duration: float = 4.0
@export var investigate_hard_timeout: float = 10.0
@export var repeat_cooldown_duration: float = 8.0
@export var repeat_cooldown_distance: float = 2.0

@export_group("Found Chase")
@export var found_speed: float = 3.8
@export var grab_distance: float = 1.5
@export var found_lunge_distance: float = 2.5
@export var found_lose_sight_duration: float = 5.0
@export var found_escape_suspicion: float = 60.0

@export_group("Hunt")
@export var hunt_threshold: float = 75.0
@export var hunt_exit_suspicion: float = 60.0
@export var hunt_timeout: float = 8.0

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
@export var post_deposit_crib_safe_radius: float = 1.75
@export var post_deposit_kitchen_position: Vector3 = Vector3(9.5, 0.7, -3.8)
@export var post_deposit_kitchen_speed: float = 2.2
@export var post_deposit_room_entry_openness: float = 0.7
@export var post_deposit_room_check_position: Vector3 = Vector3(-12.0, 0.7, -3.0)
@export var post_deposit_room_dwell_duration: float = 4.0
@export var post_deposit_protest_delay: float = 1.2

@export_group("Light Expectations")
@export var light_anomaly_scan_interval: float = 0.2
@export var light_restore_delay: float = 2.0
@export var light_switch_arrival_distance: float = 0.8
@export var light_anomaly_cone_padding: float = 0.35
@export var tv_couch_position: Vector3 = Vector3(-0.2, 0.7, -4.6)
@export var tv_couch_settle_distance: float = 1.0
@export var tv_ambient_id: String = "tv"
@export var tv_glow_node_name: String = "TVGlow"
@export var tv_notes_node_name: String = "TVNotes"

@export_group("Parent Voice Indicator")
@export var voice_indicator_color: Color = Color("#ff2d95")
@export var voice_indicator_height: float = 1.35
@export var voice_indicator_duration: float = 0.9
@export var voice_indicator_scale: float = 0.2
@export var voice_indicator_pulse_speed: float = 8.0

@export_group("Readability")
@export var cone_base_color: Color = Color(0.68, 0.56, 0.92, 1.0)
@export var cone_suspicious_color: Color = Color(1.0, 0.68, 0.18, 1.0)
@export var cone_hunt_color: Color = Color(1.0, 0.38, 0.12, 1.0)
@export var cone_found_color: Color = Color(1.0, 0.12, 0.12, 1.0)
@export_range(0.0, 1.0, 0.01) var cone_base_alpha: float = 0.12
@export_range(0.0, 1.0, 0.01) var cone_suspicious_alpha: float = 0.34
@export_range(0.0, 1.0, 0.01) var cone_hunt_alpha: float = 0.4
@export_range(0.0, 1.0, 0.01) var cone_found_alpha: float = 0.45

@export_group("Debug Trace")
@export var debug_perception_trace: bool = false
@export var debug_perception_trace_interval: float = 0.25
@export var debug_hearing_trace: bool = false

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

@export_group("B9 Runtime Verification")
@export var verify_b9_far_bark_distance: float = 14.0
@export var verify_b9_far_run_distance: float = 10.0
@export var verify_b9_endgame_start_time: float = 268.9
@export var verify_b9_endgame_duration: float = 30.0
@export var verify_b9_final_hall_position: Vector3 = Vector3(-12.75, 0.7, 0.0)
@export var verify_b9_final_hall_tolerance: float = 1.5
@export var verify_b9_final_time_target: float = 292.0
@export var verify_b9_final_time_tolerance: float = 2.0
@export var verify_b9_bowl_trigger_delay: float = 0.5
@export var verify_b9_bowl_timeout: float = 12.0
@export var verify_b9_cone_wall_position: Vector3 = Vector3(0.0, 0.7, -5.3)
@export var verify_b9_cone_wall_honesty_tolerance: float = 0.02

@export_group("B10 Runtime Verification")
@export var verify_b10_sprint_start: Vector3 = Vector3(-12.75, 0.6, -0.8)
@export var verify_b10_sprint_parent_start: Vector3 = Vector3(-0.2, 0.7, -4.6)
@export var verify_b10_sprint_fridge: Vector3 = Vector3(12.2, 0.6, -4.2)
@export var verify_b10_sprint_duration: float = 40.0
@export var verify_b10_return_min_distance: float = 3.0
@export var verify_b10_glance_deadline: float = 20.0
@export var verify_b10_glance_player_distance: float = 3.5
@export var verify_b10_glance_detection_min: float = 5.0

@export_group("B13 Runtime Verification")
@export var verify_b13_walk_parent_position: Vector3 = Vector3(-12.75, 0.7, -0.8)
@export var verify_b13_walk_ahead_distance: float = 2.0
@export var verify_b13_walk_lateral_distance: float = 0.6
@export var verify_b13_walk_duration: float = 1.2
@export var verify_b13_noise_loudness: float = 3.0
@export var verify_b13_juke_parent_position: Vector3 = Vector3(-0.2, 0.7, -4.6)
@export var verify_b13_juke_start_distance: float = 2.4
@export var verify_b13_juke_speed: float = 3.6
@export var verify_b13_juke_half_span: float = 0.7
@export var verify_b13_catch_duration: float = 6.0
@export var verify_b13_chase_time_scale: float = 1.0
@export var verify_b13_chase_physics_ticks_per_second: int = 60
@export var verify_b13_chase_warmup_frames: int = 4
@export var verify_b13_light_radius: float = 5.0
@export var verify_b13_light_energy: float = 1.0
@export var verify_b13_max_physics_frames: int = 12000

@export_group("B14 Runtime Verification")
@export var verify_b14_timeout: float = 20.0
@export var verify_b14_voice_duration: float = 0.3

@export_group("B15 Runtime Verification")
@export var verify_b15_door_distance: float = 12.0
@export var verify_b15_rush_duration: float = 1.0
@export var verify_b15_second_cue_delay: float = 0.6
@export var verify_b15_turn_dot: float = 0.9
@export var verify_b15_no_walk_tolerance: float = 0.1
@export var verify_b15_investigate_move: float = 0.25
@export var verify_b15_timeout: float = 6.0

var suspicion: float = 0.0

var _state: State = State.ROUTINE
var _player: DinnerPlayer
var _navigation_agent: NavigationAgent3D
var _vision_cone: MeshInstance3D
var _crib: Node3D
var _snack: DinnerSnack
var _bedroom_door: DinnerDoor
var _bathroom_door: DinnerDoor
var _level: Node3D
var _kid_hall_switch: DinnerWorldSwitch
var _cone_material: StandardMaterial3D
var _cone_ray_distances: Array[float] = []
var _glance_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _navigation_ready: bool = false
var _last_navigation_target: Vector3
var _has_navigation_target: bool = false
var _sweep_time: float = 0.0
var _cone_yaw_degrees: float = 0.0
var _moved_along_path_this_frame: bool = false
var _heard_since_last_tick: bool = false
var _last_known_position: Vector3
var _hearing_elapsed: float = 0.0
var _source_next_hearing_time: Dictionary = {}
var _source_last_event_time: Dictionary = {}
var _interest_window_remaining: float = 0.0
var _interest_position: Vector3
var _curious_elapsed: float = 0.0
var _curiosity_count: int = 0
var _verify_b15_counted_events: int = 0
var _investigate_elapsed: float = 0.0
var _investigate_look_elapsed: float = 0.0
var _found_no_sight_elapsed: float = 0.0
var _hunt_no_noise_elapsed: float = 0.0
var _hunt_target_position: Vector3
var _repeat_cooldown_remaining: float = 0.0
var _last_checked_position: Vector3
var _has_checked_position: bool = false
var _carry_elapsed: float = 0.0
var _carry_path_started: bool = false
var _post_deposit_elapsed: float = 0.0
var _post_deposit_path_started: bool = false
var _verify_b8_door_creak_heard: bool = false
var _verify_b9_bowl_clatter_heard: bool = false
var _routine_staged_door_row: int = -1
var _routine_staged_door_opened: bool = false
var _glance_row_index: int = -1
var _glance_interval_elapsed: float = 0.0
var _glance_duration_elapsed: float = 0.0
var _glance_active: bool = false
var _glance_direction: Vector3
var _glance_count: int = 0
var _debug_trace_elapsed: float = 0.0
var _debug_trace_initialized: bool = false
var _debug_trace_state: StringName
var _debug_trace_sees: bool = false
var _debug_trace_hears: bool = false
var _light_anomaly_scan_elapsed: float = 0.0
var _light_anomaly_switch: DinnerWorldSwitch
var _light_anomaly_expected_on: bool = false
var _light_restore_elapsed: float = 0.0
var _parent_operating_switch: bool = false
var _kid_hall_punishment_active: bool = false
var _tv_suppressed_for_listening: bool = false
var _post_deposit_protest_emitted: bool = false
var _voice_indicator: MeshInstance3D
var _voice_indicator_elapsed: float = 0.0
var _voice_indicator_active: bool = false
var _verify_b14_visual_noise_count: int = 0


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_navigation_agent = get_node_or_null(navigation_agent_path) as NavigationAgent3D
	_vision_cone = get_node_or_null(vision_cone_path) as MeshInstance3D
	_crib = get_node_or_null(crib_path) as Node3D
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_bedroom_door = get_node_or_null(bedroom_door_path) as DinnerDoor
	_bathroom_door = get_node_or_null(bathroom_door_path) as DinnerDoor
	_level = get_node_or_null(level_path) as Node3D
	_kid_hall_switch = (
		get_node_or_null(kid_hall_switch_path) as DinnerWorldSwitch
	)
	_glance_rng.seed = glance_random_seed
	_setup_cone()
	_setup_voice_indicator()
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)
	_finish_navigation_setup.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b6"):
		_run_b6_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b7"):
		_run_b7_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b8"):
		_run_b8_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b9"):
		_run_b9_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b10"):
		_run_b10_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b13"):
		_run_b13_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b14"):
		_run_b14_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b15"):
		_run_b15_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--trace-parent-perception"):
		debug_perception_trace = true
	if OS.get_cmdline_user_args().has("--trace-parent-hearing"):
		debug_hearing_trace = true


func _physics_process(delta: float) -> void:
	_repeat_cooldown_remaining = maxf(_repeat_cooldown_remaining - delta, 0.0)
	_update_hearing_interest(delta)
	_moved_along_path_this_frame = false
	_enforce_tv_listening_state()
	_update_perception(delta)

	match _state:
		State.ROUTINE:
			_update_routine(delta)
		State.CURIOUS:
			_update_curious(delta)
		State.INVESTIGATE:
			_update_investigate(delta)
		State.HUNT:
			_update_hunt(delta)
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
		State.POST_DEPOSIT_ROOM_ENTER:
			_update_post_deposit_room_enter(delta)
		State.POST_DEPOSIT_ROOM_DWELL:
			_update_post_deposit_room_dwell(delta)
		State.POST_DEPOSIT_ROOM_EXIT:
			_update_post_deposit_room_exit(delta)

	_update_sweep(delta)
	_update_readability()
	_update_voice_indicator(delta)
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
	if next_state != State.ROUTINE:
		_cancel_glance()
	_state = next_state
	if next_state == State.INVESTIGATE or next_state == State.HUNT:
		_suppress_tv_for_listening()
	state_changed.emit(get_state_name())


func _update_hearing_interest(delta: float) -> void:
	_hearing_elapsed += delta
	if _interest_window_remaining <= 0.0:
		return
	_interest_window_remaining = maxf(
		_interest_window_remaining - delta,
		0.0
	)
	if _interest_window_remaining <= 0.0:
		_clear_interest()


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
	_scan_for_visible_light_anomaly(delta)
	if _state != State.ROUTINE:
		return
	_try_restore_tv_at_couch()
	var routine_time: float = _get_routine_time()
	_update_routine_door_staging(routine_time)
	var target: Vector3 = get_base_target(routine_time)
	_set_navigation_target(target)
	if _move_along_path(routine_speed, delta):
		_cancel_glance()
		return
	var routine_facing: Vector3 = get_base_facing(routine_time)
	var dwell_row_index: int = _get_active_dwell_row_index(routine_time)
	if dwell_row_index >= 0:
		routine_facing = _update_glance(
			delta,
			dwell_row_index,
			routine_facing
		)
	else:
		_cancel_glance()
	_face_direction(routine_facing, delta)


func _get_active_dwell_row_index(routine_time: float) -> int:
	for row_index in range(routine_rows.size()):
		var row: Dictionary = routine_rows[row_index]
		var dwell: float = _row_dwell(row)
		if dwell <= 0.0:
			continue
		var arrival_time: float = _row_time(row)
		if routine_time >= arrival_time and routine_time <= arrival_time + dwell:
			return row_index
	return -1


func _update_glance(
	delta: float,
	dwell_row_index: int,
	dwell_facing: Vector3
) -> Vector3:
	if _glance_row_index != dwell_row_index:
		_glance_row_index = dwell_row_index
		_glance_interval_elapsed = 0.0
		_glance_duration_elapsed = 0.0
		_glance_active = false
	if _glance_active:
		_glance_duration_elapsed += delta
		if _glance_duration_elapsed < glance_duration:
			return _glance_direction
		_glance_active = false
		_glance_duration_elapsed = 0.0
		_glance_interval_elapsed = 0.0
		return dwell_facing
	_glance_interval_elapsed += delta
	if glance_interval <= 0.0 or _glance_interval_elapsed < glance_interval:
		return dwell_facing
	var minimum_offset: float = minf(
		glance_min_offset_degrees,
		glance_max_offset_degrees
	)
	var maximum_offset: float = maxf(
		glance_min_offset_degrees,
		glance_max_offset_degrees
	)
	var glance_offset: float = _glance_rng.randf_range(
		minimum_offset,
		maximum_offset
	)
	if _glance_rng.randf() < 0.5:
		glance_offset *= -1.0
	_glance_direction = dwell_facing.rotated(
		Vector3.UP,
		deg_to_rad(glance_offset)
	).normalized()
	_glance_active = true
	_glance_duration_elapsed = 0.0
	_glance_count += 1
	return _glance_direction


func _cancel_glance() -> void:
	_glance_row_index = -1
	_glance_interval_elapsed = 0.0
	_glance_duration_elapsed = 0.0
	_glance_active = false


func _update_routine_door_staging(routine_time: float) -> void:
	for row_index in range(routine_rows.size()):
		var row: Dictionary = routine_rows[row_index]
		var door_key: StringName = _row_door(row)
		if door_key == &"":
			continue
		var arrival_time: float = _row_time(row)
		var departure_time: float = arrival_time + _row_dwell(row)
		if routine_time < arrival_time:
			if _routine_staged_door_row == row_index:
				_routine_staged_door_row = -1
				_routine_staged_door_opened = false
			return
		var routine_door: DinnerDoor = _get_routine_door(door_key)
		if routine_door == null:
			continue
		if routine_time <= departure_time:
			if (
				_routine_staged_door_row != row_index
				and _flat_distance(global_position, _row_position(row))
				<= routine_door_arrival_distance
			):
				routine_door.close_immediately()
				_routine_staged_door_row = row_index
				_routine_staged_door_opened = false
			return
		var exit_window_end: float = departure_time + routine_door.sneak_open_duration
		if row_index + 1 < routine_rows.size():
			exit_window_end = maxf(
				exit_window_end,
				_row_time(routine_rows[row_index + 1])
			)
		if (
			routine_time <= exit_window_end
			and not _routine_staged_door_opened
		):
			routine_door.open_to(bathroom_door_open_openness)
			_routine_staged_door_row = row_index
			_routine_staged_door_opened = true
		elif (
			routine_time > exit_window_end
			and _routine_staged_door_row == row_index
		):
			_routine_staged_door_row = -1
			_routine_staged_door_opened = false
		return


func _get_routine_door(door_key: StringName) -> DinnerDoor:
	if door_key == &"bathroom":
		return _bathroom_door
	return null


func _scan_for_visible_light_anomaly(delta: float) -> void:
	if _light_anomaly_switch != null or _state != State.ROUTINE:
		return
	_light_anomaly_scan_elapsed += delta
	if _light_anomaly_scan_elapsed < light_anomaly_scan_interval:
		return
	_light_anomaly_scan_elapsed = 0.0
	for node: Node in get_tree().get_nodes_in_group("world_switch"):
		var wall_switch: DinnerWorldSwitch = node as DinnerWorldSwitch
		if wall_switch == null:
			continue
		var expected_on: bool = _is_switch_expected_on(wall_switch.switch_id)
		if wall_switch.is_on == expected_on:
			continue
		var observation_position: Vector3 = (
			_get_switch_observation_position(wall_switch)
		)
		if not _is_point_in_active_cone(observation_position):
			continue
		_begin_light_anomaly_investigation(wall_switch)
		return


func _is_switch_expected_on(switch_id: StringName) -> bool:
	match switch_id:
		&"dining":
			return GameClock.phase < 4
		&"kitchen":
			return GameClock.phase < 3
		&"foyer":
			return GameClock.phase < 4
		&"bathroom":
			return true
		&"kid_hall":
			return _kid_hall_punishment_active
		_:
			return false


func _get_switch_observation_position(
	wall_switch: DinnerWorldSwitch
) -> Vector3:
	if not wall_switch.target_fixture_path.is_empty():
		var fixture: Node3D = (
			wall_switch.get_node_or_null(wall_switch.target_fixture_path) as Node3D
		)
		if fixture != null:
			return fixture.global_position
	return wall_switch.global_position


func _is_point_in_active_cone(point: Vector3) -> bool:
	var to_point: Vector3 = point - global_position
	to_point.y = 0.0
	var point_distance: float = to_point.length()
	if (
		point_distance <= 0.0
		or point_distance > vision_range + light_anomaly_cone_padding
	):
		return false
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized().rotated(
		Vector3.UP,
		deg_to_rad(_cone_yaw_degrees)
	)
	if (
		rad_to_deg(forward.angle_to(to_point.normalized()))
		> _get_current_cone_angle() * 0.5
	):
		return false
	var wall_distance: float = _get_static_hit_distance(to_point.normalized())
	return wall_distance + light_anomaly_cone_padding >= point_distance


func _begin_light_anomaly_investigation(
	wall_switch: DinnerWorldSwitch
) -> void:
	if (
		wall_switch == null
		or _state == State.CARRY
		or _state == State.FOUND
		or _state == State.HUNT
	):
		return
	_light_anomaly_switch = wall_switch
	_light_anomaly_expected_on = _is_switch_expected_on(wall_switch.switch_id)
	_light_restore_elapsed = 0.0
	_begin_or_update_investigate(wall_switch.global_position, true)
	light_anomaly_started.emit(wall_switch.switch_id)


func _restore_light_anomaly() -> void:
	if _light_anomaly_switch == null:
		return
	var restored_switch: DinnerWorldSwitch = _light_anomaly_switch
	var expected_on: bool = _light_anomaly_expected_on
	_parent_operating_switch = true
	restored_switch.set_state(expected_on, true)
	_parent_operating_switch = false
	light_anomaly_restored.emit(restored_switch.switch_id, expected_on)
	_clear_light_anomaly()


func _clear_light_anomaly() -> void:
	_light_anomaly_switch = null
	_light_anomaly_expected_on = false
	_light_restore_elapsed = 0.0


func _suppress_tv_for_listening() -> void:
	if GameClock.phase >= 2:
		_set_tv_enabled(false)
		return
	_tv_suppressed_for_listening = true
	_set_tv_enabled(false)


func _enforce_tv_listening_state() -> void:
	if GameClock.phase >= 2:
		_tv_suppressed_for_listening = false
		_set_tv_enabled(false)
	elif _tv_suppressed_for_listening:
		_set_tv_enabled(false)


func _try_restore_tv_at_couch() -> void:
	if (
		not _tv_suppressed_for_listening
		or GameClock.phase >= 2
		or _flat_distance(global_position, tv_couch_position)
		> tv_couch_settle_distance
	):
		return
	if _navigation_agent != null and not _navigation_agent.is_navigation_finished():
		return
	_tv_suppressed_for_listening = false
	_set_tv_enabled(true)


func _set_tv_enabled(on: bool) -> void:
	var effective_on: bool = on and GameClock.phase < 2
	NoiseSystem.set_ambient_source_enabled(tv_ambient_id, effective_on)
	if _level != null:
		for node_name: String in [tv_glow_node_name, tv_notes_node_name]:
			var tv_visual: Node3D = _level.get_node_or_null(node_name) as Node3D
			if tv_visual != null:
				tv_visual.visible = effective_on
	var tv_bed: AudioStreamPlayer3D = (
		get_node_or_null("../AudioDirector/TVBed") as AudioStreamPlayer3D
	)
	if tv_bed == null:
		return
	if effective_on:
		if GameClock.running and not tv_bed.playing:
			tv_bed.play()
	elif tv_bed.playing:
		tv_bed.stop()


func _update_curious(delta: float) -> void:
	_curious_elapsed += delta
	_face_direction(_interest_position - global_position, delta)
	if _curious_elapsed < curious_hold_duration:
		return
	_set_state(State.ROUTINE)
	_set_navigation_target(get_base_target(_get_routine_time()), true)


func _update_investigate(delta: float) -> void:
	_investigate_elapsed += delta
	if _investigate_elapsed >= investigate_hard_timeout:
		_clear_light_anomaly()
		_finish_investigate()
		return
	if _investigate_elapsed < investigate_alert_pause:
		return
	if not _can_query_navigation():
		return

	_set_navigation_target(_last_known_position)
	if _move_along_path(investigate_speed, delta):
		_investigate_look_elapsed = 0.0
		_light_restore_elapsed = 0.0
		return

	if _light_anomaly_switch != null:
		if (
			_flat_distance(
				global_position,
				_light_anomaly_switch.global_position
			) > light_switch_arrival_distance
			and not _navigation_agent.is_navigation_finished()
		):
			return
		_face_direction(
			_light_anomaly_switch.global_position - global_position,
			delta
		)
		_light_restore_elapsed += delta
		if _light_restore_elapsed >= light_restore_delay:
			_restore_light_anomaly()
			_finish_investigate()
		return
		return

	_investigate_look_elapsed += delta
	if _investigate_look_elapsed >= investigate_look_duration:
		_finish_investigate()


func _update_hunt(delta: float) -> void:
	if _heard_since_last_tick:
		_hunt_no_noise_elapsed = 0.0
	else:
		_hunt_no_noise_elapsed += delta
	if (
		suspicion < hunt_exit_suspicion
		or _hunt_no_noise_elapsed >= hunt_timeout
	):
		_finish_hunt()
		return
	_set_navigation_target(_hunt_target_position)
	if not _move_along_path(found_speed, delta):
		_face_direction(_hunt_target_position - global_position, delta)


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
		if _is_player_in_crib_area():
			_set_state(State.POST_DEPOSIT_RECLOSE)
		else:
			_begin_post_deposit_room_check()


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


func _begin_post_deposit_room_check() -> void:
	if (
		_state == State.POST_DEPOSIT_ROOM_ENTER
		or _state == State.POST_DEPOSIT_ROOM_DWELL
		or _state == State.POST_DEPOSIT_ROOM_EXIT
	):
		return
	_clear_light_anomaly()
	_post_deposit_elapsed = 0.0
	_post_deposit_path_started = false
	_post_deposit_protest_emitted = false
	if _bedroom_door != null:
		_bedroom_door.open_to(post_deposit_room_entry_openness)
	_set_navigation_target(post_deposit_room_check_position, true)
	_set_state(State.POST_DEPOSIT_ROOM_ENTER)


func _update_post_deposit_room_enter(delta: float) -> void:
	if (
		_bedroom_door != null
		and _bedroom_door.openness
		< _bedroom_door.blocker_disable_openness
	):
		_face_bedroom_door(delta)
		return
	_set_navigation_target(post_deposit_room_check_position)
	_move_along_path(post_deposit_exit_speed, delta)
	if not _navigation_agent.is_navigation_finished():
		_post_deposit_path_started = true
	if not _post_deposit_path_started:
		return
	if not _has_reached_post_deposit_target(post_deposit_room_check_position):
		return
	_post_deposit_elapsed = 0.0
	_post_deposit_protest_emitted = false
	_set_state(State.POST_DEPOSIT_ROOM_DWELL)
	epilogue_room_check_started.emit()


func _update_post_deposit_room_dwell(delta: float) -> void:
	_post_deposit_elapsed += delta
	if _crib != null:
		_face_direction(_crib.global_position - global_position, delta)
	if (
		not _post_deposit_protest_emitted
		and _post_deposit_elapsed >= post_deposit_protest_delay
	):
		_post_deposit_protest_emitted = true
		epilogue_kid_protest.emit()
	if _post_deposit_elapsed < post_deposit_room_dwell_duration:
		return
	_post_deposit_path_started = false
	_set_navigation_target(post_deposit_exit_position, true)
	_set_state(State.POST_DEPOSIT_ROOM_EXIT)


func _update_post_deposit_room_exit(delta: float) -> void:
	_set_navigation_target(post_deposit_exit_position)
	_move_along_path(post_deposit_exit_speed, delta)
	if not _navigation_agent.is_navigation_finished():
		_post_deposit_path_started = true
	if not _post_deposit_path_started:
		return
	if not _has_reached_post_deposit_target(post_deposit_exit_position):
		return
	if _bedroom_door != null:
		_bedroom_door.close_immediately()
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
	if _try_begin_carry_if_close():
		return

	var has_line_of_sight: bool = _has_clear_line_of_sight()
	if has_line_of_sight:
		_last_known_position = _player.global_position
		_found_no_sight_elapsed = 0.0
	else:
		_found_no_sight_elapsed += delta
		if _found_no_sight_elapsed >= found_lose_sight_duration:
			_escape_found()
			return

	_set_navigation_target(_player.global_position)
	if (
		has_line_of_sight
		and _flat_distance(global_position, _player.global_position)
		<= found_lunge_distance
	):
		_move_directly_toward_player(delta)
	elif _can_query_navigation():
		if not _move_along_path(found_speed, delta):
			_face_direction(_player.global_position - global_position, delta)
	if _try_begin_carry_if_close():
		return


func _try_begin_carry_if_close() -> bool:
	if _player == null:
		return false
	if _flat_distance(global_position, _player.global_position) > grab_distance:
		return false
	_begin_carry()
	return _state == State.CARRY


func _move_directly_toward_player(delta: float) -> void:
	if _player == null:
		return
	var movement: Vector3 = _player.global_position - global_position
	movement.y = 0.0
	if movement.length_squared() <= 0.0:
		return
	var movement_distance: float = minf(
		maxf(found_speed, 0.0) * delta,
		movement.length()
	)
	var movement_direction: Vector3 = movement.normalized()
	global_position += movement_direction * movement_distance
	_face_direction(movement_direction, delta)
	_moved_along_path_this_frame = movement_distance > 0.0


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
	if _player == null:
		_trace_perception(delta, false)
		return
	if _state == State.FOUND or _state == State.CARRY:
		_trace_perception(
			delta,
			_state == State.FOUND and _can_see_player()
		)
		return

	var was_post_deposit: bool = _is_post_deposit_state()
	var sees_player: bool = (
		not was_post_deposit
		or not _is_player_in_crib_area()
	) and _can_see_player()
	if sees_player:
		if _state == State.POST_DEPOSIT_PEEK:
			_begin_post_deposit_room_check()
			_trace_perception(delta, true)
			return
		_clear_light_anomaly()
		_last_known_position = _player.global_position
		suspicion += seen_suspicion_per_second * _get_seen_rate_multiplier() * delta
		if suspicion >= suspicion_max:
			_begin_found_or_carry()
		elif _state != State.HUNT:
			_begin_or_update_investigate(_last_known_position, true)
	elif not _heard_since_last_tick:
		suspicion -= suspicion_decay_per_second * delta
	suspicion = clampf(suspicion, 0.0, suspicion_max)
	_trace_perception(delta, sees_player)


func _is_player_in_crib_area() -> bool:
	if _player == null or _crib == null:
		return false
	return (
		_flat_distance(_player.global_position, _crib.global_position)
		<= post_deposit_crib_safe_radius
	)


func _trace_perception(delta: float, sees_player: bool) -> void:
	if not debug_perception_trace:
		return
	_debug_trace_elapsed += delta
	var state_name: StringName = get_state_name()
	var state_changed_since_trace: bool = (
		not _debug_trace_initialized
		or state_name != _debug_trace_state
	)
	var senses_changed_since_trace: bool = (
		not _debug_trace_initialized
		or sees_player != _debug_trace_sees
		or _heard_since_last_tick != _debug_trace_hears
	)
	if (
		not state_changed_since_trace
		and not senses_changed_since_trace
		and _debug_trace_elapsed < maxf(debug_perception_trace_interval, 0.0)
	):
		return
	print(
		"Parent perception: state=%s suspicion=%.1f sees=%s hears=%s"
		% [
			state_name,
			suspicion,
			sees_player,
			_heard_since_last_tick,
		]
	)
	_debug_trace_elapsed = 0.0
	_debug_trace_initialized = true
	_debug_trace_state = state_name
	_debug_trace_sees = sees_player
	_debug_trace_hears = _heard_since_last_tick


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
	if source == self or _state == State.CARRY:
		return
	if _parent_operating_switch and source is DinnerWorldSwitch:
		return
	if source == _bedroom_door and _is_post_deposit_state():
		return
	if (
		source == _bathroom_door
		and _routine_staged_door_opened
		and _bathroom_door != null
		and _bathroom_door.is_opening_to_target()
	):
		return
	var audible_radius: float = minf(
		maxf(loudness, 0.0) * maxf(ring_radius_per_loudness, 0.0),
		maxf(ring_radius_cap, 0.0)
	)
	if audible_radius <= 0.0:
		return
	var distance_to_noise: float = global_position.distance_to(pos)
	if distance_to_noise >= audible_radius:
		_trace_hearing_event(
			source,
			loudness,
			distance_to_noise,
			0.0,
			false,
			false,
			&"out_of_range"
		)
		return
	var falloff: float = 1.0 - distance_to_noise / audible_radius
	var event_contribution: float = loudness * noise_suspicion_multiplier * falloff
	if source is DinnerPet:
		event_contribution = maxf(event_contribution, event_alert_threshold)
	var source_id: int = source.get_instance_id() if source != null else 0
	var sustained_source: bool = source is DinnerDoor
	var last_event_time: float = float(
		_source_last_event_time.get(source_id, -INF)
	)
	var new_source_burst: bool = (
		not sustained_source
		or _hearing_elapsed - last_event_time
		> maxf(hearing_source_cooldown, 0.0)
	)
	_source_last_event_time[source_id] = _hearing_elapsed
	var counts_contribution: bool = (
		not sustained_source
		or _hearing_elapsed
		>= float(_source_next_hearing_time.get(source_id, -INF))
	)
	_heard_since_last_tick = true
	_last_known_position = pos
	if not counts_contribution:
		if _state == State.HUNT:
			_hunt_target_position = pos
			_hunt_no_noise_elapsed = 0.0
			_set_navigation_target(pos, true)
		_trace_hearing_event(
			source,
			loudness,
			distance_to_noise,
			event_contribution,
			false,
			new_source_burst,
			&"source_cooldown"
		)
		return
	if sustained_source:
		_source_next_hearing_time[source_id] = (
			_hearing_elapsed + maxf(hearing_source_cooldown, 0.0)
		)
	if OS.get_cmdline_user_args().has("--verify-b15"):
		_verify_b15_counted_events += 1
	suspicion = clampf(
		suspicion + event_contribution,
		0.0,
		suspicion_max
	)
	var qualifying_interest: bool = (
		event_contribution >= interest_threshold
		and new_source_burst
	)
	_trace_hearing_event(
		source,
		loudness,
		distance_to_noise,
		event_contribution,
		true,
		new_source_burst,
		&"qualifying" if qualifying_interest else &"counted"
	)
	if _state == State.FOUND:
		return
	if _state == State.HUNT:
		_hunt_target_position = pos
		_hunt_no_noise_elapsed = 0.0
		_set_navigation_target(pos, true)
		return
	if source is DinnerWorldSwitch:
		_begin_light_anomaly_investigation(source as DinnerWorldSwitch)
		return
	if suspicion >= hunt_threshold:
		_clear_light_anomaly()
		_begin_hunt(pos)
	elif qualifying_interest:
		_clear_light_anomaly()
		_handle_interest_cue(pos)
	elif suspicion >= investigate_threshold and _interest_window_remaining <= 0.0:
		_clear_light_anomaly()
		_begin_or_update_investigate(pos)


func _handle_interest_cue(pos: Vector3) -> void:
	if _state == State.INVESTIGATE:
		_begin_or_update_investigate(pos, true)
		return
	if _interest_window_remaining > 0.0:
		_clear_interest()
		_begin_or_update_investigate(pos, true)
		return
	_interest_position = pos
	_interest_window_remaining = maxf(interest_window_duration, 0.0)
	_curious_elapsed = 0.0
	_curiosity_count += 1
	_set_state(State.CURIOUS)
	curiosity_started.emit(pos)


func _clear_interest() -> void:
	_interest_window_remaining = 0.0
	_curious_elapsed = 0.0


func _trace_hearing_event(
	source: Node,
	loudness: float,
	distance_to_noise: float,
	contribution: float,
	counted: bool,
	new_burst: bool,
	result: StringName
) -> void:
	if not debug_hearing_trace:
		return
	var source_name: String = "<null>"
	if source != null:
		source_name = str(source.name)
	print(
		(
			"Parent hearing: source=%s loudness=%.2f distance=%.2f "
			+ "contribution=%.1f counted=%s new_burst=%s result=%s "
			+ "state=%s suspicion=%.1f"
		)
		% [
			source_name,
			loudness,
			distance_to_noise,
			contribution,
			counted,
			new_burst,
			result,
			get_state_name(),
			suspicion,
		]
	)


func _is_post_deposit_state() -> bool:
	return (
		_state == State.POST_DEPOSIT_EXIT
		or _state == State.POST_DEPOSIT_CLOSE_BEHIND
		or _state == State.POST_DEPOSIT_HALL_WALK
		or _state == State.POST_DEPOSIT_REOPEN
		or _state == State.POST_DEPOSIT_PEEK
		or _state == State.POST_DEPOSIT_RECLOSE
		or _state == State.POST_DEPOSIT_KITCHEN
		or _state == State.POST_DEPOSIT_ROOM_ENTER
		or _state == State.POST_DEPOSIT_ROOM_DWELL
		or _state == State.POST_DEPOSIT_ROOM_EXIT
	)


func _begin_or_update_investigate(
	target: Vector3,
	ignore_repeat_cooldown: bool = false
) -> void:
	if not ignore_repeat_cooldown and _is_repeat_target_suppressed(target):
		return
	_clear_interest()
	_last_known_position = target
	if _state == State.INVESTIGATE:
		_set_navigation_target(target, true)
		return
	_cancel_glance()
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_set_state(State.INVESTIGATE)
	_set_navigation_target(target, true)


func _begin_hunt(target: Vector3) -> void:
	_clear_light_anomaly()
	_clear_interest()
	_hunt_target_position = target
	_last_known_position = target
	_hunt_no_noise_elapsed = 0.0
	_cancel_glance()
	_set_state(State.HUNT)
	_set_navigation_target(target, true)


func _finish_hunt() -> void:
	_last_known_position = _hunt_target_position
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_set_state(State.INVESTIGATE)
	_set_navigation_target(_last_known_position, true)


func _finish_investigate() -> void:
	_last_checked_position = _last_known_position
	_has_checked_position = true
	_repeat_cooldown_remaining = repeat_cooldown_duration
	_clear_light_anomaly()
	_set_state(State.ROUTINE)
	_set_navigation_target(get_base_target(_get_routine_time()), true)


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
	_cancel_glance()
	_clear_light_anomaly()
	_clear_interest()
	suspicion = suspicion_max
	_last_known_position = _player.global_position
	_found_no_sight_elapsed = 0.0
	_set_state(State.FOUND)
	_set_navigation_target(_player.global_position, true)


func _escape_found() -> void:
	_cancel_glance()
	suspicion = clampf(found_escape_suspicion, 0.0, suspicion_max)
	_investigate_elapsed = 0.0
	_investigate_look_elapsed = 0.0
	_set_state(State.INVESTIGATE)
	_set_navigation_target(_last_known_position, true)


func _begin_carry() -> void:
	if _state == State.CARRY or _player == null:
		return
	if global_position.distance_to(_player.global_position) > grab_distance:
		return
	_clear_interest()
	var catch_position: Vector3 = _player.global_position
	var had_snack: bool = _player.carrying_snack
	if had_snack:
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
	player_caught.emit(catch_position, had_snack)


func _finish_carry() -> void:
	if _player != null:
		var player_drop_position: Vector3 = global_position
		if _crib != null:
			player_drop_position = _crib.global_position + crib_player_offset
		_player.detach_from_carrier(player_drop_position)
	_post_deposit_elapsed = 0.0
	_post_deposit_path_started = false
	_activate_punishment_light()
	_set_state(State.POST_DEPOSIT_EXIT)
	_set_navigation_target(post_deposit_exit_position, true)
	player_deposited.emit()


func _resume_routine_after_deposit() -> void:
	_set_state(State.ROUTINE)
	_set_navigation_target(get_base_target(_get_routine_time()), true)


func _activate_punishment_light() -> void:
	_kid_hall_punishment_active = true
	if _kid_hall_switch == null:
		return
	_parent_operating_switch = true
	_kid_hall_switch.set_state(true, true)
	_parent_operating_switch = false


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
	var suspicion_weight: float = clampf(
		suspicion / maxf(suspicion_max, 0.001),
		0.0,
		1.0
	)
	if _state == State.FOUND or _state == State.CARRY:
		_cone_material.albedo_color = _color_with_alpha(
			cone_found_color,
			cone_found_alpha
		)
	elif _state == State.HUNT:
		_cone_material.albedo_color = _color_with_alpha(
			cone_hunt_color,
			cone_hunt_alpha
		)
	else:
		var cone_color: Color = cone_base_color.lerp(
			cone_suspicious_color,
			suspicion_weight
		)
		cone_color.a = lerpf(
			cone_base_alpha,
			cone_suspicious_alpha,
			suspicion_weight
		)
		_cone_material.albedo_color = cone_color


func _get_current_cone_angle() -> float:
	match _state:
		State.CURIOUS:
			return investigate_cone_angle_degrees
		State.INVESTIGATE:
			return investigate_cone_angle_degrees
		State.HUNT:
			return found_cone_angle_degrees
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
	_cone_material.albedo_color = _color_with_alpha(
		cone_base_color,
		cone_base_alpha
	)
	_vision_cone.position.y = cone_floor_offset
	_build_cone_mesh(_get_current_cone_angle())


func _setup_voice_indicator() -> void:
	_voice_indicator = MeshInstance3D.new()
	_voice_indicator.name = "ParentVoiceIndicator"
	_voice_indicator.position = Vector3.UP * voice_indicator_height
	_voice_indicator.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_voice_indicator.visible = false
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.no_depth_test = true
	material.albedo_color = voice_indicator_color
	material.emission_enabled = true
	material.emission = voice_indicator_color
	var icon_mesh: ImmediateMesh = ImmediateMesh.new()
	icon_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
	for vertex: Vector3 in [
		Vector3(-0.45, -0.25, 0.0),
		Vector3(0.45, -0.25, 0.0),
		Vector3(0.45, 0.25, 0.0),
		Vector3(-0.45, -0.25, 0.0),
		Vector3(0.45, 0.25, 0.0),
		Vector3(-0.45, 0.25, 0.0),
		Vector3(-0.12, -0.24, 0.0),
		Vector3(0.02, -0.48, 0.0),
		Vector3(0.16, -0.24, 0.0),
	]:
		icon_mesh.surface_add_vertex(vertex)
	icon_mesh.surface_end()
	_voice_indicator.mesh = icon_mesh
	_voice_indicator.scale = Vector3.ONE * voice_indicator_scale
	add_child(_voice_indicator)


func show_parent_voice_indicator(duration: float = -1.0) -> void:
	if _voice_indicator == null:
		return
	_voice_indicator_elapsed = (
		duration if duration >= 0.0 else voice_indicator_duration
	)
	_voice_indicator_active = true
	_voice_indicator.visible = true


func _update_voice_indicator(delta: float) -> void:
	if not _voice_indicator_active or _voice_indicator == null:
		return
	_voice_indicator_elapsed -= delta
	var pulse: float = 1.0 + 0.1 * sin(
		Time.get_ticks_msec() * 0.001 * voice_indicator_pulse_speed
	)
	_voice_indicator.scale = (
		Vector3.ONE * maxf(voice_indicator_scale * pulse, 0.001)
	)
	if _voice_indicator_elapsed > 0.0:
		return
	_voice_indicator_active = false
	_voice_indicator.visible = false


func _color_with_alpha(color: Color, alpha: float) -> Color:
	var result: Color = color
	result.a = clampf(alpha, 0.0, 1.0)
	return result


func _build_cone_mesh(cone_angle_degrees: float) -> void:
	if _vision_cone == null or _cone_material == null:
		return
	var ray_count: int = maxi(cone_raycast_count, 2)
	var reset_distances: bool = _cone_ray_distances.size() != ray_count
	if reset_distances:
		_cone_ray_distances.resize(ray_count)
	var half_angle_radians: float = deg_to_rad(cone_angle_degrees * 0.5)
	var smoothing_weight: float = clampf(
		cone_distance_smoothing_speed * get_physics_process_delta_time(),
		0.0,
		1.0
	)
	var ray_points: Array[Vector3] = []
	for ray_index in range(ray_count):
		var ray_weight: float = float(ray_index) / float(ray_count - 1)
		var ray_angle: float = lerpf(-half_angle_radians, half_angle_radians, ray_weight)
		var local_direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, ray_angle)
		var world_direction: Vector3 = _vision_cone.global_transform.basis * local_direction
		world_direction.y = 0.0
		world_direction = world_direction.normalized()
		var hit_distance: float = _get_static_hit_distance(world_direction)
		var clipped_distance: float = hit_distance
		if not reset_distances:
			clipped_distance = minf(
				hit_distance,
				lerpf(
					_cone_ray_distances[ray_index],
					hit_distance,
					smoothing_weight
				)
			)
		_cone_ray_distances[ray_index] = clipped_distance
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
	await _settle_verification_audio()
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
		_reset_hearing_interest_for_verification()
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
	await _settle_verification_audio()
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

	var dog_bark_interested: bool = false
	var dog_bark_suspicion: float = 0.0
	if pet != null and _player != null:
		_player.set_physics_process(false)
		_player.detach_from_carrier(verify_observer_parking_position)
		global_position = verify_bark_parent_position
		_state = State.ROUTINE
		suspicion = 0.0
		_reset_hearing_interest_for_verification()
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
		dog_bark_interested = (
			_state == State.CURIOUS
			and _last_known_position.distance_to(pet.global_position)
			<= routine_repath_distance
		)
		NoiseSystem.unregister_ambient_source(verify_bark_mask_id)

	var toy_interested: bool = false
	var toy_suspicion: float = 0.0
	var toy_position: Vector3 = Vector3.ZERO
	if _player != null:
		global_position = Vector3(0.0, verify_carry_parent_position.y, 0.0)
		_state = State.ROUTINE
		suspicion = 0.0
		_reset_hearing_interest_for_verification()
		_has_checked_position = false
		_repeat_cooldown_remaining = 0.0
		_set_navigation_target(global_position, true)
		toy_position = global_position + Vector3.RIGHT * verify_toy_event_distance
		NoiseSystem.emit_noise(toy_position, verify_toy_event_loudness, _player)
		toy_suspicion = suspicion
		toy_interested = (
			_state == State.CURIOUS
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
		and dog_bark_interested
		and toy_interested
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
	await _settle_verification_audio()
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
	assert(dog_bark_interested, "B8 dog bark did not trigger first-cue curiosity.")
	assert(toy_interested, "B8 nearby toy event did not trigger first-cue curiosity.")
	assert(decay_observed, "B8 suspicion did not decay at 5 points per second.")
	print("B8 live SceneTree verification passed.")


func _run_b9_live_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = _player != null and _player.is_physics_processing()

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	if _player != null:
		_player.set_physics_process(false)
		_player.detach_from_carrier(verify_observer_parking_position)
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	var hearing_origin: Vector3 = Vector3(0.0, verify_carry_parent_position.y, 0.0)
	global_position = hearing_origin
	_state = State.ROUTINE
	suspicion = 0.0
	_has_checked_position = false
	_repeat_cooldown_remaining = 0.0
	_set_navigation_target(global_position, true)
	var far_bark_position: Vector3 = (
		hearing_origin + Vector3.RIGHT * verify_b9_far_bark_distance
	)
	if pet != null:
		pet.global_position = far_bark_position
		pet.bark()
	await get_tree().physics_frame
	var far_bark_suspicion: float = suspicion
	var far_bark_interested: bool = (
		pet != null
		and _state == State.CURIOUS
		and _flat_distance(_last_known_position, far_bark_position)
		<= routine_repath_distance
	)

	global_position = hearing_origin
	_state = State.ROUTINE
	suspicion = 0.0
	_has_checked_position = false
	_repeat_cooldown_remaining = 0.0
	_set_navigation_target(global_position, true)
	var far_run_position: Vector3 = (
		hearing_origin + Vector3.RIGHT * verify_b9_far_run_distance
	)
	var far_run_loudness: float = 0.0
	if _player != null:
		far_run_loudness = (
			_player.run_noise_multiplier
			* _player.hardwood_surface_multiplier
		)
		NoiseSystem.emit_noise(far_run_position, far_run_loudness, _player)
	await get_tree().physics_frame
	var far_run_ignored: bool = _state == State.ROUTINE and is_zero_approx(suspicion)

	var temporary_bathroom_door: DinnerDoor
	if _bathroom_door == null:
		temporary_bathroom_door = DinnerDoor.new()
		temporary_bathroom_door.name = "B9VerifyBathroomDoor"
		get_parent().add_child(temporary_bathroom_door)
		_bathroom_door = temporary_bathroom_door
	_bathroom_door.openness = bathroom_door_open_openness
	_state = State.ROUTINE
	suspicion = 0.0
	_routine_staged_door_row = -1
	_routine_staged_door_opened = false
	var bathroom_row: Dictionary = {}
	for row: Dictionary in routine_rows:
		if _row_door(row) == &"bathroom":
			bathroom_row = row
			break
	var bathroom_row_found: bool = not bathroom_row.is_empty()
	var bathroom_closed_on_arrival: bool = false
	var bathroom_opened_on_exit: bool = false
	var bathroom_open_commanded: bool = false
	var bathroom_routine_preserved: bool = false
	var bathroom_closed_openness: float = _bathroom_door.openness
	var bathroom_exit_openness: float = _bathroom_door.openness
	var bathroom_staged_row: int = -1
	var bathroom_exit_parent_state: StringName = &""
	if bathroom_row_found:
		global_position = _row_position(bathroom_row)
		GameClock.start()
		GameClock.time_remaining = (
			GameClock.run_length - _row_time(bathroom_row) - 0.05
		)
		for _frame_index in range(4):
			await get_tree().physics_frame
		bathroom_closed_openness = _bathroom_door.openness
		bathroom_closed_on_arrival = is_zero_approx(_bathroom_door.openness)
		GameClock.time_remaining = (
			GameClock.run_length
			- _row_time(bathroom_row)
			- _row_dwell(bathroom_row)
			- 0.05
		)
		bathroom_exit_openness = _bathroom_door.openness
		var bathroom_exit_start: float = (
			GameClock.run_length - GameClock.time_remaining
		)
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			bathroom_open_commanded = (
				bathroom_open_commanded
				or _routine_staged_door_opened
				or _bathroom_door.is_opening_to_target()
			)
			bathroom_exit_openness = maxf(
				bathroom_exit_openness,
				_bathroom_door.openness
			)
			var exit_elapsed: float = (
				GameClock.run_length - GameClock.time_remaining
			) - bathroom_exit_start
			if _bathroom_door.openness >= _bathroom_door.blocker_disable_openness:
				bathroom_opened_on_exit = true
				break
			if exit_elapsed >= _bathroom_door.sneak_open_duration:
				break
		bathroom_staged_row = _routine_staged_door_row
		bathroom_exit_parent_state = get_state_name()
		bathroom_routine_preserved = _state == State.ROUTINE

	global_position = verify_b9_cone_wall_position
	rotation.y = 0.0
	if _vision_cone != null:
		_vision_cone.rotation.y = 0.0
	_cone_ray_distances.clear()
	_build_cone_mesh(routine_cone_angle_degrees)
	var near_wall_distances: Array[float] = _cone_ray_distances.duplicate()
	rotation.y = PI
	var open_hit_distances: Array[float] = _get_live_cone_hit_distances(
		routine_cone_angle_degrees
	)
	_build_cone_mesh(routine_cone_angle_degrees)
	var cone_expansion_smoothed: bool = false
	var cone_open_wall_honest: bool = true
	var cone_largest_smoothing_gap: float = 0.0
	for ray_index in range(_cone_ray_distances.size()):
		var open_hit: float = open_hit_distances[ray_index]
		var smoothed_distance: float = _cone_ray_distances[ray_index]
		cone_largest_smoothing_gap = maxf(
			cone_largest_smoothing_gap,
			open_hit - smoothed_distance
		)
		cone_expansion_smoothed = (
			cone_expansion_smoothed
			or (
				open_hit > near_wall_distances[ray_index] + 0.1
				and smoothed_distance < open_hit - 0.05
			)
		)
		cone_open_wall_honest = (
			cone_open_wall_honest
			and smoothed_distance
			<= open_hit + verify_b9_cone_wall_honesty_tolerance
		)
	rotation.y = 0.0
	var near_hit_distances: Array[float] = _get_live_cone_hit_distances(
		routine_cone_angle_degrees
	)
	_build_cone_mesh(routine_cone_angle_degrees)
	var cone_contraction_wall_honest: bool = true
	for ray_index in range(_cone_ray_distances.size()):
		cone_contraction_wall_honest = (
			cone_contraction_wall_honest
			and _cone_ray_distances[ray_index]
			<= (
				near_hit_distances[ray_index]
				+ verify_b9_cone_wall_honesty_tolerance
			)
		)

	_state = State.ROUTINE
	suspicion = 0.0
	_routine_staged_door_row = -1
	_routine_staged_door_opened = false
	global_position = get_base_target(verify_b9_endgame_start_time)
	_set_navigation_target(global_position, true)
	GameClock.start()
	GameClock.time_remaining = GameClock.run_length - verify_b9_endgame_start_time
	var final_hall_closest: float = INF
	var final_hall_first_reach_time: float = INF
	var carpet_corner_closest: float = INF
	var carpet_nav_point: Vector3 = NavigationServer3D.map_get_closest_point(
		get_world_3d().navigation_map,
		Vector3(5.0, 0.7, 4.8)
	)
	var carpet_band_entered: bool = false
	var hall_turn_closest: float = INF
	var endgame_reached_duration: bool = false
	for _frame_index in range(verify_max_physics_frames):
		await get_tree().physics_frame
		var endgame_elapsed: float = (
			GameClock.run_length
			- GameClock.time_remaining
			- verify_b9_endgame_start_time
		)
		carpet_corner_closest = minf(
			carpet_corner_closest,
			_flat_distance(global_position, Vector3(5.0, 0.7, 4.8))
		)
		carpet_band_entered = (
			carpet_band_entered
			or carpet_corner_closest <= 1.0
		)
		hall_turn_closest = minf(
			hall_turn_closest,
			_flat_distance(global_position, Vector3(-5.75, 0.7, 0.0))
		)
		final_hall_closest = minf(
			final_hall_closest,
			_flat_distance(global_position, verify_b9_final_hall_position)
		)
		if (
			final_hall_first_reach_time == INF
			and final_hall_closest <= verify_b9_final_hall_tolerance
		):
			final_hall_first_reach_time = (
				GameClock.run_length - GameClock.time_remaining
			)
		if endgame_elapsed >= verify_b9_endgame_duration:
			endgame_reached_duration = true
			break
	var final_facing: Vector3 = -global_transform.basis.z
	final_facing.y = 0.0
	var final_facing_dot: float = final_facing.normalized().dot(Vector3.FORWARD)
	var final_faces_kid_door: bool = (
		final_facing_dot >= 0.9
	)
	var endgame_route_completed: bool = (
		endgame_reached_duration
		and carpet_band_entered
		and hall_turn_closest <= verify_b9_final_hall_tolerance
		and final_hall_closest <= verify_b9_final_hall_tolerance
		and absf(
			final_hall_first_reach_time - verify_b9_final_time_target
		) <= verify_b9_final_time_tolerance
		and final_faces_kid_door
	)

	var temporary_bowl: Node3D
	var bowl_visit_started: bool = false
	var bowl_eating_observed: bool = false
	var bowl_head_bob_observed: bool = false
	var bowl_visit_completed: bool = false
	var bowl_visit_elapsed: float = 0.0
	if pet != null:
		if pet._kitchen_bowl == null:
			temporary_bowl = Node3D.new()
			temporary_bowl.name = "B9VerifyKitchenBowl"
			temporary_bowl.global_position = Vector3(7.4, 0.42, -1.5)
			get_parent().add_child(temporary_bowl)
			pet._kitchen_bowl = temporary_bowl
		pet.global_position = Vector3(4.2, 0.42, -3.8)
		pet._has_left_bed = true
		pet._resume_base()
		GameClock.start()
		GameClock.time_remaining = GameClock.run_length - 100.0
		pet.schedule_bowl_visit_after(verify_b9_bowl_trigger_delay)
		_verify_b9_bowl_clatter_heard = false
		if not NoiseSystem.noise_emitted.is_connected(_capture_b9_noise):
			NoiseSystem.noise_emitted.connect(_capture_b9_noise)
		var bowl_start_elapsed: float = GameClock.run_length - GameClock.time_remaining
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			bowl_visit_elapsed = (
				GameClock.run_length - GameClock.time_remaining - bowl_start_elapsed
			)
			bowl_visit_started = bowl_visit_started or pet.is_visiting_bowl()
			bowl_eating_observed = bowl_eating_observed or pet.is_eating_at_bowl()
			if pet.is_eating_at_bowl() and pet._body != null:
				bowl_head_bob_observed = (
					bowl_head_bob_observed
					or pet._body.position.distance_to(pet._body_base_position)
					>= pet.bowl_head_bob_height * 0.25
				)
			if (
				bowl_eating_observed
				and not pet.is_visiting_bowl()
				and pet.get_state_name() == &"BASE"
			):
				bowl_visit_completed = true
				break
			if bowl_visit_elapsed >= verify_b9_bowl_timeout:
				break
	if NoiseSystem.noise_emitted.is_connected(_capture_b9_noise):
		NoiseSystem.noise_emitted.disconnect(_capture_b9_noise)

	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		_player.set_physics_process(player_was_processing)
	if temporary_bathroom_door != null:
		_bathroom_door = null
		temporary_bathroom_door.queue_free()
	if temporary_bowl != null and pet != null:
		pet._kitchen_bowl = null
		temporary_bowl.queue_free()

	var verification_passed: bool = (
		far_bark_interested
		and far_run_ignored
		and bathroom_row_found
		and bathroom_closed_on_arrival
		and bathroom_opened_on_exit
		and bathroom_routine_preserved
		and cone_expansion_smoothed
		and cone_open_wall_honest
		and cone_contraction_wall_honest
		and endgame_route_completed
		and bowl_visit_started
		and bowl_eating_observed
		and bowl_head_bob_observed
		and _verify_b9_bowl_clatter_heard
		and bowl_visit_completed
	)
	print(
		(
			"B9 live metrics: far bark %.1f m -> %.1f suspicion, "
			+ "run %.1f at %.1f m -> %.1f suspicion, cone gap=%.2f m, "
			+ "bath door=%.2f->%.2f (command=%s,row=%d,state=%s), "
			+ "route corners=%.2f/%.2f m (carpet nav %.1f,%.1f), "
			+ "end hall=%.2f m at %.2f s (face=%.2f,band=%s,duration=%s), "
			+ "bowl visit=%.2f s."
		)
		% [
			verify_b9_far_bark_distance,
			far_bark_suspicion,
			far_run_loudness,
			verify_b9_far_run_distance,
			0.0 if far_run_ignored else suspicion,
			cone_largest_smoothing_gap,
			bathroom_closed_openness,
			bathroom_exit_openness,
			bathroom_open_commanded,
			bathroom_staged_row,
			bathroom_exit_parent_state,
			carpet_corner_closest,
			hall_turn_closest,
			carpet_nav_point.x,
			carpet_nav_point.z,
			final_hall_closest,
			final_hall_first_reach_time,
			final_facing_dot,
			carpet_band_entered,
			endgame_reached_duration,
			bowl_visit_elapsed,
		]
	)
	await _settle_verification_audio()
	get_tree().quit(0 if verification_passed else 1)
	assert(far_bark_interested, "B9 14 m dog bark did not trigger curiosity.")
	assert(far_run_ignored, "B9 10 m run-hardwood event reached the parent.")
	assert(bathroom_row_found, "B9 routine has no bathroom door row.")
	assert(bathroom_closed_on_arrival, "B9 bathroom door did not close on arrival.")
	assert(bathroom_opened_on_exit, "B9 bathroom door did not open on exit.")
	assert(bathroom_routine_preserved, "B9 parent investigated its own bathroom door.")
	assert(
		cone_expansion_smoothed,
		"B9 cone rays jumped to their unclipped distance without smoothing."
	)
	assert(
		cone_open_wall_honest and cone_contraction_wall_honest,
		"B9 smoothed cone rendered beyond a live static hit."
	)
	assert(endgame_route_completed, "B9 parent missed the carpet-to-kid-door finale.")
	assert(
		bowl_visit_started
		and bowl_eating_observed
		and bowl_head_bob_observed
		and _verify_b9_bowl_clatter_heard
		and bowl_visit_completed,
		"B9 dog bowl visit skipped path, clatter, eating bob, or patrol resume."
	)
	print("B9 live SceneTree verification passed.")


func _run_b10_live_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = _player != null and _player.is_physics_processing()
	var pet_was_processing: bool = pet != null and pet.is_physics_processing()

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	if _player != null:
		_player.set_physics_process(false)
		_player.detach_from_carrier(verify_b10_sprint_start)
	if pet != null:
		pet.set_physics_process(false)
	for zone: String in LightSystem.VALID_ZONES:
		LightSystem.set_zone_enabled(zone, false)
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	global_position = verify_b10_sprint_parent_start
	_state = State.ROUTINE
	suspicion = 0.0
	_heard_since_last_tick = false
	_hunt_no_noise_elapsed = 0.0
	_has_checked_position = false
	_repeat_cooldown_remaining = 0.0
	_cancel_glance()
	_set_navigation_target(global_position, true)
	var outbound_path: Array[Vector3] = [
		verify_b10_sprint_start,
		Vector3(-5.75, 0.6, -0.8),
		Vector3(0.0, 0.6, -0.8),
		Vector3(6.0, 0.6, -0.8),
		verify_b10_sprint_fridge,
	]
	var sprint_path: Array[Vector3] = outbound_path.duplicate()
	for reverse_index in range(outbound_path.size() - 2, -1, -1):
		sprint_path.append(outbound_path[reverse_index])
	var path_index: int = 1
	var sprint_returning: bool = false
	var sprint_completed: bool = false
	var hunt_triggered: bool = false
	var hunt_first_time: float = INF
	var hunt_cone_wide: bool = false
	var hunt_color_observed: bool = false
	var hunt_retarget_observed: bool = false
	var hunt_exit_observed: bool = false
	var return_min_distance: float = INF
	var footstep_elapsed: float = 0.0
	var sprint_elapsed: float = 0.0
	var previous_clock_elapsed: float = 0.0
	Input.action_press("run")
	GameClock.start()
	for _frame_index in range(verify_max_physics_frames):
		await get_tree().physics_frame
		var clock_elapsed: float = GameClock.run_length - GameClock.time_remaining
		var frame_delta: float = maxf(clock_elapsed - previous_clock_elapsed, 0.0)
		previous_clock_elapsed = clock_elapsed
		sprint_elapsed = clock_elapsed
		var movement_remaining: float = _player.run_speed * frame_delta
		while movement_remaining > 0.0 and path_index < sprint_path.size():
			var target: Vector3 = sprint_path[path_index]
			var target_delta: Vector3 = target - _player.global_position
			target_delta.y = 0.0
			var target_distance: float = target_delta.length()
			if target_distance <= movement_remaining:
				_player.global_position = target
				movement_remaining -= target_distance
				path_index += 1
				if path_index == outbound_path.size():
					sprint_returning = true
			else:
				_player.global_position += (
					target_delta.normalized() * movement_remaining
				)
				movement_remaining = 0.0

		footstep_elapsed += frame_delta
		while footstep_elapsed >= _player.run_footstep_interval:
			footstep_elapsed -= _player.run_footstep_interval
			var raw_loudness: float = (
				_player.run_noise_multiplier
				* _player.hardwood_surface_multiplier
			)
			var mask: float = clampf(
				NoiseSystem.get_mask_at(_player.global_position),
				0.0,
				1.0
			)
			NoiseSystem.emit_noise(
				_player.global_position,
				raw_loudness * (1.0 - mask),
				_player
			)
		if _state == State.HUNT:
			hunt_triggered = true
			if hunt_first_time == INF:
				hunt_first_time = sprint_elapsed
			hunt_cone_wide = (
				hunt_cone_wide
				or is_equal_approx(
					_get_current_cone_angle(),
					found_cone_angle_degrees
				)
			)
			hunt_color_observed = (
				hunt_color_observed
				or (
					_cone_material != null
					and _cone_material.albedo_color
					== _color_with_alpha(cone_hunt_color, cone_hunt_alpha)
				)
			)
			hunt_retarget_observed = (
				hunt_retarget_observed
				or _flat_distance(
					_hunt_target_position,
					_player.global_position
				) <= _player.run_speed * _player.run_footstep_interval
			)
		elif hunt_triggered and _state == State.INVESTIGATE:
			hunt_exit_observed = true
		if sprint_returning:
			return_min_distance = minf(
				return_min_distance,
				_flat_distance(global_position, _player.global_position)
			)
		if path_index >= sprint_path.size():
			sprint_completed = true
			break
		if sprint_elapsed >= verify_b10_sprint_duration:
			break
	Input.action_release("run")

	_player.global_position = verify_observer_parking_position
	suspicion = hunt_threshold
	_state = State.ROUTINE
	_hunt_no_noise_elapsed = 0.0
	_heard_since_last_tick = false
	_begin_hunt(global_position)
	GameClock.start()
	var hunt_exit_elapsed: float = 0.0
	for _frame_index in range(verify_max_physics_frames):
		await get_tree().physics_frame
		hunt_exit_elapsed = GameClock.run_length - GameClock.time_remaining
		if _state == State.INVESTIGATE:
			hunt_exit_observed = true
			break
		if hunt_exit_elapsed >= hunt_timeout + 0.5:
			break
	for zone: String in LightSystem.VALID_ZONES:
		LightSystem.set_zone_enabled(zone, true)
	global_position = _row_position(routine_rows[0])
	_state = State.ROUTINE
	suspicion = 0.0
	_heard_since_last_tick = false
	_has_checked_position = false
	_repeat_cooldown_remaining = 0.0
	_glance_rng.seed = glance_random_seed
	_glance_count = 0
	_cancel_glance()
	_set_navigation_target(global_position, true)
	_player.global_position = verify_observer_parking_position
	GameClock.start()
	var glance_started: bool = false
	var glance_detected_player: bool = false
	var glance_returned: bool = false
	var glance_escalated: bool = false
	var glance_start_time: float = INF
	var glance_offset_degrees: float = 0.0
	var glance_max_suspicion: float = 0.0
	var glance_player_lit: bool = false
	var glance_player_planted: bool = false
	var glance_dynamic_light_active: bool = false
	var glance_light_id: String = "b10_verify_glance"
	var dwell_facing: Vector3 = _row_facing(routine_rows[0])
	for _frame_index in range(verify_max_physics_frames):
		await get_tree().physics_frame
		var glance_clock_elapsed: float = (
			GameClock.run_length - GameClock.time_remaining
		)
		if _glance_active and not glance_started:
			glance_started = true
			glance_start_time = glance_clock_elapsed
			glance_offset_degrees = rad_to_deg(
				dwell_facing.angle_to(_glance_direction)
			)
			for candidate_distance: float in [
				verify_b10_glance_player_distance,
				3.0,
				2.5,
				2.0,
				1.5,
				1.0,
			]:
				_player.global_position = (
					global_position
					+ _glance_direction * candidate_distance
				)
				_player.global_position.y = verify_b10_sprint_start.y
				if _has_clear_line_of_sight():
					glance_player_planted = true
					if (
						LightSystem.get_brightness_at(_player.global_position)
						<= brightness_threshold
					):
						LightSystem.register_dynamic_light(
							glance_light_id,
							_player.global_position
						)
						LightSystem.set_dynamic_light(
							glance_light_id,
							3.0,
							1.0
						)
						glance_dynamic_light_active = true
					break
		if glance_player_planted:
			glance_player_lit = (
				glance_player_lit
				or LightSystem.get_brightness_at(_player.global_position)
				> brightness_threshold
			)
			glance_max_suspicion = maxf(glance_max_suspicion, suspicion)
			if suspicion > 0.0 or _state == State.INVESTIGATE:
				glance_detected_player = true
				glance_escalated = _state == State.INVESTIGATE
				_player.global_position = verify_observer_parking_position
				glance_player_planted = false
				if glance_escalated:
					break
		if (
			glance_started
			and glance_detected_player
			and not _glance_active
		):
			var current_facing: Vector3 = -global_transform.basis.z
			current_facing.y = 0.0
			glance_returned = current_facing.normalized().dot(dwell_facing) >= 0.9
			if glance_returned:
				break
		if (
			glance_clock_elapsed
			>= verify_b10_glance_deadline + glance_duration + 3.0
		):
			break

	GameClock.running = false
	if glance_dynamic_light_active:
		LightSystem.set_dynamic_light(glance_light_id, 0.0, 0.0)
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		_player.set_physics_process(player_was_processing)
	if pet != null:
		pet.set_physics_process(pet_was_processing)

	var sprint_gate_passed: bool = (
		sprint_completed
		and hunt_triggered
		and hunt_cone_wide
		and hunt_color_observed
		and hunt_retarget_observed
		and return_min_distance < verify_b10_return_min_distance
		and hunt_exit_observed
	)
	var glance_gate_passed: bool = (
		glance_started
		and glance_start_time <= verify_b10_glance_deadline
		and glance_offset_degrees >= glance_min_offset_degrees
		and glance_offset_degrees <= glance_max_offset_degrees
		and glance_player_lit
		and glance_detected_player
		and (glance_returned or glance_escalated)
	)
	var verification_passed: bool = sprint_gate_passed and glance_gate_passed
	print(
		(
			"B10 live metrics: sprint=%.2f s, HUNT at %.2f s, "
			+ "return closest=%.2f m, hunt exit=%.2f s; "
			+ "glance at %.2f s / %.1f deg, suspicion=%.1f, "
			+ "returned=%s, escalated=%s."
		)
		% [
			sprint_elapsed,
			hunt_first_time,
			return_min_distance,
			hunt_exit_elapsed,
			glance_start_time,
			glance_offset_degrees,
			glance_max_suspicion,
			glance_returned,
			glance_escalated,
		]
	)
	await _settle_verification_audio()
	get_tree().quit(0 if verification_passed else 1)
	assert(sprint_completed, "B10 sprint bot did not complete its round trip.")
	assert(hunt_triggered, "B10 sprint bot never triggered HUNT.")
	assert(
		hunt_cone_wide and hunt_color_observed and hunt_retarget_observed,
		"B10 HUNT missed its wide cone, colour, or newest-noise retarget."
	)
	assert(
		return_min_distance < verify_b10_return_min_distance,
		"B10 HUNT did not close within 3 m on the return leg."
	)
	assert(hunt_exit_observed, "B10 HUNT did not fall back to INVESTIGATE.")
	assert(
		glance_started and glance_start_time <= verify_b10_glance_deadline,
		"B10 no couch glance occurred inside 20 s."
	)
	assert(
		glance_offset_degrees >= glance_min_offset_degrees
		and glance_offset_degrees <= glance_max_offset_degrees,
		"B10 couch glance was outside the 100-160 degree range."
	)
	assert(
		glance_player_lit and glance_detected_player,
		"B10 glance did not see the lit player behind the couch."
	)
	assert(
		glance_returned or glance_escalated,
		"B10 glance neither returned nor escalated after detection."
	)
	print("B10 live SceneTree verification passed.")


func _run_b13_live_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var original_navigation_ready: bool = _navigation_ready
	var original_debug_trace: bool = debug_perception_trace
	var player_was_processing: bool = _player != null and _player.is_physics_processing()
	var player_was_input_locked: bool = _player != null and _player.input_locked
	var player_start_position: Vector3 = (
		_player.global_position if _player != null else Vector3.ZERO
	)
	var pet_was_processing: bool = pet != null and pet.is_physics_processing()
	var verification_light_id: String = "b13_verify_walk_by"

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	debug_perception_trace = true
	_debug_trace_initialized = false
	if pet != null:
		pet.set_physics_process(false)
	if _player != null:
		if _player.is_attached_to_carrier():
			_player.detach_from_carrier(player_start_position)
		_player.set_input_locked(true)
		_player.set_physics_process(false)
	for zone: String in LightSystem.VALID_ZONES:
		LightSystem.set_zone_enabled(zone, true)

	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	var walk_by_started_in_epilogue: bool = false
	var walk_by_lit: bool = false
	var walk_by_seen: bool = false
	var walk_by_aborted_epilogue: bool = false
	var walk_by_abort_state: StringName = &""
	var walk_by_suspicion: float = 0.0
	if _player != null:
		suspicion = 0.0
		global_position = verify_b13_walk_parent_position
		var walk_forward: Vector3 = post_deposit_hall_direction
		walk_forward.y = 0.0
		walk_forward = (
			walk_forward.normalized()
			if walk_forward.length_squared() > 0.0
			else Vector3.RIGHT
		)
		var walk_right: Vector3 = Vector3(
			-walk_forward.z,
			0.0,
			walk_forward.x
		)
		rotation.y = atan2(-walk_forward.x, -walk_forward.z)
		_cone_yaw_degrees = 0.0
		_post_deposit_path_started = true
		_set_state(State.POST_DEPOSIT_HALL_WALK)
		_set_navigation_target(_get_post_deposit_hall_target(), true)
		var walk_center: Vector3 = (
			global_position
			+ walk_forward * verify_b13_walk_ahead_distance
		)
		walk_center.y = player_start_position.y
		LightSystem.register_dynamic_light(verification_light_id, walk_center)
		LightSystem.set_dynamic_light(
			verification_light_id,
			verify_b13_light_radius,
			verify_b13_light_energy
		)
		_player.global_position = (
			walk_center
			- walk_right * verify_b13_walk_lateral_distance
		)
		walk_by_started_in_epilogue = _is_post_deposit_state()
		GameClock.start()
		for _frame_index in range(verify_b13_max_physics_frames):
			var walk_elapsed_before_tick: float = (
				GameClock.run_length - GameClock.time_remaining
			)
			var walk_weight: float = clampf(
				walk_elapsed_before_tick / maxf(verify_b13_walk_duration, 0.001),
				0.0,
				1.0
			)
			_player.global_position = (
				walk_center
				+ walk_right
				* lerpf(
					-verify_b13_walk_lateral_distance,
					verify_b13_walk_lateral_distance,
					walk_weight
				)
			)
			await get_tree().physics_frame
			walk_by_lit = (
				walk_by_lit
				or LightSystem.get_brightness_at(_player.global_position)
				> brightness_threshold
			)
			walk_by_suspicion = maxf(walk_by_suspicion, suspicion)
			walk_by_seen = walk_by_seen or suspicion > 0.0
			if not _is_post_deposit_state():
				walk_by_aborted_epilogue = true
				walk_by_abort_state = get_state_name()
				break
			if (
				GameClock.run_length - GameClock.time_remaining
				>= verify_b13_walk_duration
			):
				break

	var loud_hearing_registered: bool = false
	var loud_hearing_aborted_epilogue: bool = false
	var loud_hearing_abort_state: StringName = &""
	if _player != null:
		_player.global_position = verify_observer_parking_position
		suspicion = 0.0
		_post_deposit_elapsed = 0.0
		_set_state(State.POST_DEPOSIT_PEEK)
		GameClock.start()
		NoiseSystem.emit_noise(
			global_position,
			verify_b13_noise_loudness,
			_player
		)
		loud_hearing_registered = _heard_since_last_tick
		loud_hearing_aborted_epilogue = not _is_post_deposit_state()
		loud_hearing_abort_state = get_state_name()
		await get_tree().physics_frame

	var entered_lunge_range: bool = false
	var lunge_motion_observed: bool = false
	var juke_caught: bool = false
	var catch_elapsed_after_close: float = INF
	var juke_min_distance: float = INF
	var juke_direction_changes: int = 0
	var lunge_start_position: Vector3 = Vector3.ZERO
	if _player != null:
		Engine.time_scale = maxf(verify_b13_chase_time_scale, 0.001)
		Engine.physics_ticks_per_second = maxi(
			verify_b13_chase_physics_ticks_per_second,
			60
		)
		for _warmup_frame in range(verify_b13_chase_warmup_frames):
			await get_tree().physics_frame
		suspicion = suspicion_max
		global_position = verify_b13_juke_parent_position
		var chase_forward: Vector3 = verify_point_blank_facing
		chase_forward.y = 0.0
		chase_forward = (
			chase_forward.normalized()
			if chase_forward.length_squared() > 0.0
			else Vector3.LEFT
		)
		rotation.y = atan2(-chase_forward.x, -chase_forward.z)
		_player.detach_from_carrier(
			global_position + chase_forward * verify_b13_juke_start_distance
		)
		_player.set_input_locked(true)
		_player.set_physics_process(false)
		_found_no_sight_elapsed = 0.0
		_state = State.FOUND
		_navigation_ready = false
		lunge_start_position = global_position
		var juke_center_z: float = _player.global_position.z
		var juke_direction: float = 1.0
		var previous_chase_elapsed: float = 0.0
		GameClock.start()
		for _frame_index in range(verify_b13_max_physics_frames):
			await get_tree().physics_frame
			var chase_elapsed: float = (
				GameClock.run_length - GameClock.time_remaining
			)
			var chase_delta: float = maxf(
				chase_elapsed - previous_chase_elapsed,
				0.0
			)
			previous_chase_elapsed = chase_elapsed
			var current_distance: float = _flat_distance(
				global_position,
				_player.global_position
			)
			juke_min_distance = minf(juke_min_distance, current_distance)
			if current_distance <= found_lunge_distance:
				entered_lunge_range = true
			lunge_motion_observed = (
				lunge_motion_observed
				or global_position.distance_to(lunge_start_position) > 0.1
			)
			if _state == State.CARRY and _player.is_attached_to_carrier():
				juke_caught = true
				catch_elapsed_after_close = chase_elapsed
				break
			var next_player_position: Vector3 = _player.global_position
			next_player_position.z += (
				juke_direction
				* maxf(verify_b13_juke_speed, 0.0)
				* chase_delta
			)
			if (
				next_player_position.z
				>= juke_center_z + verify_b13_juke_half_span
			):
				next_player_position.z = (
					juke_center_z + verify_b13_juke_half_span
				)
				juke_direction = -1.0
				juke_direction_changes += 1
			elif (
				next_player_position.z
				<= juke_center_z - verify_b13_juke_half_span
			):
				next_player_position.z = (
					juke_center_z - verify_b13_juke_half_span
				)
				juke_direction = 1.0
				juke_direction_changes += 1
			_player.global_position = next_player_position
			if chase_elapsed >= verify_b13_catch_duration:
				break

	var walk_by_gate_passed: bool = (
		walk_by_started_in_epilogue
		and walk_by_lit
		and walk_by_seen
		and walk_by_aborted_epilogue
		and (
			walk_by_abort_state == &"INVESTIGATE"
			or walk_by_abort_state == &"FOUND"
			or walk_by_abort_state == &"CARRY"
		)
	)
	var loud_hearing_gate_passed: bool = (
		loud_hearing_registered
		and loud_hearing_aborted_epilogue
		and (
			loud_hearing_abort_state == &"CURIOUS"
			or loud_hearing_abort_state == &"INVESTIGATE"
			or loud_hearing_abort_state == &"HUNT"
			or loud_hearing_abort_state == &"FOUND"
		)
	)
	var juke_gate_passed: bool = (
		entered_lunge_range
		and lunge_motion_observed
		and juke_direction_changes > 0
		and juke_caught
		and catch_elapsed_after_close <= verify_b13_catch_duration
	)
	var verification_passed: bool = (
		walk_by_gate_passed
		and loud_hearing_gate_passed
		and juke_gate_passed
	)

	GameClock.running = false
	LightSystem.set_dynamic_light(verification_light_id, 0.0, 0.0)
	_navigation_ready = original_navigation_ready
	debug_perception_trace = original_debug_trace
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _player != null:
		if _player.is_attached_to_carrier():
			_player.detach_from_carrier(player_start_position)
		else:
			_player.global_position = player_start_position
		_player.set_input_locked(player_was_input_locked)
		_player.set_physics_process(player_was_processing)
	if pet != null:
		pet.set_physics_process(pet_was_processing)

	print(
		(
			"B13 live metrics: epilogue sight=%s, suspicion=%.1f, abort=%s; "
			+ "loud hearing=%s, abort=%s; juke closest=%.2f m, "
			+ "turns=%d, direct motion=%s, caught=%.2f s."
		)
		% [
			walk_by_seen,
			walk_by_suspicion,
			walk_by_abort_state,
			loud_hearing_registered,
			loud_hearing_abort_state,
			juke_min_distance,
			juke_direction_changes,
			lunge_motion_observed,
			catch_elapsed_after_close,
		]
	)
	await _settle_verification_audio()
	get_tree().quit(0 if verification_passed else 1)
	assert(
		walk_by_gate_passed,
		"B13 lit walk-by did not abort the post-deposit epilogue."
	)
	assert(
		loud_hearing_gate_passed,
		"B13 loud noise did not abort the post-deposit epilogue."
	)
	assert(entered_lunge_range, "B13 juking bot never entered the 2.5 m lunge range.")
	assert(juke_direction_changes > 0, "B13 chase bot never completed a juke.")
	assert(lunge_motion_observed, "B13 FOUND did not move with navigation disabled.")
	assert(juke_caught, "B13 juking bot was not caught.")
	assert(
		catch_elapsed_after_close <= verify_b13_catch_duration,
		"B13 juking bot was not caught inside 6 s."
	)
	print("B13 live SceneTree verification passed.")


func _run_b14_live_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var player_was_processing: bool = (
		_player != null and _player.is_physics_processing()
	)
	var player_was_input_locked: bool = (
		_player != null and _player.input_locked
	)
	var player_start_position: Vector3 = (
		_player.global_position if _player != null else Vector3.ZERO
	)
	var pet_was_processing: bool = (
		pet != null and pet.is_physics_processing()
	)
	var original_facing_turn_speed: float = facing_turn_speed

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	if _player != null:
		if _player.is_attached_to_carrier():
			_player.detach_from_carrier(player_start_position)
		_player.set_input_locked(true)
		_player.set_physics_process(false)
		_player.global_position = verify_observer_parking_position
	if pet != null:
		pet.set_physics_process(false)
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	var dining_switch: DinnerWorldSwitch
	for node: Node in get_tree().get_nodes_in_group("world_switch"):
		var candidate: DinnerWorldSwitch = node as DinnerWorldSwitch
		if candidate != null and candidate.switch_id == &"dining":
			dining_switch = candidate
			break
	var click_started_investigate: bool = false
	var tv_stopped_for_listening: bool = false
	var click_restored: bool = false
	var returned_to_couch: bool = false
	var tv_restored_at_couch: bool = false
	var visual_anomaly_detected: bool = false
	var phase_two_tv_stayed_off: bool = false
	var tv_bed: AudioStreamPlayer3D = (
		get_node_or_null("../AudioDirector/TVBed") as AudioStreamPlayer3D
	)
	var audio_director: DinnerAudioDirector = (
		get_node_or_null("../AudioDirector") as DinnerAudioDirector
	)
	var tv_glow: Node3D = (
		_level.get_node_or_null(tv_glow_node_name) as Node3D
		if _level != null
		else null
	)

	if dining_switch != null:
		GameClock.start()
		dining_switch.set_state(true, false)
		global_position = dining_switch.global_position + Vector3(1.0, -0.3, 0.0)
		_state = State.ROUTINE
		suspicion = 0.0
		_clear_light_anomaly()
		_tv_suppressed_for_listening = false
		_set_navigation_target(global_position, true)
		_set_tv_enabled(true)
		if tv_bed != null and not tv_bed.playing:
			tv_bed.play()
		dining_switch.set_state(false, true)
		click_started_investigate = (
			_state == State.INVESTIGATE
			and _light_anomaly_switch == dining_switch
		)
		tv_stopped_for_listening = (
			_tv_suppressed_for_listening
			and (tv_bed == null or not tv_bed.playing)
			and (tv_glow == null or not tv_glow.visible)
			and NoiseSystem.get_mask_at(Vector3(-2.75, 0.0, -4.1))
			<= 0.001
		)
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			click_restored = dining_switch.is_on
			returned_to_couch = (
				_flat_distance(global_position, tv_couch_position)
				<= tv_couch_settle_distance
			)
			tv_restored_at_couch = (
				returned_to_couch
				and not _tv_suppressed_for_listening
				and (tv_bed == null or tv_bed.playing)
				and (tv_glow == null or tv_glow.visible)
				and NoiseSystem.get_mask_at(Vector3(-2.75, 0.0, -4.1))
				> 0.001
			)
			if click_restored and tv_restored_at_couch:
				break
			if (
				GameClock.run_length - GameClock.time_remaining
				>= verify_b14_timeout
			):
				break

		dining_switch.set_state(false, false)
		var observation_position: Vector3 = (
			_get_switch_observation_position(dining_switch)
		)
		var observation_direction: Vector3 = (
			observation_position - tv_couch_position
		)
		observation_direction.y = 0.0
		global_position = tv_couch_position
		rotation.y = atan2(
			-observation_direction.normalized().x,
			-observation_direction.normalized().z
		)
		facing_turn_speed = 0.0
		_state = State.ROUTINE
		_light_anomaly_scan_elapsed = light_anomaly_scan_interval
		_set_navigation_target(global_position, true)
		await get_tree().physics_frame
		visual_anomaly_detected = (
			_state == State.INVESTIGATE
			and _light_anomaly_switch == dining_switch
		)
		if _light_anomaly_switch != null:
			_restore_light_anomaly()
		_finish_investigate()
		facing_turn_speed = original_facing_turn_speed

		GameClock.start()
		GameClock.scrub(121.0)
		_set_state(State.INVESTIGATE)
		await get_tree().physics_frame
		global_position = tv_couch_position
		_set_navigation_target(global_position, true)
		_set_state(State.ROUTINE)
		for _frame_index in range(4):
			await get_tree().physics_frame
		phase_two_tv_stayed_off = (
			GameClock.phase >= 2
			and (tv_bed == null or not tv_bed.playing)
			and (tv_glow == null or not tv_glow.visible)
			and NoiseSystem.get_mask_at(Vector3(-2.75, 0.0, -4.1))
			<= 0.001
		)

	var punishment_light_on: bool = false
	if _kid_hall_switch != null:
		GameClock.start()
		_kid_hall_switch.set_state(false, false)
		_kid_hall_punishment_active = false
		_activate_punishment_light()
		punishment_light_on = (
			_kid_hall_punishment_active and _kid_hall_switch.is_on
		)

	var room_entered: bool = false
	var room_dwell_observed: bool = false
	var room_protest_observed: bool = false
	var room_exit_observed: bool = false
	var room_check_completed: bool = false
	var room_dwell_elapsed: float = 0.0
	var room_parent_voice_observed: bool = false
	var room_parent_icon_observed: bool = false
	var room_kid_voice_observed: bool = false
	if _player != null and _bedroom_door != null:
		_player.global_position = verify_observer_parking_position
		global_position = _get_post_deposit_hall_target()
		_bedroom_door.openness = post_deposit_reopen_openness
		_post_deposit_elapsed = post_deposit_peek_duration
		_post_deposit_path_started = false
		_set_state(State.POST_DEPOSIT_PEEK)
		GameClock.start()
		var room_check_start: float = 0.0
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			var elapsed: float = GameClock.run_length - GameClock.time_remaining
			if _state == State.POST_DEPOSIT_ROOM_ENTER:
				room_entered = true
			elif _state == State.POST_DEPOSIT_ROOM_DWELL:
				if not room_dwell_observed:
					room_check_start = elapsed
				room_dwell_observed = true
				if audio_director != null:
					room_parent_voice_observed = (
						room_parent_voice_observed
						or audio_director.is_voice_pool_playing(
							&"parent_bed_check"
						)
					)
				room_parent_icon_observed = (
					room_parent_icon_observed
					or (
						room_parent_voice_observed
						and _voice_indicator != null
						and _voice_indicator.visible
					)
				)
				room_dwell_elapsed = maxf(
					room_dwell_elapsed,
					elapsed - room_check_start
				)
				room_protest_observed = (
					room_protest_observed or _post_deposit_protest_emitted
				)
				if audio_director != null and _post_deposit_protest_emitted:
					room_kid_voice_observed = (
						room_kid_voice_observed
						or audio_director.is_voice_pool_playing(
							&"kid_room_protest"
						)
					)
			elif _state == State.POST_DEPOSIT_ROOM_EXIT:
				room_exit_observed = true
			elif room_entered and _state == State.ROUTINE:
				room_check_completed = true
				break
			if elapsed >= verify_b14_timeout:
				break

	_verify_b14_visual_noise_count = 0
	if not NoiseSystem.noise_emitted.is_connected(_capture_b14_visual_noise):
		NoiseSystem.noise_emitted.connect(_capture_b14_visual_noise)
	show_parent_voice_indicator(verify_b14_voice_duration)
	var voice_indicator_observed: bool = false
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame
		voice_indicator_observed = (
			voice_indicator_observed
			or (
				_voice_indicator != null
				and _voice_indicator.visible
			)
		)
	if NoiseSystem.noise_emitted.is_connected(_capture_b14_visual_noise):
		NoiseSystem.noise_emitted.disconnect(_capture_b14_visual_noise)
	var voice_indicator_silent: bool = _verify_b14_visual_noise_count == 0

	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	facing_turn_speed = original_facing_turn_speed
	if _player != null:
		_player.global_position = player_start_position
		_player.set_input_locked(player_was_input_locked)
		_player.set_physics_process(player_was_processing)
	if pet != null:
		pet.set_physics_process(pet_was_processing)

	var epilogue_gate_passed: bool = (
		punishment_light_on
		and room_entered
		and room_dwell_observed
		and room_protest_observed
		and room_dwell_elapsed >= post_deposit_room_dwell_duration - 0.1
		and room_exit_observed
		and room_check_completed
		and room_parent_voice_observed
		and room_parent_icon_observed
		and room_kid_voice_observed
	)
	var verification_passed: bool = (
		click_started_investigate
		and tv_stopped_for_listening
		and click_restored
		and tv_restored_at_couch
		and visual_anomaly_detected
		and phase_two_tv_stayed_off
		and epilogue_gate_passed
		and voice_indicator_observed
		and voice_indicator_silent
	)
	print(
		(
			"B14 live metrics: click investigate=%s, restored=%s, "
			+ "TV off/on=%s/%s, visual anomaly=%s, phase2 off=%s; "
			+ "punishment=%s, room enter/dwell/protest/exit=%s/%s/%s/%s "
			+ "(%.2f s), resumed=%s; room VO parent/icon/kid=%s/%s/%s; "
			+ "VO icon=%s, noise events=%d."
		)
		% [
			click_started_investigate,
			click_restored,
			tv_stopped_for_listening,
			tv_restored_at_couch,
			visual_anomaly_detected,
			phase_two_tv_stayed_off,
			punishment_light_on,
			room_entered,
			room_dwell_observed,
			room_protest_observed,
			room_exit_observed,
			room_dwell_elapsed,
			room_check_completed,
			room_parent_voice_observed,
			room_parent_icon_observed,
			room_kid_voice_observed,
			voice_indicator_observed,
			_verify_b14_visual_noise_count,
		]
	)
	await _settle_verification_audio()
	get_tree().quit(0 if verification_passed else 1)
	assert(click_started_investigate, "B14 switch click did not investigate.")
	assert(click_restored, "B14 parent did not restore the expected light state.")
	assert(tv_stopped_for_listening, "B14 parent did not silence the TV to listen.")
	assert(tv_restored_at_couch, "B14 TV did not return at the couch.")
	assert(visual_anomaly_detected, "B14 cone did not notice an early-dark zone.")
	assert(phase_two_tv_stayed_off, "B14 phase 2 TV shutdown was not permanent.")
	assert(epilogue_gate_passed, "B14 escaped-child room check did not complete.")
	assert(
		room_parent_voice_observed
		and room_parent_icon_observed
		and room_kid_voice_observed,
		"B14 room-dwell parent/icon/kid VO wiring did not play in order."
	)
	assert(
		voice_indicator_observed and voice_indicator_silent,
		"B14 parent VO icon was missing or emitted gameplay noise."
	)
	print("B14 live SceneTree verification passed.")


func _run_b15_live_verification() -> void:
	var pet: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var original_debug_hearing: bool = debug_hearing_trace
	var original_routine_rows: Array[Dictionary] = routine_rows.duplicate(true)
	var player_was_processing: bool = (
		_player != null and _player.is_physics_processing()
	)
	var player_was_input_locked: bool = (
		_player != null and _player.input_locked
	)
	var player_start_position: Vector3 = (
		_player.global_position if _player != null else Vector3.ZERO
	)
	var pet_was_processing: bool = (
		pet != null and pet.is_physics_processing()
	)
	var original_door_duration: float = (
		_bedroom_door.sneak_open_duration
		if _bedroom_door != null
		else 0.0
	)
	var original_door_openness: float = (
		_bedroom_door.openness if _bedroom_door != null else 0.0
	)

	Engine.time_scale = maxf(verify_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(verify_physics_ticks_per_second, 60)
	debug_hearing_trace = true
	if _player != null:
		if _player.is_attached_to_carrier():
			_player.detach_from_carrier(player_start_position)
		_player.set_input_locked(true)
		_player.set_physics_process(false)
		_player.global_position = verify_observer_parking_position
	if pet != null:
		pet.set_physics_process(false)
	for _frame_index in range(verify_warmup_frames):
		await get_tree().physics_frame

	var first_door_curious: bool = false
	var first_door_stayed_put: bool = false
	var first_door_turned: bool = false
	var first_door_max_displacement: float = 0.0
	var first_door_counted_events: int = 0
	var first_door_suspicion: float = 0.0
	var second_door_investigated: bool = false
	var second_door_movement: float = 0.0
	var switch_contribution_at_door_test: float = 0.0
	if _bedroom_door != null:
		var from_door: Vector3 = tv_couch_position - _bedroom_door.global_position
		from_door.y = 0.0
		if from_door.length_squared() <= 0.0:
			from_door = Vector3.RIGHT
		var door_test_position: Vector3 = (
			_bedroom_door.global_position
			+ from_door.normalized() * verify_b15_door_distance
		)
		door_test_position.y = verify_carry_parent_position.y
		routine_rows = [
			{
				"time": 0.0,
				"position": door_test_position,
				"dwell": GameClock.run_length,
				"facing": -from_door.normalized(),
			},
		]
		global_position = door_test_position
		rotation.y = atan2(
			-from_door.normalized().x,
			-from_door.normalized().z
		)
		_cone_yaw_degrees = 0.0
		_state = State.ROUTINE
		suspicion = 0.0
		_reset_hearing_interest_for_verification()
		_set_navigation_target(global_position, true)
		_bedroom_door.close_immediately()
		_bedroom_door.sneak_open_duration = maxf(
			_bedroom_door.rush_open_duration,
			0.001
		)
		GameClock.start()
		var first_rush_start: Vector3 = global_position
		var first_count_start: int = _verify_b15_counted_events
		_bedroom_door.open_to(1.0)
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			first_door_max_displacement = maxf(
				first_door_max_displacement,
				_flat_distance(global_position, first_rush_start)
			)
			first_door_suspicion = maxf(first_door_suspicion, suspicion)
			if (
				GameClock.run_length - GameClock.time_remaining
				>= verify_b15_rush_duration
			):
				break
		first_door_counted_events = (
			_verify_b15_counted_events - first_count_start
		)
		first_door_curious = _state == State.CURIOUS
		var first_delay_start: float = (
			GameClock.run_length - GameClock.time_remaining
		)
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			first_door_max_displacement = maxf(
				first_door_max_displacement,
				_flat_distance(global_position, first_rush_start)
			)
			if (
				GameClock.run_length - GameClock.time_remaining
				- first_delay_start
				>= verify_b15_second_cue_delay
			):
				break
		var toward_door: Vector3 = (
			_bedroom_door.global_position - global_position
		)
		toward_door.y = 0.0
		var parent_forward: Vector3 = -global_transform.basis.z
		parent_forward.y = 0.0
		first_door_turned = (
			parent_forward.normalized().dot(toward_door.normalized())
			>= verify_b15_turn_dot
		)
		first_door_stayed_put = (
			first_door_max_displacement <= verify_b15_no_walk_tolerance
			and _state == State.CURIOUS
			and suspicion < hunt_threshold
		)

		_bedroom_door.close_immediately()
		var second_rush_start: Vector3 = global_position
		var second_rush_start_time: float = (
			GameClock.run_length - GameClock.time_remaining
		)
		_bedroom_door.open_to(1.0)
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			second_door_investigated = (
				second_door_investigated
				or _state == State.INVESTIGATE
			)
			second_door_movement = maxf(
				second_door_movement,
				_flat_distance(global_position, second_rush_start)
			)
			var second_elapsed: float = (
				GameClock.run_length - GameClock.time_remaining
				- second_rush_start_time
			)
			if (
				second_door_investigated
				and second_door_movement >= verify_b15_investigate_move
			):
				break
			if second_elapsed >= verify_b15_timeout:
				break

		if _kid_hall_switch != null:
			var switch_radius: float = minf(
				1.5 * ring_radius_per_loudness,
				ring_radius_cap
			)
			var switch_distance: float = door_test_position.distance_to(
				_kid_hall_switch.global_position
			)
			if switch_distance < switch_radius:
				switch_contribution_at_door_test = (
					1.5
					* noise_suspicion_multiplier
					* (1.0 - switch_distance / switch_radius)
				)
		_bedroom_door.close_immediately()

	var first_bark_curious: bool = false
	var first_bark_stayed_put: bool = false
	var first_bark_turned: bool = false
	var first_bark_suspicion: float = 0.0
	var first_bark_displacement: float = 0.0
	var second_bark_investigated: bool = false
	var second_bark_movement: float = 0.0
	if pet != null:
		var bark_parent_position: Vector3 = verify_bark_parent_position
		var bark_position: Vector3 = verify_bark_pet_position
		routine_rows = [
			{
				"time": 0.0,
				"position": bark_parent_position,
				"dwell": GameClock.run_length,
				"facing": Vector3.LEFT,
			},
		]
		global_position = bark_parent_position
		rotation.y = 0.0
		pet.global_position = bark_position
		_state = State.ROUTINE
		suspicion = 0.0
		_reset_hearing_interest_for_verification()
		_set_navigation_target(global_position, true)
		GameClock.start()
		var first_bark_start: Vector3 = global_position
		pet.bark()
		first_bark_curious = _state == State.CURIOUS
		first_bark_suspicion = suspicion
		var bark_delay_start: float = (
			GameClock.run_length - GameClock.time_remaining
		)
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			if (
				GameClock.run_length - GameClock.time_remaining
				- bark_delay_start
				>= verify_b15_second_cue_delay
			):
				break
		first_bark_stayed_put = (
			_flat_distance(global_position, first_bark_start)
			<= verify_b15_no_walk_tolerance
		)
		first_bark_displacement = _flat_distance(
			global_position,
			first_bark_start
		)
		var toward_bark: Vector3 = bark_position - global_position
		toward_bark.y = 0.0
		var bark_forward: Vector3 = -global_transform.basis.z
		bark_forward.y = 0.0
		first_bark_turned = (
			bark_forward.normalized().dot(toward_bark.normalized())
			>= verify_b15_turn_dot
		)
		var second_bark_start: Vector3 = global_position
		var second_bark_start_time: float = (
			GameClock.run_length - GameClock.time_remaining
		)
		pet.bark()
		for _frame_index in range(verify_max_physics_frames):
			await get_tree().physics_frame
			second_bark_investigated = (
				second_bark_investigated
				or _state == State.INVESTIGATE
			)
			second_bark_movement = maxf(
				second_bark_movement,
				_flat_distance(global_position, second_bark_start)
			)
			var bark_elapsed: float = (
				GameClock.run_length - GameClock.time_remaining
				- second_bark_start_time
			)
			if (
				second_bark_investigated
				and second_bark_movement >= verify_b15_investigate_move
			):
				break
			if bark_elapsed >= verify_b15_timeout:
				break

	var door_gate_passed: bool = (
		first_door_curious
		and first_door_stayed_put
		and first_door_turned
		and first_door_counted_events >= 2
		and first_door_counted_events <= 4
		and second_door_investigated
		and second_door_movement >= verify_b15_investigate_move
	)
	var bark_gate_passed: bool = (
		first_bark_curious
		and first_bark_stayed_put
		and first_bark_turned
		and second_bark_investigated
		and second_bark_movement >= verify_b15_investigate_move
	)
	var verification_passed: bool = door_gate_passed and bark_gate_passed

	GameClock.running = false
	routine_rows = original_routine_rows
	debug_hearing_trace = original_debug_hearing
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if _bedroom_door != null:
		_bedroom_door.sneak_open_duration = original_door_duration
		_bedroom_door.close_immediately()
		_bedroom_door.openness = original_door_openness
	if _player != null:
		_player.global_position = player_start_position
		_player.set_input_locked(player_was_input_locked)
		_player.set_physics_process(player_was_processing)
	if pet != null:
		pet.set_physics_process(pet_was_processing)

	print(
		(
			"B15 live metrics: first door state=%s, counted=%d, "
			+ "suspicion=%.1f, turn=%s, drift=%.3f m; second door "
			+ "investigate=%s, move=%.2f m; switch-at-test=%.1f; "
			+ "first bark state=%s, suspicion=%.1f, turn=%s, "
			+ "drift=%.3f m; second bark investigate=%s, move=%.2f m."
		)
		% [
			&"CURIOUS" if first_door_curious else get_state_name(),
			first_door_counted_events,
			first_door_suspicion,
			first_door_turned,
			first_door_max_displacement,
			second_door_investigated,
			second_door_movement,
			switch_contribution_at_door_test,
			&"CURIOUS" if first_bark_curious else get_state_name(),
			first_bark_suspicion,
			first_bark_turned,
			first_bark_displacement,
			second_bark_investigated,
			second_bark_movement,
		]
	)
	await _settle_verification_audio()
	get_tree().quit(0 if verification_passed else 1)
	assert(
		door_gate_passed,
		"B15 rushed door did not produce CURIOUS then INVESTIGATE."
	)
	assert(
		bark_gate_passed,
		"B15 two barks did not produce CURIOUS then INVESTIGATE."
	)
	print("B15 live SceneTree verification passed.")


func _reset_hearing_interest_for_verification() -> void:
	_source_next_hearing_time.clear()
	_source_last_event_time.clear()
	_clear_interest()
	_curiosity_count = 0
	_verify_b15_counted_events = 0


func _settle_verification_audio() -> void:
	var audio_players: Array[Node] = []
	audio_players.append_array(
		get_tree().root.find_children("*", "AudioStreamPlayer", true, false)
	)
	audio_players.append_array(
		get_tree().root.find_children("*", "AudioStreamPlayer2D", true, false)
	)
	audio_players.append_array(
		get_tree().root.find_children("*", "AudioStreamPlayer3D", true, false)
	)
	for node in audio_players:
		node.call("stop")
		node.set("stream", null)
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout


func _get_live_cone_hit_distances(cone_angle_degrees: float) -> Array[float]:
	var hit_distances: Array[float] = []
	if _vision_cone == null:
		return hit_distances
	var ray_count: int = maxi(cone_raycast_count, 2)
	var half_angle_radians: float = deg_to_rad(cone_angle_degrees * 0.5)
	for ray_index in range(ray_count):
		var ray_weight: float = float(ray_index) / float(ray_count - 1)
		var ray_angle: float = lerpf(
			-half_angle_radians,
			half_angle_radians,
			ray_weight
		)
		var local_direction: Vector3 = Vector3.FORWARD.rotated(
			Vector3.UP,
			ray_angle
		)
		var world_direction: Vector3 = (
			_vision_cone.global_transform.basis * local_direction
		)
		world_direction.y = 0.0
		world_direction = world_direction.normalized()
		hit_distances.append(_get_static_hit_distance(world_direction))
	return hit_distances


func _capture_b8_noise(_pos: Vector3, loudness: float, source: Node) -> void:
	if source == _bedroom_door and loudness > 0.0:
		_verify_b8_door_creak_heard = true


func _capture_b9_noise(_pos: Vector3, loudness: float, source: Node) -> void:
	if source is DinnerPet and is_equal_approx(loudness, source.bowl_clatter_loudness):
		_verify_b9_bowl_clatter_heard = true


func _capture_b14_visual_noise(
	_pos: Vector3,
	_loudness: float,
	_source: Node
) -> void:
	_verify_b14_visual_noise_count += 1


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


func _row_door(row: Dictionary) -> StringName:
	return row.get("door", &"") as StringName
