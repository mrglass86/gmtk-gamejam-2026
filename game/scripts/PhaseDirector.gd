extends Node
class_name PhaseDirector

## Applies the whole countdown world state from one phase value. Every call
## writes every controlled state so forward and backward scrubbing are equal.

@export_node_path("Node3D") var level_path: NodePath = NodePath("../Level")
@export_node_path("DinnerDoor") var fridge_path: NodePath = NodePath("../Fridge")
@export_node_path("OmniLight3D") var fridge_light_path: NodePath = NodePath(
	"../Fridge/SpillLight"
)

@export_group("TV Flicker")
@export_range(0.0, 0.2) var tv_flicker_amount: float = 0.055
@export var tv_flicker_speed: float = 15.0

var _level: Node3D
var _fridge: DinnerDoor
var _fridge_light: OmniLight3D
var _tv_glow: AreaLight3D
var _tv_base_energy: float = 0.0
var _tv_flicker_time: float = 0.0
var _previous_fridge_openness: float = 0.0


func _ready() -> void:
	_level = get_node_or_null(level_path) as Node3D
	_fridge = get_node_or_null(fridge_path) as DinnerDoor
	_fridge_light = get_node_or_null(fridge_light_path) as OmniLight3D
	if _level != null:
		_tv_glow = _level.get_node_or_null("TVGlow") as AreaLight3D
	if _tv_glow != null:
		_tv_base_energy = _tv_glow.light_energy
	if _fridge != null:
		_previous_fridge_openness = _fridge.openness
	apply_fridge_open_rate(0.0)
	if not GameClock.phase_changed.is_connected(apply_phase):
		GameClock.phase_changed.connect(apply_phase)
	apply_phase.call_deferred(GameClock.phase)


func _process(delta: float) -> void:
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


func apply_phase(current_phase: int) -> void:
	var clamped_phase: int = clampi(current_phase, 0, 4)
	LightSystem.set_zone_enabled("bedroom", true)
	LightSystem.set_zone_enabled("living", clamped_phase < 1)
	LightSystem.set_zone_enabled("kitchen", clamped_phase < 3)
	LightSystem.set_zone_enabled("hall", clamped_phase < 4)
	NoiseSystem.set_ambient_source_enabled("tv", clamped_phase < 2)
	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", clamped_phase < 3)

	_set_level_node_visible("KidLampVisual", true)
	_set_level_node_visible("LivingLampVisual", clamped_phase < 1)
	_set_level_node_visible("TVGlow", clamped_phase < 2)
	_set_level_node_visible("KitchenLampVisual", clamped_phase < 3)
	_set_level_node_visible("MidLampVisual", clamped_phase < 4)
	_set_level_node_visible("AlcoveLampVisual", clamped_phase < 4)
	if _tv_glow != null and clamped_phase < 2:
		apply_tv_flicker()


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
