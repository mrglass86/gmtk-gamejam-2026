extends Node
class_name PhaseDirector

## Applies the whole countdown world state from one phase value. Every call
## writes every controlled state so forward and backward scrubbing are equal.

@export_node_path("Node3D") var level_path: NodePath = NodePath("../Level")

var _level: Node3D


func _ready() -> void:
	_level = get_node_or_null(level_path) as Node3D
	if not GameClock.phase_changed.is_connected(apply_phase):
		GameClock.phase_changed.connect(apply_phase)
	apply_phase.call_deferred(GameClock.phase)


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


func _set_level_node_visible(node_name: String, on: bool) -> void:
	if _level == null:
		return
	var visual: Node3D = _level.get_node_or_null(node_name) as Node3D
	if visual != null:
		visual.visible = on
