extends MeshInstance3D
class_name SnackVisualPresenter

## Keeps the shared snack mesh above the floor and on the player-facing side
## of whichever goal door revealed it. DinnerSnack remains gameplay-authority.

@export_node_path("DinnerSnack") var snack_path: NodePath = NodePath("..")
@export_node_path("DinnerDoor") var fridge_path: NodePath = NodePath("../../Fridge")
@export_node_path("DinnerDoor") var pantry_path: NodePath = NodePath("../../Pantry")
@export var default_offset: Vector3 = Vector3(0.0, 0.36, 0.0)
@export var fridge_reveal_offset: Vector3 = Vector3(0.0, 0.36, 0.65)
@export var pantry_reveal_offset: Vector3 = Vector3(0.0, 0.36, -0.65)
@export var door_match_tolerance: float = 0.1

var _snack: DinnerSnack
var _fridge: DinnerDoor
var _pantry: DinnerDoor


func _ready() -> void:
	_snack = get_node_or_null(snack_path) as DinnerSnack
	_fridge = get_node_or_null(fridge_path) as DinnerDoor
	_pantry = get_node_or_null(pantry_path) as DinnerDoor
	apply_reveal_clearance()


func _process(_delta: float) -> void:
	if _snack != null and _snack.available_for_pickup:
		apply_reveal_clearance()


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
