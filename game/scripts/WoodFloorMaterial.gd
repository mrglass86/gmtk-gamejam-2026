class_name WoodFloorMaterial
extends RefCounted

## Shared world-projected plank material for every wood floor surface.
## World-space triplanar projection keeps one continuous pattern across
## separate floor slabs and noise-overlay patches, so a creaky board shows
## exactly the planks the slab beneath it would — the trap has no visual
## tell (director ruling 2026-07-24). The texture is generated in code from
## a fixed seed: no sourced assets, identical planks every launch.

const TEXTURE_SIZE: int = 256
const PLANK_ROWS: int = 8
const PLANK_MIN_LENGTH: int = 48
const PLANK_MAX_LENGTH: int = 120
const PATTERN_SEED: int = 260724
const BASE_COLOR: Color = Color("#77726c")
const SEAM_DARKEN: float = 0.72
const SEAM_THICKNESS: int = 2
const PLANK_VALUE_JITTER: float = 0.08
## One texture tile spans 1 / UV_SCALE metres, so the eight plank rows read
## as roughly 0.2 m boards under the fixed top-down camera.
const UV_SCALE: float = 0.625

static var _shared_material: StandardMaterial3D


static func shared() -> StandardMaterial3D:
	if _shared_material == null:
		_shared_material = _build_material()
	return _shared_material


static func _build_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = _build_plank_texture()
	material.roughness = 1.0
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(UV_SCALE, UV_SCALE, UV_SCALE)
	return material


static func _build_plank_texture() -> ImageTexture:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = PATTERN_SEED
	var image: Image = Image.create_empty(
		TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGB8
	)
	var row_height: int = TEXTURE_SIZE / PLANK_ROWS
	var seam_color: Color = _scaled(BASE_COLOR, SEAM_DARKEN)
	for row_index in range(PLANK_ROWS):
		var y_start: int = row_index * row_height
		var x_cursor: int = 0
		while x_cursor < TEXTURE_SIZE:
			var x_end: int = mini(
				x_cursor + rng.randi_range(PLANK_MIN_LENGTH, PLANK_MAX_LENGTH),
				TEXTURE_SIZE
			)
			# A remnant shorter than the minimum merges into this plank so the
			# left texture edge is always a seam and the tile wraps cleanly.
			if TEXTURE_SIZE - x_end < PLANK_MIN_LENGTH:
				x_end = TEXTURE_SIZE
			var plank_color: Color = _scaled(
				BASE_COLOR,
				1.0 + rng.randf_range(-PLANK_VALUE_JITTER, PLANK_VALUE_JITTER)
			)
			for pixel_y in range(y_start, y_start + row_height):
				for pixel_x in range(x_cursor, x_end):
					var is_seam: bool = (
						pixel_y - y_start < SEAM_THICKNESS
						or pixel_x - x_cursor < SEAM_THICKNESS
					)
					image.set_pixel(
						pixel_x,
						pixel_y,
						seam_color if is_seam else plank_color
					)
			x_cursor = x_end
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


static func _scaled(color: Color, value_scale: float) -> Color:
	return Color(
		clampf(color.r * value_scale, 0.0, 1.0),
		clampf(color.g * value_scale, 0.0, 1.0),
		clampf(color.b * value_scale, 0.0, 1.0)
	)
