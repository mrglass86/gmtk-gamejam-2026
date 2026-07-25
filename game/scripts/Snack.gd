extends Node3D
class_name DinnerSnack

## A revealed snack is collected by proximity, then owned by the player until
## the later carry state drops it back into the world.

signal picked_up(player: DinnerPlayer)
signal dropped(drop_position: Vector3)
## Presentation/audio consumers observe this instead of inferring identity from
## the snack's current position.
signal snack_type_changed(snack_type: StringName)

const TYPE_ICE_CREAM: StringName = &"ice_cream"
const TYPE_CHIPS: StringName = &"chips"

@export_group("Identity")
@export var snack_type: StringName = &""

@export_group("Pickup")
@export_node_path("Node3D") var player_path: NodePath = NodePath("../Player")
@export var pickup_radius: float = 1.0
@export var starts_available: bool = false
@export var drop_pickup_lockout: float = 0.75

@export_group("B17 Runtime Verification")
@export var verify_b17_time_scale: float = 20.0
@export var verify_b17_physics_ticks_per_second: int = 1200
@export var verify_b17_warmup_frames: int = 12
@export var verify_b17_open_duration: float = 0.5
@export var verify_b17_timeout: float = 4.0
@export var verify_b17_observer_position: Vector3 = Vector3(-30.0, 0.6, -20.0)
@export var verify_b17_drop_offset: Vector3 = Vector3(1.5, 0.0, 0.0)

@export_group("Optional Visual")
@export_node_path("VisualInstance3D") var visual_path: NodePath = NodePath("Visual")

var available_for_pickup: bool = false
var carried_by: DinnerPlayer
## Presentation-only bookkeeping: true while the snack sits on the floor
## because of a drop (catch or carry enforcement), false for door reveals
## and while carried. Nothing mechanical reads this flag.
var was_dropped: bool = false

var _player: DinnerPlayer
var _visual: VisualInstance3D
var _pickup_lockout_remaining: float = 0.0
var _verify_b17_observed_types: Array[StringName] = []


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_visual = get_node_or_null(visual_path) as VisualInstance3D
	available_for_pickup = starts_available
	_refresh_visual()
	if OS.get_cmdline_user_args().has("--verify-b17"):
		_run_b17_live_verification.call_deferred()


func _physics_process(delta: float) -> void:
	_pickup_lockout_remaining = maxf(_pickup_lockout_remaining - delta, 0.0)
	if _pickup_lockout_remaining > 0.0:
		return
	if not available_for_pickup or _player == null:
		return
	if _player.global_position.distance_to(global_position) <= pickup_radius:
		pick_up(_player)


func reveal_for_pickup() -> void:
	_pickup_lockout_remaining = 0.0
	available_for_pickup = true
	was_dropped = false
	_refresh_visual()


func reveal_at(
	reveal_position: Vector3,
	revealed_snack_type: StringName = &""
) -> void:
	if revealed_snack_type != &"":
		set_snack_type(revealed_snack_type)
	global_position = reveal_position
	reveal_for_pickup()


func set_snack_type(next_snack_type: StringName) -> void:
	if snack_type == next_snack_type:
		return
	snack_type = next_snack_type
	snack_type_changed.emit(snack_type)


func pick_up(player: DinnerPlayer) -> bool:
	if (
		not available_for_pickup
		or player == null
		or player.input_locked
		or player.is_attached_to_carrier()
		or _pickup_lockout_remaining > 0.0
	):
		return false
	available_for_pickup = false
	carried_by = player
	carried_by.set_carrying_snack(true)
	was_dropped = false
	_refresh_visual()
	picked_up.emit(carried_by)
	return true


func drop_at(drop_position: Vector3) -> void:
	if _player != null:
		_player.set_carrying_snack(false)
	carried_by = null
	global_position = drop_position
	available_for_pickup = true
	was_dropped = true
	_pickup_lockout_remaining = drop_pickup_lockout
	_refresh_visual()
	dropped.emit(drop_position)


func _refresh_visual() -> void:
	if _visual != null:
		_visual.visible = available_for_pickup


func _run_b17_live_verification() -> void:
	var fridge: DinnerDoor = (
		get_parent().get_node_or_null("Fridge") as DinnerDoor
	)
	var pantry: DinnerDoor = (
		get_parent().get_node_or_null("Pantry") as DinnerDoor
	)
	var parent_actor: DinnerParent = (
		get_parent().get_node_or_null("Parent") as DinnerParent
	)
	var pet_actor: DinnerPet = (
		get_parent().get_node_or_null("Pet") as DinnerPet
	)
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var original_player_position: Vector3 = (
		_player.global_position if _player != null else Vector3.ZERO
	)
	var original_player_processing: bool = (
		_player != null and _player.is_physics_processing()
	)
	var original_player_carrying: bool = (
		_player != null and _player.carrying_snack
	)
	var original_available: bool = available_for_pickup
	var original_carried_by: DinnerPlayer = carried_by
	var original_snack_type: StringName = snack_type
	var original_position: Vector3 = global_position
	var parent_was_processing: bool = (
		parent_actor != null and parent_actor.is_physics_processing()
	)
	var pet_was_processing: bool = (
		pet_actor != null and pet_actor.is_physics_processing()
	)
	var fridge_duration: float = (
		fridge.sneak_open_duration if fridge != null else 0.0
	)
	var pantry_duration: float = (
		pantry.sneak_open_duration if pantry != null else 0.0
	)

	Engine.time_scale = maxf(verify_b17_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(
		verify_b17_physics_ticks_per_second,
		60
	)
	if parent_actor != null:
		parent_actor.set_physics_process(false)
	if pet_actor != null:
		pet_actor.set_physics_process(false)
	if _player != null:
		if _player.is_attached_to_carrier():
			_player.detach_from_carrier(original_player_position)
		_player.set_carrying_snack(false)
		_player.set_input_locked(false)
		_player.set_physics_process(false)
		_player.global_position = verify_b17_observer_position
	_verify_b17_observed_types.clear()
	if not snack_type_changed.is_connected(_capture_b17_snack_type):
		snack_type_changed.connect(_capture_b17_snack_type)
	for _frame_index in range(verify_b17_warmup_frames):
		await get_tree().physics_frame

	var fridge_result: Dictionary = await _verify_b17_door_round_trip(
		fridge,
		TYPE_ICE_CREAM
	)
	var pantry_result: Dictionary = await _verify_b17_door_round_trip(
		pantry,
		TYPE_CHIPS
	)
	var type_signal_exposed: bool = (
		_verify_b17_observed_types.has(TYPE_ICE_CREAM)
		and _verify_b17_observed_types.has(TYPE_CHIPS)
	)
	var verification_passed: bool = (
		bool(fridge_result.get("passed", false))
		and bool(pantry_result.get("passed", false))
		and type_signal_exposed
	)

	if snack_type_changed.is_connected(_capture_b17_snack_type):
		snack_type_changed.disconnect(_capture_b17_snack_type)
	if fridge != null:
		fridge.sneak_open_duration = fridge_duration
		fridge.close_immediately()
	if pantry != null:
		pantry.sneak_open_duration = pantry_duration
		pantry.close_immediately()
	available_for_pickup = original_available
	carried_by = original_carried_by
	snack_type = original_snack_type
	global_position = original_position
	_refresh_visual()
	if _player != null:
		_player.global_position = original_player_position
		_player.set_carrying_snack(original_player_carrying)
		_player.set_physics_process(original_player_processing)
	if parent_actor != null:
		parent_actor.set_physics_process(parent_was_processing)
	if pet_actor != null:
		pet_actor.set_physics_process(pet_was_processing)
	GameClock.running = false
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks

	print(
		(
			"B17 live metrics: fridge door=%s reveal/pick/drop/recollect="
			+ "%s/%s/%s/%s type=%s; pantry door=%s "
			+ "reveal/pick/drop/recollect=%s/%s/%s/%s type=%s; "
			+ "type signal=%s."
		)
		% [
			fridge_result.get("door_type", &""),
			fridge_result.get("revealed", false),
			fridge_result.get("picked_up", false),
			fridge_result.get("dropped", false),
			fridge_result.get("recollected", false),
			fridge_result.get("final_type", &""),
			pantry_result.get("door_type", &""),
			pantry_result.get("revealed", false),
			pantry_result.get("picked_up", false),
			pantry_result.get("dropped", false),
			pantry_result.get("recollected", false),
			pantry_result.get("final_type", &""),
			type_signal_exposed,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(
		bool(fridge_result.get("passed", false)),
		"B17 fridge ice-cream type did not survive its round trip."
	)
	assert(
		bool(pantry_result.get("passed", false)),
		"B17 pantry chips type did not survive its round trip."
	)
	assert(
		type_signal_exposed,
		"B17 snack type changes were not exposed to presenters."
	)
	print("B17 live SceneTree verification passed.")


func _verify_b17_door_round_trip(
	door: DinnerDoor,
	expected_type: StringName
) -> Dictionary:
	var result: Dictionary = {
		"passed": false,
		"door_type": &"",
		"revealed": false,
		"picked_up": false,
		"dropped": false,
		"recollected": false,
		"final_type": &"",
	}
	if door == null or _player == null:
		return result
	door.close_immediately()
	door._snack_revealed = false
	door.sneak_open_duration = maxf(verify_b17_open_duration, 0.001)
	available_for_pickup = false
	carried_by = null
	set_snack_type(&"")
	_player.set_carrying_snack(false)
	_player.global_position = verify_b17_observer_position
	_refresh_visual()
	GameClock.start()
	door.open_to(minf(door.snack_open_threshold + 0.05, 1.0))
	for _frame_index in range(verify_b17_max_frames()):
		await get_tree().physics_frame
		if available_for_pickup:
			break
		if _get_b17_clock_elapsed() >= verify_b17_timeout:
			break
	result["door_type"] = door.snack_type
	result["revealed"] = (
		available_for_pickup
		and snack_type == expected_type
		and door.snack_type == expected_type
	)

	_player.global_position = global_position
	var pickup_start: float = _get_b17_clock_elapsed()
	for _frame_index in range(verify_b17_max_frames()):
		await get_tree().physics_frame
		if carried_by == _player:
			break
		if _get_b17_clock_elapsed() - pickup_start >= verify_b17_timeout:
			break
	result["picked_up"] = (
		carried_by == _player
		and _player.carrying_snack
		and snack_type == expected_type
	)

	var drop_position: Vector3 = global_position + verify_b17_drop_offset
	_player.global_position = verify_b17_observer_position
	drop_at(drop_position)
	result["dropped"] = (
		available_for_pickup
		and carried_by == null
		and snack_type == expected_type
		and global_position.is_equal_approx(drop_position)
	)
	var lockout_start: float = _get_b17_clock_elapsed()
	for _frame_index in range(verify_b17_max_frames()):
		await get_tree().physics_frame
		if (
			_get_b17_clock_elapsed() - lockout_start
			>= drop_pickup_lockout + 0.1
		):
			break
	_player.global_position = drop_position
	var recollect_start: float = _get_b17_clock_elapsed()
	for _frame_index in range(verify_b17_max_frames()):
		await get_tree().physics_frame
		if carried_by == _player:
			break
		if _get_b17_clock_elapsed() - recollect_start >= verify_b17_timeout:
			break
	result["recollected"] = (
		carried_by == _player
		and _player.carrying_snack
		and snack_type == expected_type
	)
	result["final_type"] = snack_type
	result["passed"] = (
		bool(result["revealed"])
		and bool(result["picked_up"])
		and bool(result["dropped"])
		and bool(result["recollected"])
	)
	return result


func verify_b17_max_frames() -> int:
	return maxi(
		int(ceil(verify_b17_timeout * verify_b17_physics_ticks_per_second)),
		1
	)


func _get_b17_clock_elapsed() -> float:
	return GameClock.run_length - GameClock.time_remaining


func _capture_b17_snack_type(next_snack_type: StringName) -> void:
	_verify_b17_observed_types.append(next_snack_type)
