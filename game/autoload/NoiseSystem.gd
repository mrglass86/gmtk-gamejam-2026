extends Node
## NoiseSystem autoload — locked interface, brief section 3.
## A pure broadcast bus. Listeners handle their own distance falloff; the
## system does no filtering. Emitters apply masking before calling emit_noise:
## loudness = raw * (1.0 - get_mask_at(pos)).

signal noise_emitted(pos: Vector3, loudness: float, source: Node)


func emit_noise(pos: Vector3, loudness: float, source: Node) -> void:
	noise_emitted.emit(pos, loudness, source)


func get_mask_at(pos: Vector3) -> float:
	# TODO A4: strongest overlapping ambient mask (TV, kitchen speaker) at pos.
	# 0.0 silent .. 1.0 fully masked. Sources die with their routine phase.
	return 0.0
