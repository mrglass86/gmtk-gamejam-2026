extends Node3D
class_name DinnerSnack

## A revealed snack is collected by proximity, then owned by the player until
## the later carry state drops it back into the world.

signal picked_up(player: DinnerPlayer)
signal dropped(drop_position: Vector3)

@export_group("Pickup")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export var pickup_radius: float = 1.0
@export var starts_available: bool = false

@export_group("Optional Visual")
@export_node_path("VisualInstance3D") var visual_path: NodePath = NodePath("Visual")

var available_for_pickup: bool = false
var carried_by: DinnerPlayer

var _player: DinnerPlayer
var _visual: VisualInstance3D


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_visual = get_node_or_null(visual_path) as VisualInstance3D
	available_for_pickup = starts_available
	_refresh_visual()


func _physics_process(_delta: float) -> void:
	if not available_for_pickup or _player == null:
		return
	if _player.global_position.distance_to(global_position) <= pickup_radius:
		pick_up(_player)


func reveal_for_pickup() -> void:
	available_for_pickup = true
	_refresh_visual()


func reveal_at(reveal_position: Vector3) -> void:
	global_position = reveal_position
	reveal_for_pickup()


func pick_up(player: DinnerPlayer) -> bool:
	if not available_for_pickup or player == null:
		return false
	available_for_pickup = false
	carried_by = player
	carried_by.set_carrying_snack(true)
	_refresh_visual()
	picked_up.emit(carried_by)
	return true


func drop_at(drop_position: Vector3) -> void:
	if carried_by != null:
		carried_by.set_carrying_snack(false)
	carried_by = null
	global_position = drop_position
	available_for_pickup = true
	_refresh_visual()
	dropped.emit(drop_position)


func _refresh_visual() -> void:
	if _visual != null:
		_visual.visible = available_for_pickup
