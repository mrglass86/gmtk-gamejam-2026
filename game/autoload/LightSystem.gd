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


func get_brightness_at(pos: Vector3) -> float:
	# TODO A1: max contribution of any enabled registered light,
	# linear falloff to zero at the radius edge. 0.0 dark .. 1.0 fully lit.
	return 0.0


func set_zone_enabled(zone: String, on: bool) -> void:
	# TODO A1: toggle every registered light in the zone.
	lighting_changed.emit()
