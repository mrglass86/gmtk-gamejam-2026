extends Node
## NoiseSystem autoload — locked interface, brief section 3.
## A pure broadcast bus. Listeners handle their own distance falloff; the
## system does no filtering. Emitters apply masking before calling emit_noise:
## loudness = raw * (1.0 - get_mask_at(pos)).

signal noise_emitted(pos: Vector3, loudness: float, source: Node)

## A4 registers the TV and kitchen speaker here. Mask values use the same
## linear falloff shape as lights; overlapping sources use the strongest value.
var _ambient_sources: Dictionary = {}


func emit_noise(pos: Vector3, loudness: float, source: Node) -> void:
	noise_emitted.emit(pos, loudness, source)


func register_ambient_source(id: String, pos: Vector3, radius: float, strength: float, enabled: bool = true) -> void:
	if radius <= 0.0:
		push_error("NoiseSystem rejected non-positive ambient radius for %s" % id)
		return
	_ambient_sources[id] = {
		"position": pos,
		"radius": radius,
		"strength": clampf(strength, 0.0, 1.0),
		"enabled": enabled,
	}


func set_ambient_source_enabled(id: String, enabled: bool) -> void:
	if not _ambient_sources.has(id):
		push_error("NoiseSystem cannot update missing ambient source: %s" % id)
		return
	var source_data: Dictionary = _ambient_sources[id]
	source_data["enabled"] = enabled
	_ambient_sources[id] = source_data


func unregister_ambient_source(id: String) -> void:
	_ambient_sources.erase(id)


func get_mask_at(pos: Vector3) -> float:
	var strongest_mask: float = 0.0
	for source_id: String in _ambient_sources:
		var source_data: Dictionary = _ambient_sources[source_id]
		if not source_data["enabled"]:
			continue
		var source_position: Vector3 = source_data["position"]
		var radius: float = source_data["radius"]
		var strength: float = source_data["strength"]
		var contribution: float = strength * clampf(1.0 - source_position.distance_to(pos) / radius, 0.0, 1.0)
		strongest_mask = maxf(strongest_mask, contribution)
	return strongest_mask
