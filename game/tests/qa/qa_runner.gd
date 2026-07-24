extends Node

## Lane C's black-box-ish runtime harness.  Each invocation instantiates the
## production Main scene and drives its real physics/input paths; it deliberately
## does not call any --verify-* helpers.

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const PLAYING: int = 1
const WON: int = 2
const LOST: int = 3

var _main: Node
var _flow: Node
var _player: Node
var _parent: Node
var _snack: Node
var _rng := RandomNumberGenerator.new()
var _scenario := "caught-snack"
var _seed := 260724
var _failed := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_parse_args()
	_rng.seed = _seed
	_run.call_deferred()


func _parse_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-scenario="):
			_scenario = argument.trim_prefix("--qa-scenario=")
		elif argument.begins_with("--qa-seed="):
			_seed = int(argument.trim_prefix("--qa-seed="))


func _run() -> void:
	_main = MAIN_SCENE.instantiate()
	add_child(_main)
	await get_tree().process_frame
	_flow = _main.get_node("GameFlow")
	_player = _main.get_node("Player")
	_parent = _main.get_node("Parent")
	_snack = _main.get_node("Snack")
	_start_live_game()

	match _scenario:
		"caught-snack":
			await _caught_snack_no_free_win()
		"switch-spam":
			await _switch_spam_stays_coherent()
		"monkey":
			await _monkey_run_reaches_terminal_state()
		_:
			_fail("unknown scenario '%s'" % _scenario)
			return
	if _failed:
		return
	_pass("scenario=%s seed=%d" % [_scenario, _seed])


func _start_live_game() -> void:
	# The production title card pauses the tree.  Use its production transition,
	# rather than a verification-only reset, then let normal physics take over.
	_flow.call("_start_game")
	get_tree().paused = false
	await get_tree().physics_frame
	_require(_flow.state == PLAYING, "production GameFlow did not enter PLAYING")


func _caught_snack_no_free_win() -> void:
	Engine.time_scale = 2.0
	Engine.physics_ticks_per_second = 120
	await _wait_physics(24)

	var catch_position := Vector3(-2.0, 0.7, -3.0)
	_parent.global_position = catch_position + Vector3(-0.35, 0.0, 0.0)
	_player.global_position = catch_position
	_snack.call("reveal_at", catch_position)
	_require(_snack.call("pick_up", _player), "setup could not pick up snack")
	_require(_player.carrying_snack, "snack pickup did not mark player carrying")

	# This is the historical free-win sequence: a catch while holding snack.
	_parent.call("_begin_found_or_carry")
	await _wait_physics(180)

	_require(not _player.carrying_snack, "caught player regained snack during carry")
	_require(_snack.carried_by == null, "caught snack still has a carrier")
	_require(_snack.available_for_pickup, "caught snack was not returned to world")
	_require(_flow.state != WON, "catch with snack produced a free win")
	_require(
		_snack.global_position.distance_to(catch_position) <= 0.35,
		"caught snack did not remain at the catch position"
	)
	print("QA caught-snack metrics: state=%s snack_distance=%.2f attached=%s" % [
		_parent.call("get_state_name"),
		_snack.global_position.distance_to(catch_position),
		_player.call("is_attached_to_carrier"),
	])


func _switch_spam_stays_coherent() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 120
	var switches := get_tree().get_nodes_in_group("world_switch")
	_require(not switches.is_empty(), "no production world switches available")
	var switch: Node = switches[0]
	_player.global_position = switch.global_position
	await _wait_physics(4)
	var starts_on: bool = switch.is_on
	for _press_index: int in range(61):
		# Feed the same InputEvent through the production switch handler.  This
		# keeps the test independent of headless viewport focus.
		var press := InputEventAction.new()
		press.action = &"interact"
		press.pressed = true
		switch.call("_unhandled_input", press)
		await get_tree().physics_frame
		await get_tree().physics_frame
	_require(
		switch.is_on != starts_on,
		"switch spam made no valid state change before the live threat response"
	)
	_require(_flow.state == PLAYING, "switch spam ended the game unexpectedly")
	print("QA switch-spam metrics: switch=%s presses=61 start=%s final=%s player_locked=%s" % [
		switch.name, starts_on, switch.is_on, _player.input_locked,
	])


func _monkey_run_reaches_terminal_state() -> void:
	# 4,500 frames at this tick/time scale consume the production five-minute
	# clock.  Inputs are real InputMap actions and the actors remain enabled.
	Engine.time_scale = 16.0
	Engine.physics_ticks_per_second = 240
	var locked_elapsed := 0.0
	var presses := 0
	for frame_index: int in range(5200):
		if _flow.state != PLAYING:
			break
		if frame_index % _rng.randi_range(4, 17) == 0:
			_randomize_input()
			presses += 1
		await get_tree().physics_frame
		_assert_possible_snack_state()
		var delta := 16.0 / 240.0
		if _player.input_locked and not _player.call("is_attached_to_carrier"):
			locked_elapsed += delta
		else:
			locked_elapsed = 0.0
		_require(
			locked_elapsed <= 22.0,
			"player input stayed locked without carry for %.1f seconds" % locked_elapsed
		)
	_release_inputs()
	_require(
		_flow.state == WON or _flow.state == LOST,
		"clock did not reach a terminal GameFlow state after monkey run"
	)
	_require(not GameClock.running, "terminal GameFlow state left GameClock running")
	print("QA monkey metrics: seed=%d input_changes=%d terminal=%s time=%.2f" % [
		_seed,
		presses,
		"WON" if _flow.state == WON else "LOST",
		GameClock.time_remaining,
	])


func _randomize_input() -> void:
	_release_inputs()
	var directions: Array[StringName] = [&"move_left", &"move_right", &"move_forward", &"move_back"]
	var first: StringName = directions[_rng.randi_range(0, directions.size() - 1)]
	Input.action_press(first)
	if _rng.randf() < 0.30:
		Input.action_press(directions[_rng.randi_range(0, directions.size() - 1)])
	if _rng.randf() < 0.42:
		Input.action_press(&"run")
	if _rng.randf() < 0.36:
		Input.action_press(&"interact")


func _release_inputs() -> void:
	for action: StringName in [&"move_left", &"move_right", &"move_forward", &"move_back", &"run", &"interact"]:
		Input.action_release(action)


func _send_action(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


func _assert_possible_snack_state() -> void:
	if _snack.carried_by != null:
		_require(_player.carrying_snack, "snack has a carrier while player is not carrying")
		_require(not _snack.available_for_pickup, "carried snack is simultaneously pickupable")
	if _player.carrying_snack:
		_require(_snack.carried_by == _player, "player carries snack without snack ownership")


func _wait_physics(frames: int) -> void:
	for _frame_index: int in range(frames):
		await get_tree().physics_frame


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	_release_inputs()
	push_error("QA FAIL [%s]: %s" % [_scenario, message])
	_cleanup_and_quit.call_deferred(1)


func _pass(message: String) -> void:
	_release_inputs()
	print("QA PASS: %s" % message)
	_cleanup_and_quit.call_deferred(0)


func _cleanup_and_quit(exit_code: int) -> void:
	if is_instance_valid(_main):
		_stop_audio(_main)
		_main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_main = null
	_flow = null
	_player = null
	_parent = null
	_snack = null
	get_tree().quit(exit_code)


func _stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer:
		var player_2d := node as AudioStreamPlayer
		player_2d.stop()
		player_2d.stream = null
	elif node is AudioStreamPlayer3D:
		var player_3d := node as AudioStreamPlayer3D
		player_3d.stop()
		player_3d.stream = null
	for child: Node in node.get_children():
		_stop_audio(child)
