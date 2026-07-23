extends CanvasLayer
class_name DinnerGameFlow

## Owns the only three presentation beats in the jam build: title, play, and
## result. The same first-input transition is where the Saturday audio pass
## must start imported audio for Web autoplay compliance.

signal game_started()
signal game_ended(did_win: bool)
signal restart_requested()

enum State {
	TITLE,
	PLAYING,
	WON,
	LOST,
}

@export_group("Scene References")
@export_node_path("DinnerPlayer") var player_path: NodePath = NodePath("../Player")
@export_node_path("Area3D") var crib_goal_path: NodePath = NodePath("../Crib/WinArea")
@export_node_path("Control") var title_card_path: NodePath = NodePath("TitleCard")
@export_node_path("Control") var result_card_path: NodePath = NodePath("ResultCard")
@export_node_path("Label") var result_heading_path: NodePath = NodePath(
	"ResultCard/Panel/ResultHeading"
)
@export_node_path("Label") var result_detail_path: NodePath = NodePath(
	"ResultCard/Panel/ResultDetail"
)

@export_group("Crib Goal")
@export var goal_body_margin: float = 0.4

var state: State = State.TITLE
var restart_was_requested: bool = false
var reload_scene_on_restart: bool = true

var _player: DinnerPlayer
var _crib_goal: Area3D
var _title_card: Control
var _result_card: Control
var _result_heading: Label
var _result_detail: Label
var _verification_mode: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as DinnerPlayer
	_crib_goal = get_node_or_null(crib_goal_path) as Area3D
	_title_card = get_node_or_null(title_card_path) as Control
	_result_card = get_node_or_null(result_card_path) as Control
	_result_heading = get_node_or_null(result_heading_path) as Label
	_result_detail = get_node_or_null(result_detail_path) as Label
	_verification_mode = OS.get_cmdline_user_args().has("--verify-a6")

	if _should_bypass_presentation():
		visible = false
		return

	assert(_player != null, "GameFlow is missing its player reference.")
	assert(_crib_goal != null, "GameFlow is missing its crib goal reference.")
	assert(_title_card != null and _result_card != null, "GameFlow cards are not wired.")
	if not GameClock.time_expired.is_connected(_on_time_expired):
		GameClock.time_expired.connect(_on_time_expired)
	_enter_title()


func _physics_process(_delta: float) -> void:
	if state != State.PLAYING or _player == null:
		return
	if _player.carrying_snack and _is_player_in_crib():
		_finish_game(true)


func _input(event: InputEvent) -> void:
	if state == State.TITLE and _is_first_input(event):
		_start_game()
		get_viewport().set_input_as_handled()
		return
	if (state == State.WON or state == State.LOST) and event.is_action_pressed(&"restart"):
		_request_restart()
		get_viewport().set_input_as_handled()


func qualifies_for_expiry_win(in_crib: bool, has_snack: bool) -> bool:
	return in_crib and has_snack


func prepare_verification_case() -> void:
	assert(_verification_mode, "Verification reset is only available to the A6 harness.")
	get_tree().paused = false
	restart_was_requested = false
	reload_scene_on_restart = false
	_player.global_position = Vector3(-12.4, 0.6, -4.0)
	_player.set_carrying_snack(false)
	_enter_title()


func _enter_title() -> void:
	state = State.TITLE
	GameClock.running = false
	GameClock.time_remaining = GameClock.run_length
	GameClock.phase = 0
	GameClock.phase_changed.emit(0)
	_player.set_input_locked(true)
	_title_card.visible = true
	_result_card.visible = false
	get_tree().paused = true


func _start_game() -> void:
	if state != State.TITLE:
		return
	state = State.PLAYING
	_title_card.visible = false
	_result_card.visible = false
	get_tree().paused = false
	_player.set_input_locked(false)
	GameClock.start()
	game_started.emit()


func _finish_game(did_win: bool) -> void:
	if state != State.PLAYING:
		return
	state = State.WON if did_win else State.LOST
	GameClock.running = false
	_player.set_input_locked(true)
	_title_card.visible = false
	_result_card.visible = true
	if did_win:
		_result_heading.text = "BACK IN BED"
		_result_detail.text = "Snack secured. Bedtime never saw it coming."
	else:
		_result_heading.text = "BEDTIME"
		_result_detail.text = "No snack in the crib when the clock ran out."
	game_ended.emit(did_win)
	get_tree().paused = true


func _on_time_expired() -> void:
	if state != State.PLAYING:
		return
	_finish_game(
		qualifies_for_expiry_win(
			_is_player_in_crib(),
			_player != null and _player.carrying_snack
		)
	)


func _request_restart() -> void:
	restart_was_requested = true
	restart_requested.emit()
	if not reload_scene_on_restart:
		return
	get_tree().paused = false
	var reload_error: Error = get_tree().reload_current_scene()
	if reload_error != OK:
		push_error("Could not reload the current scene (error %d)." % reload_error)


func _is_player_in_crib() -> bool:
	if _crib_goal == null or _player == null:
		return false
	if _crib_goal.overlaps_body(_player):
		return true
	var collision: CollisionShape3D = _crib_goal.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision == null:
		return false
	var goal_shape: BoxShape3D = collision.shape as BoxShape3D
	if goal_shape == null:
		return false
	var local_player_position: Vector3 = collision.to_local(_player.global_position)
	var half_size: Vector3 = goal_shape.size * 0.5
	return (
		absf(local_player_position.x) <= half_size.x + goal_body_margin
		and absf(local_player_position.y) <= half_size.y
		and absf(local_player_position.z) <= half_size.z + goal_body_margin
	)


func _is_first_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		return key_event.pressed and not key_event.echo
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).pressed
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventAction:
		return (event as InputEventAction).pressed
	return false


func _should_bypass_presentation() -> bool:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--verify-a6" or argument.begins_with("--capture-a6-title="):
			continue
		if argument.begins_with("--verify-") or argument.begins_with("--capture-layout="):
			return true
	return false
