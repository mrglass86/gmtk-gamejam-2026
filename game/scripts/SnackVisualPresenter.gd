extends MeshInstance3D
class_name SnackVisualPresenter

## Scene-side presentation for the shared snack. DinnerSnack remains gameplay
## authority while this presenter consumes its stable snack_type and handles
## variant primitives, reveal clearance, carried visibility, emissive pulse,
## and the player's mesh-only pickup pop.

@export_node_path("DinnerSnack") var snack_path: NodePath = NodePath("..")
@export_node_path("DinnerDoor") var fridge_path: NodePath = NodePath("../../Fridge")
@export_node_path("DinnerDoor") var pantry_path: NodePath = NodePath("../../Pantry")
@export var default_offset: Vector3 = Vector3(0.0, 0.42, 0.0)
@export var fridge_reveal_offset: Vector3 = Vector3(2.2, 0.42, 0.95)
@export var pantry_reveal_offset: Vector3 = Vector3(1.0, 0.42, 0.9)
@export var door_match_tolerance: float = 0.1
@export_group("Carried Presentation")
@export var carried_offset: Vector3 = Vector3(0.52, 0.72, 0.12)
@export var player_presentation_path: NodePath = NodePath("PresentationPivot")
@export var pickup_pop_scale: float = 1.22
@export var pickup_pop_rise_time: float = 0.10
@export var pickup_pop_return_time: float = 0.20
@export_group("Pulse")
@export var pulse_scale_amount: float = 0.07
@export var pulse_speed: float = 3.6
@export var emission_energy_base: float = 2.4
@export var emission_pulse_amount: float = 0.3
@export_group("Snack Identity")
@export var pantry_packet_color: Color = Color("#fff0a8")
@export var pantry_foil_color: Color = Color("#f7fbff")
@export var fridge_scoop_color: Color = Color("#f5f7ff")
@export var fridge_cone_color: Color = Color("#c8c3b8")

var _snack: DinnerSnack
var _fridge: DinnerDoor
var _pantry: DinnerDoor
var _pulse_elapsed: float = 0.0
var _base_scale: Vector3
var _presented_type: StringName = &""
var _pulse_materials: Array[StandardMaterial3D] = []
var _variant_parts: Array[MeshInstance3D] = []
var _pickup_pop_tween: Tween


func _ready() -> void:
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_fridge = get_node_or_null(fridge_path) as DinnerDoor
	_pantry = get_node_or_null(pantry_path) as DinnerDoor
	_base_scale = scale
	if _snack != null and not _snack.picked_up.is_connected(_on_picked_up):
		_snack.picked_up.connect(_on_picked_up)
	if (
		_snack != null
		and not _snack.snack_type_changed.is_connected(_on_snack_type_changed)
	):
		_snack.snack_type_changed.connect(_on_snack_type_changed)
	_apply_snack_type(
		_snack.snack_type if _snack != null else DinnerSnack.TYPE_CHIPS
	)
	apply_reveal_clearance()


func _process(delta: float) -> void:
	_pulse_elapsed += delta
	_apply_pulse()
	if _snack == null:
		visible = false
		return
	if _snack.carried_by != null:
		visible = true
		global_position = _snack.carried_by.to_global(carried_offset)
	elif _snack.available_for_pickup:
		visible = true
		apply_reveal_clearance()
	else:
		visible = false


func get_presented_type() -> StringName:
	return _presented_type


func get_pulse_materials() -> Array[StandardMaterial3D]:
	return _pulse_materials.duplicate()


func get_visual_world_aabb() -> AABB:
	var combined: AABB = global_transform * get_aabb()
	for part: MeshInstance3D in _variant_parts:
		combined = combined.merge(part.global_transform * part.get_aabb())
	return combined


func apply_reveal_clearance() -> void:
	if _snack == null:
		return
	if (
		_fridge != null
		and _snack.global_position.distance_to(_fridge.global_position)
		<= door_match_tolerance
	):
		position = fridge_reveal_offset
		return
	if (
		_pantry != null
		and _snack.global_position.distance_to(_pantry.global_position)
		<= door_match_tolerance
	):
		position = pantry_reveal_offset
		return
	position = default_offset


func _apply_snack_type(next_type: StringName) -> void:
	var resolved_type: StringName = (
		DinnerSnack.TYPE_ICE_CREAM
		if next_type == DinnerSnack.TYPE_ICE_CREAM
		else DinnerSnack.TYPE_CHIPS
	)
	_clear_variant_parts()
	_pulse_materials.clear()
	_presented_type = resolved_type
	if resolved_type == DinnerSnack.TYPE_ICE_CREAM:
		_build_ice_cream()
	else:
		_build_pantry_packet()
	_apply_pulse()


func _build_pantry_packet() -> void:
	var packet_mesh: BoxMesh = BoxMesh.new()
	packet_mesh.size = Vector3(0.56, 0.68, 0.16)
	mesh = packet_mesh
	material_override = _make_emissive_material(
		pantry_packet_color,
		pantry_packet_color
	)
	rotation_degrees = Vector3(0.0, 12.0, 0.0)

	var foil_band: MeshInstance3D = MeshInstance3D.new()
	foil_band.name = "FoilBand"
	var foil_mesh: BoxMesh = BoxMesh.new()
	foil_mesh.size = Vector3(0.58, 0.12, 0.18)
	foil_band.mesh = foil_mesh
	foil_band.position = Vector3(0.0, 0.14, 0.0)
	foil_band.material_override = _make_emissive_material(
		pantry_foil_color,
		pantry_foil_color
	)
	add_child(foil_band)
	_variant_parts.append(foil_band)


func _build_ice_cream() -> void:
	var scoop_mesh: SphereMesh = SphereMesh.new()
	scoop_mesh.radius = 0.3
	scoop_mesh.height = 0.6
	mesh = scoop_mesh
	material_override = _make_emissive_material(
		fridge_scoop_color,
		fridge_scoop_color
	)
	rotation = Vector3.ZERO

	var cone: MeshInstance3D = MeshInstance3D.new()
	cone.name = "Cone"
	var cone_mesh: CylinderMesh = CylinderMesh.new()
	cone_mesh.top_radius = 0.23
	cone_mesh.bottom_radius = 0.055
	cone_mesh.height = 0.4
	cone.mesh = cone_mesh
	cone.position = Vector3(0.0, -0.18, 0.0)
	cone.material_override = _make_emissive_material(
		fridge_cone_color,
		fridge_cone_color
	)
	add_child(cone)
	_variant_parts.append(cone)


func _clear_variant_parts() -> void:
	for part: MeshInstance3D in _variant_parts:
		if is_instance_valid(part):
			part.visible = false
			remove_child(part)
			part.queue_free()
	_variant_parts.clear()


func _make_emissive_material(
	albedo: Color,
	emission_color: Color
) -> StandardMaterial3D:
	var snack_material: StandardMaterial3D = StandardMaterial3D.new()
	snack_material.albedo_color = albedo
	snack_material.roughness = 0.48
	snack_material.metallic = 0.08
	snack_material.emission_enabled = true
	snack_material.emission = emission_color
	snack_material.emission_energy_multiplier = emission_energy_base
	_pulse_materials.append(snack_material)
	return snack_material


func _apply_pulse() -> void:
	var pulse_weight: float = sin(_pulse_elapsed * pulse_speed * TAU)
	scale = _base_scale * (1.0 + pulse_scale_amount * pulse_weight)
	for pulse_material: StandardMaterial3D in _pulse_materials:
		pulse_material.emission_energy_multiplier = emission_energy_base * (
			1.0 + emission_pulse_amount * pulse_weight
		)


func _on_snack_type_changed(next_type: StringName) -> void:
	_apply_snack_type(next_type)


func _on_picked_up(carrier: DinnerPlayer) -> void:
	visible = true
	global_position = carrier.to_global(carried_offset)
	var presentation: Node3D = carrier.get_node_or_null(
		player_presentation_path
	) as Node3D
	if presentation == null:
		return
	if _pickup_pop_tween != null and _pickup_pop_tween.is_valid():
		_pickup_pop_tween.kill()
	presentation.scale = Vector3.ONE
	_pickup_pop_tween = create_tween()
	_pickup_pop_tween.tween_property(
		presentation,
		"scale",
		Vector3.ONE * pickup_pop_scale,
		pickup_pop_rise_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pickup_pop_tween.tween_property(
		presentation,
		"scale",
		Vector3.ONE,
		pickup_pop_return_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
