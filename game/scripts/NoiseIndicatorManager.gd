extends Node3D

## Absolute-gated listener for NoiseSystem. The bus itself stays unfiltered;
## only this visual listener decides which post-mask events need a ring.

@export var render_threshold: float = 0.25
@export var sustained_event_gap: float = 0.35

const INDICATOR_SCENE: PackedScene = preload("res://scenes/NoiseIndicator.tscn")

var _last_event_time: Dictionary = {}


func _ready() -> void:
	NoiseSystem.noise_emitted.connect(_on_noise_emitted)


func _on_noise_emitted(pos: Vector3, loudness: float, source: Node) -> void:
	if loudness < render_threshold:
		return
	var source_id: int = source.get_instance_id()
	var now: float = Time.get_ticks_msec() * 0.001
	var previous_time: float = _last_event_time.get(source_id, -INF)
	_last_event_time[source_id] = now
	var indicator: Node3D = INDICATOR_SCENE.instantiate() as Node3D
	indicator.top_level = true
	indicator.call("configure", pos, loudness, now - previous_time <= sustained_event_gap)
	add_child(indicator)
