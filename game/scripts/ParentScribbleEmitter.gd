extends Node3D
class_name DinnerParentScribbleEmitter

## Floaty speech scribbles above the parent while a VO pool plays — the
## speech sibling of TVNoteEmitter's music notes. Watches the (now
## mesh-less) ParentVoiceIndicator's visible flag, which B14 and the audio
## verify assert, and spawns small procedural squiggle sprites that rise,
## wobble, and fade. Deliberately paper-white: the magenta of the old
## indicator block stays reserved for noise-danger tells.

@export var emission_interval: float = 0.22
@export var lifetime: float = 0.9
@export var rise_height: float = 0.55
@export var spread: float = 0.24
@export var wobble_amount: float = 0.05
@export var wobble_speed: float = 9.0
@export var scribble_color: Color = Color(0.93, 0.91, 0.85, 0.55)
@export var scribble_pixel_size: float = 0.008
## Fixed seed: the 2-3 squiggle texture variants are deterministic, drawn
## in code (short sine strokes into an Image) — no assets, no fonts.
@export var texture_random_seed: int = 260725
@export_range(2, 3, 1) var texture_variant_count: int = 3

## Node whose `visible` flag gates emission (the ParentVoiceIndicator).
var watch_target: Node3D

var _elapsed: float = 0.0
var _scribbles: Array[Dictionary] = []
var _textures: Array[ImageTexture] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = texture_random_seed
	_build_scribble_textures()


func _process(delta: float) -> void:
	var active: bool = watch_target != null and watch_target.visible
	if active:
		_elapsed += delta
		if _elapsed >= emission_interval:
			_elapsed = fmod(_elapsed, maxf(emission_interval, 0.01))
			_spawn_scribble()
	else:
		_elapsed = 0.0
	for index: int in range(_scribbles.size() - 1, -1, -1):
		var row: Dictionary = _scribbles[index]
		var scribble: Sprite3D = row["node"] as Sprite3D
		var age: float = float(row["age"]) + delta
		if age >= lifetime or not is_instance_valid(scribble):
			if is_instance_valid(scribble):
				scribble.queue_free()
			_scribbles.remove_at(index)
			continue
		row["age"] = age
		var weight: float = age / maxf(lifetime, 0.01)
		scribble.position.y = float(row["start_y"]) + rise_height * weight
		scribble.position.x = (
			float(row["start_x"])
			+ sin(float(row["wobble_phase"]) + age * wobble_speed)
			* wobble_amount
			* weight
		)
		var faded: Color = scribble_color
		faded.a = scribble_color.a * (1.0 - weight)
		scribble.modulate = faded
		_scribbles[index] = row


func _spawn_scribble() -> void:
	if _textures.is_empty():
		return
	var scribble: Sprite3D = Sprite3D.new()
	scribble.texture = _textures[_rng.randi_range(0, _textures.size() - 1)]
	scribble.pixel_size = scribble_pixel_size
	scribble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scribble.no_depth_test = true
	scribble.modulate = scribble_color
	scribble.position = Vector3(
		_rng.randf_range(-spread, spread),
		0.0,
		_rng.randf_range(-0.12, 0.12)
	)
	add_child(scribble)
	_scribbles.append({
		"node": scribble,
		"age": 0.0,
		"start_x": scribble.position.x,
		"start_y": scribble.position.y,
		"wobble_phase": _rng.randf_range(0.0, TAU),
	})


## Draws each variant as two short sine strokes with soft edges and end
## fade — reads as tiny handwriting from gameplay distance.
func _build_scribble_textures() -> void:
	for _variant_index: int in range(clampi(texture_variant_count, 2, 3)):
		var image: Image = Image.create(44, 18, false, Image.FORMAT_RGBA8)
		for stroke_index: int in range(2):
			var mid_y: float = 5.0 + 7.0 * float(stroke_index)
			var amplitude: float = _rng.randf_range(2.0, 3.4)
			var frequency: float = _rng.randf_range(0.55, 0.95)
			var phase: float = _rng.randf_range(0.0, TAU)
			var start_x: int = _rng.randi_range(0, 4)
			var end_x: int = 44 - _rng.randi_range(1, 6)
			for x: int in range(start_x, end_x):
				var stroke_span: float = maxf(float(end_x - start_x), 1.0)
				var stroke_weight: float = (
					float(x - start_x) / stroke_span
				)
				var end_fade: float = clampf(
					minf(stroke_weight, 1.0 - stroke_weight) * 6.0,
					0.0,
					1.0
				)
				var y_center: int = int(round(
					mid_y + sin(float(x) * frequency + phase) * amplitude
				))
				for y_offset: int in range(-1, 2):
					var y: int = clampi(y_center + y_offset, 0, 17)
					var pixel_alpha: float = (
						(1.0 if y_offset == 0 else 0.4) * end_fade
					)
					if pixel_alpha <= 0.0:
						continue
					var existing: Color = image.get_pixel(x, y)
					image.set_pixel(
						x,
						y,
						Color(1.0, 1.0, 1.0, maxf(existing.a, pixel_alpha))
					)
		_textures.append(ImageTexture.create_from_image(image))
