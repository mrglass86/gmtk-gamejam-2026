extends Node
## LightSystem autoload — locked interface, brief section 3.
## Brightness is analytic, computed from registered lights and their on/off
## state. It is never sampled from the rendered frame: cheap, testable, and
## independent of the visual lighting.
##
## Lane A implements (package A1): light registration per zone (bedroom, hall,
## living, kitchen), max-contribution with linear falloff, zone toggling.
## Pre-approved additive helper (package A2): register_dynamic_light /
## set_dynamic_light for the fridge spill, id "fridge".

signal lighting_changed()

const VALID_ZONES: PackedStringArray = ["bedroom", "hall", "living", "kitchen"]

## Static sources are registered by LevelBuilder when it creates each named
## ceiling lamp. Each source stores an analytic floor anchor, independent of
## the visual light's ceiling position, so the brightness query describes the
## place the player occupies rather than renderer output.
var _lights: Dictionary = {}
var _dynamic_lights: Dictionary = {}


func register_light(id: String, zone: String, pos: Vector3, radius: float, enabled: bool = true) -> void:
	if not VALID_ZONES.has(zone):
		push_error("LightSystem rejected unknown zone: %s" % zone)
		return
	if radius <= 0.0:
		push_error("LightSystem rejected non-positive radius for %s" % id)
		return
	_lights[id] = {
		"zone": zone,
		"position": pos,
		"radius": radius,
		"enabled": enabled,
	}
	lighting_changed.emit()


func unregister_light(id: String) -> void:
	if _lights.erase(id):
		lighting_changed.emit()


## Dynamic lights are intentionally outside VALID_ZONES: the fridge is a
## transient analytic spill, not a routine-controlled room lamp.
func register_dynamic_light(id: String, pos: Vector3) -> void:
	_dynamic_lights[id] = {
		"position": pos,
		"radius": 0.0,
		"energy": 0.0,
	}
	lighting_changed.emit()


func set_dynamic_light(id: String, radius: float, energy: float) -> void:
	if not _dynamic_lights.has(id):
		push_error("LightSystem cannot update missing dynamic light: %s" % id)
		return
	var light_data: Dictionary = _dynamic_lights[id]
	light_data["radius"] = maxf(radius, 0.0)
	light_data["energy"] = maxf(energy, 0.0)
	_dynamic_lights[id] = light_data
	lighting_changed.emit()


func unregister_dynamic_light(id: String) -> void:
	if _dynamic_lights.erase(id):
		lighting_changed.emit()


func get_brightness_at(pos: Vector3) -> float:
	var brightest: float = 0.0
	for light_id: String in _lights:
		var light_data: Dictionary = _lights[light_id]
		if not light_data["enabled"]:
			continue
		var light_position: Vector3 = light_data["position"]
		var radius: float = light_data["radius"]
		var contribution: float = clampf(1.0 - light_position.distance_to(pos) / radius, 0.0, 1.0)
		brightest = maxf(brightest, contribution)
	for light_id: String in _dynamic_lights:
		var dynamic_data: Dictionary = _dynamic_lights[light_id]
		var dynamic_radius: float = dynamic_data["radius"]
		var dynamic_energy: float = dynamic_data["energy"]
		if dynamic_radius <= 0.0 or dynamic_energy <= 0.0:
			continue
		var dynamic_position: Vector3 = dynamic_data["position"]
		var dynamic_contribution: float = dynamic_energy * clampf(
			1.0 - dynamic_position.distance_to(pos) / dynamic_radius, 0.0, 1.0
		)
		brightest = maxf(brightest, dynamic_contribution)
	return brightest


func set_zone_enabled(zone: String, on: bool) -> void:
	for light_id: String in _lights:
		var light_data: Dictionary = _lights[light_id]
		if light_data["zone"] == zone:
			light_data["enabled"] = on
			_lights[light_id] = light_data
	lighting_changed.emit()
