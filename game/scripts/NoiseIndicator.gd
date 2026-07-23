extends Node3D
class_name NoiseIndicator

## A single visual noise event. Its ring measures audibility precisely; its
## billboard icon identifies the source and makes sustained events feel alive.

@export var audibility_multiplier: float = 8.0
@export var maximum_radius: float = 20.0
@export var lifetime: float = 1.2
@export var spoke_count: int = 8
@export var spoke_length: float = 0.55
@export var spoke_thickness: float = 0.045
@export var ring_height: float = 0.04
@export var icon_rise: float = 0.5
@export var icon_base_scale: float = 0.4
@export var icon_loudness_scale: float = 0.15
@export var sustained_jitter: float = 0.06
@export var icon_texture_size: int = 32
@export var indicator_color: Color = Color("#FF2D95")

var max_radius: float = 0.0
var _elapsed: float = 0.0
var _is_sustained: bool = false
var _ring_material: StandardMaterial3D
var _icon: Sprite3D
var _spokes: Array[MeshInstance3D] = []
var _icon_scale: float = 1.0


func configure(noise_position: Vector3, loudness: float, sustained: bool) -> void:
	position = Vector3(noise_position.x, ring_height, noise_position.z)
	max_radius = minf(loudness * audibility_multiplier, maximum_radius)
	_is_sustained = sustained
	_icon_scale = icon_base_scale + loudness * icon_loudness_scale


func _ready() -> void:
	_build_ring()
	_build_icon()


func _process(delta: float) -> void:
	_elapsed += delta
	var progress: float = clampf(_elapsed / lifetime, 0.0, 1.0)
	_update_ring(progress)
	_update_icon(progress)
	if progress >= 1.0:
		queue_free()


func _build_ring() -> void:
	_ring_material = StandardMaterial3D.new()
	_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring_material.albedo_color = indicator_color

	var spoke_mesh: BoxMesh = BoxMesh.new()
	spoke_mesh.size = Vector3(1.0, spoke_thickness, spoke_thickness)
	for spoke_index: int in range(spoke_count):
		var spoke: MeshInstance3D = MeshInstance3D.new()
		spoke.mesh = spoke_mesh
		spoke.material_override = _ring_material
		spoke.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(spoke)
		_spokes.append(spoke)


func _build_icon() -> void:
	_icon = Sprite3D.new()
	_icon.texture = _create_icon_texture()
	_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon.pixel_size = 0.018
	_icon.no_depth_test = true
	_icon.modulate = indicator_color
	_icon.scale = Vector3.ONE * _icon_scale
	add_child(_icon)


func _create_icon_texture() -> ImageTexture:
	var image: Image = Image.create(icon_texture_size, icon_texture_size, false, Image.FORMAT_RGBA8)
	var center: int = icon_texture_size / 2
	for x: int in range(icon_texture_size):
		for y: int in range(icon_texture_size):
			if abs(x - center) + abs(y - center) <= center * 0.55:
				image.set_pixel(x, y, Color.WHITE)
	return ImageTexture.create_from_image(image)


func _update_ring(progress: float) -> void:
	var current_radius: float = max_radius * progress
	var alpha: float = 1.0 - progress
	var ring_color: Color = indicator_color
	ring_color.a = alpha
	_ring_material.albedo_color = ring_color
	for spoke_index: int in range(_spokes.size()):
		var angle: float = TAU * float(spoke_index) / float(spoke_count)
		var direction: Vector3 = Vector3(cos(angle), 0.0, sin(angle))
		var visible_length: float = minf(spoke_length, current_radius)
		var spoke: MeshInstance3D = _spokes[spoke_index]
		spoke.visible = visible_length > 0.0
		spoke.position = direction * maxf(current_radius - visible_length * 0.5, 0.0)
		spoke.rotation.y = -angle
		spoke.scale = Vector3(visible_length, 1.0, 1.0)


func _update_icon(progress: float) -> void:
	var icon_color: Color = indicator_color
	icon_color.a = 1.0 - progress
	_icon.modulate = icon_color
	_icon.position = Vector3(0.0, icon_rise * progress, 0.0)
	if _is_sustained:
		_icon.position.x = randf_range(-sustained_jitter, sustained_jitter)
		_icon.position.z = randf_range(-sustained_jitter, sustained_jitter)
