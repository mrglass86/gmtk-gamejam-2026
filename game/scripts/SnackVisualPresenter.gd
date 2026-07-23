extends MeshInstance3D
class_name SnackVisualPresenter

## Scene-side presentation for the shared snack. DinnerSnack remains gameplay
## authority while this mesh handles reveal clearance, carried visibility,
## emissive pulse, and the player's mesh-only pickup pop.

@export_node_path("DinnerSnack") var snack_path: NodePath = NodePath("..")
@export_node_path("DinnerDoor") var fridge_path: NodePath = NodePath("../../Fridge")
@export_node_path("DinnerDoor") var pantry_path: NodePath = NodePath("../../Pantry")
@export var default_offset: Vector3 = Vector3(0.0, 0.42, 0.0)
@export var fridge_reveal_offset: Vector3 = Vector3(0.0, 0.42, 0.72)
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

var _snack: DinnerSnack
var _fridge: DinnerDoor
var _pantry: DinnerDoor
var _pulse_elapsed: float = 0.0
var _base_scale: Vector3
var _material: StandardMaterial3D
var _pickup_pop_tween: Tween


func _ready() -> void:
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_fridge = get_node_or_null(fridge_path) as DinnerDoor
	_pantry = get_node_or_null(pantry_path) as DinnerDoor
	_base_scale = scale
	_prepare_material()
	if _snack != null and not _snack.picked_up.is_connected(_on_picked_up):
		_snack.picked_up.connect(_on_picked_up)
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


func _prepare_material() -> void:
	var source_material: StandardMaterial3D = material_override as StandardMaterial3D
	if source_material == null:
		return
	_material = source_material.duplicate() as StandardMaterial3D
	material_override = _material
	_material.emission_enabled = true
	_material.emission = Color("#fff4d8")
	_material.emission_energy_multiplier = emission_energy_base


func _apply_pulse() -> void:
	var pulse_weight: float = sin(_pulse_elapsed * pulse_speed * TAU)
	scale = _base_scale * (1.0 + pulse_scale_amount * pulse_weight)
	if _material != null:
		_material.emission_energy_multiplier = emission_energy_base * (
			1.0 + emission_pulse_amount * pulse_weight
		)


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
