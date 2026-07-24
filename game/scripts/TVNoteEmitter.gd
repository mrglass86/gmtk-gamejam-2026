extends Node3D
class_name TVNoteEmitter

## Sustained TV masking treatment: faint notes drift upward only while the
## source node is visible. PhaseDirector owns that visibility with the TV bed.

@export var emission_interval: float = 0.55
@export var lifetime: float = 1.8
@export var rise_height: float = 1.15
@export var spread: float = 0.55

var _elapsed: float = 0.0
var _notes: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _process(delta: float) -> void:
	if visible:
		_elapsed += delta
		if _elapsed >= emission_interval:
			_elapsed = fmod(_elapsed, emission_interval)
			_spawn_note()
	else:
		_elapsed = 0.0
	for index: int in range(_notes.size() - 1, -1, -1):
		var row: Dictionary = _notes[index]
		var note: Label3D = row["node"] as Label3D
		var age: float = float(row["age"]) + delta
		if age >= lifetime or not is_instance_valid(note):
			if is_instance_valid(note):
				note.queue_free()
			_notes.remove_at(index)
			continue
		row["age"] = age
		var weight: float = age / lifetime
		note.position.y = float(row["start_y"]) + rise_height * weight
		note.modulate.a = 0.34 * (1.0 - weight)
		_notes[index] = row


func _spawn_note() -> void:
	var note: Label3D = Label3D.new()
	note.text = "♪" if _rng.randf() > 0.35 else "♫"
	note.position = Vector3(
		_rng.randf_range(-spread, spread),
		0.0,
		_rng.randf_range(-0.16, 0.16)
	)
	note.font_size = 40
	note.pixel_size = 0.006
	note.modulate = Color(0.88, 0.32, 0.91, 0.34)
	note.outline_size = 3
	note.outline_modulate = Color(0.12, 0.02, 0.16, 0.25)
	note.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	note.no_depth_test = true
	add_child(note)
	_notes.append({"node": note, "age": 0.0, "start_y": note.position.y})
