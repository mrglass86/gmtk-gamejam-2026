extends CanvasLayer

## Temporary A1 calibration readout. The player body will become the final
## exposure readout once lane B owns its material response.

@export var update_interval: float = 0.1

@onready var label: Label = $Label

var _elapsed: float = 0.0


func _ready() -> void:
	visible = OS.is_debug_build()
	set_process(visible)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < update_interval:
		return
	_elapsed = 0.0
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		label.text = "Brightness: --"
		return
	label.text = "Brightness: %.2f" % LightSystem.get_brightness_at(player.global_position)
