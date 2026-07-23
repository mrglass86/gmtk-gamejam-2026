extends Label3D
class_name NightstandClock

## World-space countdown display. It intentionally reads the autoload and is
## not a second timer.

@export var update_interval: float = 0.1

var _elapsed: float = 0.0


func _ready() -> void:
	_update_text()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < update_interval:
		return
	_elapsed = 0.0
	_update_text()


func _update_text() -> void:
	var total_seconds: int = maxi(ceili(GameClock.time_remaining), 0)
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	text = "%d:%02d" % [minutes, seconds]
