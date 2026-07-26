extends TextureRect
class_name MenuPaperLayer

## One photographed construction-paper element on the menu (2026-07-25).
## Drifts and tilts on slow desynchronised sines, like a pile of papers
## being idly nudged. Runs while the tree is paused because the GameFlow
## layer is PROCESS_MODE_ALWAYS.

@export var drift_amplitude: Vector2 = Vector2(6.0, 4.0)
@export var drift_period: float = 7.0
@export var rotation_amplitude_degrees: float = 1.2
@export var rotation_period: float = 9.0
@export var phase_offset: float = 0.0

var _base_position: Vector2
var _base_rotation: float
var _elapsed: float = 0.0
## Anchored layers do not have their final rect during _ready (2026-07-26), so
## the rest pose is captured on the first frame instead.
var _base_captured: bool = false


func _ready() -> void:
	pivot_offset = size * 0.5


func _process(delta: float) -> void:
	if not _base_captured:
		pivot_offset = size * 0.5
		_base_position = position
		_base_rotation = rotation
		_base_captured = true
	_elapsed += delta
	var safe_drift_period: float = maxf(drift_period, 0.1)
	var safe_rotation_period: float = maxf(rotation_period, 0.1)
	position = _base_position + Vector2(
		sin((_elapsed / safe_drift_period + phase_offset) * TAU)
		* drift_amplitude.x,
		sin(
			(_elapsed / safe_drift_period * 0.83 + phase_offset + 0.31) * TAU
		) * drift_amplitude.y
	)
	rotation = _base_rotation + deg_to_rad(
		sin((_elapsed / safe_rotation_period + phase_offset + 0.62) * TAU)
		* rotation_amplitude_degrees
	)
