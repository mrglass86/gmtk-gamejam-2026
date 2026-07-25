extends SceneTree

## One-off menu-art baker (2026-07-25): keys the white table out of the
## director's photos with an adaptive per-photo threshold (sampled from the
## brightest corner table patch), feathers the edge, crops to content, and
## writes alpha PNGs to art/menu/keyed/. Run once:
##   godot --headless --path . --script res://art/menu/process_menu_art.gd

const SOURCES: PackedStringArray = [
	"IMG_7103",
	"IMG_7104",
	"IMG_7105",
	"IMG_7112",
	"IMG_7113",
	"IMG_7116",
	"IMG_7119",
]
const SATURATION_GUARD: float = 0.13
const FEATHER: float = 0.05
## Deep drop below the brightest corner so vignette-dimmed table still keys;
## saturated subjects are protected by the saturation guard regardless.
const THRESHOLD_DROP: float = 0.2
const CROP_MARGIN: int = 14
## Frame-edge junk (neighbouring props, corner vignette) must not anchor the
## crop: ignore a border band and demand a solid run of content per row/col.
const BORDER_EXCLUDE: int = 60
const MIN_CONTENT_RUN: int = 30


func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://art/menu/keyed")
	for source_name: String in SOURCES:
		_bake(source_name)
	quit()


func _bake(source_name: String) -> void:
	var path: String = "res://art/menu/%s.png" % source_name
	var image: Image = Image.load_from_file(path)
	if image == null:
		push_error("Menu bake could not load %s" % path)
		return
	image.convert(Image.FORMAT_RGBA8)
	var width: int = image.get_width()
	var height: int = image.get_height()

	# Adaptive white level: average each corner patch, keep the brightest
	# (some corners hold paper or props; the table corner wins).
	var white_level: float = 0.0
	for corner: Vector2i in [
		Vector2i(30, 30),
		Vector2i(width - 31, 30),
		Vector2i(30, height - 31),
		Vector2i(width - 31, height - 31),
	]:
		var corner_sum: float = 0.0
		var corner_count: int = 0
		for offset_y: int in range(-8, 9, 4):
			for offset_x: int in range(-8, 9, 4):
				var sample: Color = image.get_pixel(
					corner.x + offset_x,
					corner.y + offset_y
				)
				corner_sum += minf(minf(sample.r, sample.g), sample.b)
				corner_count += 1
		white_level = maxf(white_level, corner_sum / float(corner_count))
	var threshold: float = white_level - THRESHOLD_DROP

	var row_counts: PackedInt32Array = PackedInt32Array()
	row_counts.resize(height)
	var col_counts: PackedInt32Array = PackedInt32Array()
	col_counts.resize(width)
	for y: int in range(height):
		for x: int in range(width):
			var pixel: Color = image.get_pixel(x, y)
			var darkest: float = minf(minf(pixel.r, pixel.g), pixel.b)
			var brightest: float = maxf(maxf(pixel.r, pixel.g), pixel.b)
			var saturation: float = brightest - darkest
			var whiteness: float = clampf(
				(darkest - threshold) / FEATHER,
				0.0,
				1.0
			)
			var colour_hold: float = clampf(
				(saturation - SATURATION_GUARD) / 0.08,
				0.0,
				1.0
			)
			var alpha: float = 1.0 - whiteness * (1.0 - colour_hold)
			if alpha < 0.98:
				pixel.a = alpha
				image.set_pixel(x, y, pixel)
			if (
				alpha > 0.5
				and x >= BORDER_EXCLUDE
				and x < width - BORDER_EXCLUDE
				and y >= BORDER_EXCLUDE
				and y < height - BORDER_EXCLUDE
			):
				row_counts[y] += 1
				col_counts[x] += 1

	var min_x: int = -1
	var max_x: int = -1
	var min_y: int = -1
	var max_y: int = -1
	for y: int in range(height):
		if row_counts[y] >= MIN_CONTENT_RUN:
			if min_y < 0:
				min_y = y
			max_y = y
	for x: int in range(width):
		if col_counts[x] >= MIN_CONTENT_RUN:
			if min_x < 0:
				min_x = x
			max_x = x
	if max_x < 0 or max_y < 0:
		push_error("Menu bake keyed %s to nothing" % source_name)
		return
	min_x = maxi(min_x - CROP_MARGIN, 0)
	min_y = maxi(min_y - CROP_MARGIN, 0)
	max_x = mini(max_x + CROP_MARGIN, width - 1)
	max_y = mini(max_y + CROP_MARGIN, height - 1)
	var cropped: Image = image.get_region(
		Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	)
	var out_path: String = "res://art/menu/keyed/%s.png" % source_name
	cropped.save_png(out_path)
	print(
		"Menu bake: %s -> %s (%dx%d, white %.2f)"
		% [
			source_name,
			out_path,
			cropped.get_width(),
			cropped.get_height(),
			white_level,
		]
	)
