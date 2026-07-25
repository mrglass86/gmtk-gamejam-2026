extends Node
class_name PhaseDirector

## Applies the whole countdown world state. Since the 2026-07-24
## "Scheduled shutdowns are parent-initiated at the fixture" ruling, a live
## phase boundary no longer writes the shutdown lines directly: it ARMS one
## errand per phase and the parent performs it at the controlling fixture
## or switch; only completion applies the zone/ambient/visibility change.
## Direct apply_phase calls and debug scrubs force-complete every armed
## errand, so scrubbing and verify harnesses still land the pure end-state
## the old sweep produced.

## Emitted whenever a shutdown effect applies. performed=true means the
## parent physically did it (play presentation); false means a scrub or
## direct apply_phase force-completed it (state only, no sound).
signal shutdown_errand_completed(errand_id: StringName, performed: bool)

const SHUTDOWN_ERRAND_PHASES: Dictionary = {
	&"living": 1,
	&"tv": 2,
	&"kitchen": 3,
	&"dining": 4,
	&"foyer": 4,
}
const SHUTDOWN_ERRAND_ORDER: Array[StringName] = [
	&"living",
	&"tv",
	&"kitchen",
	&"dining",
	&"foyer",
]

@export_node_path("Node3D") var level_path: NodePath = NodePath("../Level")
@export_node_path("DinnerDoor") var fridge_path: NodePath = NodePath("../Fridge")
@export_node_path("OmniLight3D") var fridge_light_path: NodePath = NodePath(
	"../Fridge/SpillLight"
)

@export_group("TV Flicker")
@export_range(0.0, 0.25) var tv_flicker_amount: float = 0.16
@export var tv_flicker_speed: float = 12.0

@export_group("Shutdown Errands")
## A phase_changed arriving with a clock jump larger than this is a scrub,
## a direct time write, or a restart; it force-completes instead of arming.
## Live boundaries move the clock by one frame's delta, far below this.
@export var scrub_detection_jump: float = 5.0

var _level: Node3D
var _fridge: DinnerDoor
var _fridge_light: OmniLight3D
var _tv_glow: AreaLight3D
var _tv_base_energy: float = 0.0
var _tv_flicker_time: float = 0.0
var _previous_fridge_openness: float = 0.0
var _current_phase: int = 0
var _pending_errands: Array[StringName] = []
var _applied_effects: Dictionary = {}
var _last_observed_time_remaining: float = -1.0
# B21 stands the parent in a replaced routine row for a ~120 s live memory
# wait; errand walks during that window could sweep its cone across the
# staged dining anomaly. Under that one harness, boundaries keep the legacy
# instant sweep. Same in-game-code precedent as the --verify-b15 counter.
var _legacy_timer_mode: bool = false


func _ready() -> void:
	_level = get_node_or_null(level_path) as Node3D
	_fridge = get_node_or_null(fridge_path) as DinnerDoor
	_fridge_light = get_node_or_null(fridge_light_path) as OmniLight3D
	_legacy_timer_mode = OS.get_cmdline_user_args().has("--verify-b21")
	if _level != null:
		_tv_glow = _level.get_node_or_null("TVGlow") as AreaLight3D
	if _tv_glow != null:
		_tv_base_energy = _tv_glow.light_energy
	if _fridge != null:
		_previous_fridge_openness = _fridge.openness
	_last_observed_time_remaining = GameClock.time_remaining
	apply_fridge_open_rate(0.0)
	if not GameClock.phase_changed.is_connected(_on_clock_phase_changed):
		GameClock.phase_changed.connect(_on_clock_phase_changed)
	apply_phase.call_deferred(GameClock.phase)


func _process(delta: float) -> void:
	_last_observed_time_remaining = GameClock.time_remaining
	if _tv_glow == null or not _tv_glow.visible:
		return
	_tv_flicker_time += delta
	apply_tv_flicker()


func _physics_process(delta: float) -> void:
	if _fridge == null:
		return
	var current_openness: float = _fridge.openness
	var openness_rate: float = absf(
		current_openness - _previous_fridge_openness
	) / maxf(delta, 0.001)
	_previous_fridge_openness = current_openness
	apply_fridge_open_rate(openness_rate)


func _on_clock_phase_changed(current_phase: int) -> void:
	if _legacy_timer_mode:
		apply_phase(current_phase)
		return
	var observed_jump: float = absf(
		GameClock.time_remaining - _last_observed_time_remaining
	)
	if (
		_last_observed_time_remaining < 0.0
		or observed_jump > maxf(scrub_detection_jump, 0.0)
	):
		apply_phase(current_phase)
		return
	_arm_live_phase(current_phase)


## Legacy-pure public application: every call writes every controlled state
## for the given phase, force-completing shutdown errands. Direct verify
## calls, scrubs, restarts, and the initial boot all land here.
func apply_phase(current_phase: int) -> void:
	_current_phase = clampi(current_phase, 0, 4)
	_pending_errands.clear()
	for errand_id: StringName in SHUTDOWN_ERRAND_ORDER:
		var errand_phase: int = int(SHUTDOWN_ERRAND_PHASES[errand_id])
		if errand_phase <= _current_phase:
			if not _applied_effects.has(errand_id):
				_applied_effects[errand_id] = true
				shutdown_errand_completed.emit(errand_id, false)
		else:
			_applied_effects.erase(errand_id)
	_write_world_state()


## Errand-gated live boundary: shutdown effects newly required by this
## phase queue for the parent instead of applying, so the house visibly
## stays lit until the routine walks each stop.
func _arm_live_phase(current_phase: int) -> void:
	_current_phase = clampi(current_phase, 0, 4)
	for errand_id: StringName in SHUTDOWN_ERRAND_ORDER:
		var errand_phase: int = int(SHUTDOWN_ERRAND_PHASES[errand_id])
		if errand_phase > _current_phase:
			_applied_effects.erase(errand_id)
			_pending_errands.erase(errand_id)
		elif (
			not _applied_effects.has(errand_id)
			and not _pending_errands.has(errand_id)
		):
			_pending_errands.append(errand_id)
	_write_world_state()


func force_complete_pending_errands() -> void:
	apply_phase(GameClock.phase)


func has_pending_shutdown_errand() -> bool:
	return not _pending_errands.is_empty()


func is_shutdown_errand_pending(errand_id: StringName) -> bool:
	return _pending_errands.has(errand_id)


func peek_next_shutdown_errand() -> StringName:
	return _pending_errands[0] if not _pending_errands.is_empty() else &""


func is_shutdown_effect_applied(errand_id: StringName) -> bool:
	return _applied_effects.has(errand_id)


## The parent reports an errand done (it has clicked the fixture/switch).
## Idempotent: force-completed or repeated ids do not re-emit.
func complete_shutdown_errand(errand_id: StringName) -> void:
	_pending_errands.erase(errand_id)
	if not SHUTDOWN_ERRAND_PHASES.has(errand_id):
		return
	if not _applied_effects.has(errand_id):
		_applied_effects[errand_id] = true
		shutdown_errand_completed.emit(errand_id, true)
	_write_world_state()


func get_errand_switch(errand_id: StringName) -> DinnerWorldSwitch:
	if (
		errand_id != &"kitchen"
		and errand_id != &"dining"
		and errand_id != &"foyer"
	):
		return null
	for node: Node in get_tree().get_nodes_in_group("world_switch"):
		var wall_switch: DinnerWorldSwitch = node as DinnerWorldSwitch
		if wall_switch != null and wall_switch.switch_id == errand_id:
			return wall_switch
	return null


## Where the parent must stand to perform the errand: the real wall switch
## for switch-controlled phases, the lamp stand for the switchless living
## floor lamp, the console for the TV.
func get_errand_target(errand_id: StringName) -> Dictionary:
	var errand_switch: DinnerWorldSwitch = get_errand_switch(errand_id)
	if errand_switch != null:
		return {"valid": true, "position": errand_switch.global_position}
	var fixture_name: String = ""
	match errand_id:
		&"living":
			fixture_name = "LivingLampVisual"
		&"tv":
			fixture_name = "TVGlow"
	if fixture_name.is_empty() or _level == null:
		return {"valid": false, "position": Vector3.ZERO}
	var fixture: Node3D = _level.get_node_or_null(fixture_name) as Node3D
	if fixture == null:
		return {"valid": false, "position": Vector3.ZERO}
	return {"valid": true, "position": fixture.global_position}


## One writer for the whole countdown state, in the legacy order (zones,
## ambients, fixture visibility, switch-controlled practicals exemption,
## switch knob sync). Shutdown lines key off applied effects instead of the
## raw phase; everything else is unchanged from the pre-errand sweep.
func _write_world_state() -> void:
	var bathroom_enabled: bool = _get_switch_state(&"bathroom", false)
	var hall_door_enabled: bool = _get_switch_state(&"kid_hall", false)
	var carpet_hall_enabled: bool = _get_switch_state(&"carpet_hall", true)
	var living_off: bool = _applied_effects.has(&"living")
	var tv_off: bool = _applied_effects.has(&"tv")
	var kitchen_off: bool = _applied_effects.has(&"kitchen")
	var dining_off: bool = _applied_effects.has(&"dining")
	var foyer_off: bool = _applied_effects.has(&"foyer")
	LightSystem.set_zone_enabled("bedroom", true)
	LightSystem.set_zone_enabled("bathroom", true)
	LightSystem.set_zone_enabled("living", not living_off)
	LightSystem.set_zone_enabled("kitchen", not kitchen_off)
	# The hall countdown zone falls once both final-sweep stops are done.
	LightSystem.set_zone_enabled("hall", not (dining_off and foyer_off))
	NoiseSystem.set_ambient_source_enabled("tv", not tv_off)
	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", not kitchen_off)

	_set_level_node_visible("KidLampVisual", true)
	_set_level_node_visible("LivingLampVisual", not living_off)
	_set_level_node_visible("TVGlow", not tv_off)
	_set_level_node_visible("TVNotes", not tv_off)
	_set_level_node_visible("KitchenLampVisual", not kitchen_off)
	_set_level_node_visible("MidLampVisual", not dining_off)
	_set_level_node_visible("DiningEntryLampVisual", not dining_off)
	_set_level_node_visible("AlcoveLampVisual", not foyer_off)
	# These practicals are switch controlled and are not part of the
	# countdown zone sweep; the corridor stays a player-authored risk choice.
	LightSystem.set_light_enabled("BathroomLampVisual", bathroom_enabled)
	_set_level_node_visible("BathroomLampVisual", bathroom_enabled)
	LightSystem.set_light_enabled("HallDoorLampVisual", hall_door_enabled)
	_set_level_node_visible("HallDoorLampVisual", hall_door_enabled)
	for corridor_light_id: String in [
		"CarpetHallLampWest",
		"CarpetHallLampEast",
	]:
		LightSystem.set_light_enabled(corridor_light_id, carpet_hall_enabled)
		_set_level_node_visible(corridor_light_id, carpet_hall_enabled)
	if _tv_glow != null and not tv_off:
		apply_tv_flicker()
	for node: Node in get_tree().get_nodes_in_group("world_switch"):
		if node.has_method("sync_state_from_target"):
			node.call("sync_state_from_target")


func _get_switch_state(switch_id: StringName, fallback: bool) -> bool:
	for node: Node in get_tree().get_nodes_in_group("world_switch"):
		if node.get("switch_id") == switch_id:
			return bool(node.get("is_on"))
	return fallback


func apply_tv_flicker() -> void:
	if _tv_glow == null:
		return
	var primary_wave: float = sin(_tv_flicker_time * tv_flicker_speed)
	var secondary_wave: float = sin(
		_tv_flicker_time * tv_flicker_speed * 2.37 + 0.8
	)
	var flicker_weight: float = (
		1.0
		+ tv_flicker_amount * (primary_wave * 0.7 + secondary_wave * 0.3)
	)
	_tv_glow.light_energy = _tv_base_energy * flicker_weight


func apply_fridge_open_rate(openness_rate: float) -> void:
	if _fridge == null or _fridge_light == null:
		return
	var safe_rate: float = maxf(openness_rate, 0.0)
	_fridge_light.light_energy = (
		safe_rate * _fridge.fridge_spill_energy_per_open_rate
	)
	_fridge_light.omni_range = (
		safe_rate * _fridge.fridge_spill_radius_per_open_rate
	)


func _set_level_node_visible(node_name: String, on: bool) -> void:
	if _level == null:
		return
	var visual: Node3D = _level.get_node_or_null(node_name) as Node3D
	if visual != null:
		visual.visible = on
