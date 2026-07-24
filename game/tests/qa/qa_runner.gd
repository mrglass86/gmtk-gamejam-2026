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
var _end_count := 0
var _restart_count := 0
var _restart_on_end := false


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
	await _start_live_game()
	if _failed:
		return

	match _scenario:
		"caught-snack":
			await _caught_snack_no_free_win()
		"switch-spam":
			await _switch_spam_stays_coherent()
		"monkey":
			await _monkey_run_reaches_terminal_state()
		"crib-margin":
			await _crib_margin_does_not_award_a_win()
		"expiry":
			await _expiry_during_requested_actor_state()
		"restart-fuzz":
			await _restart_fuzz_on_terminal_transitions()
		"snack-placements":
			await _nasty_snack_placements()
		"carry-collisions":
			await _carry_and_epilogue_collisions()
		_:
			_fail("unknown scenario '%s'" % _scenario)
			return
	if _failed:
		return
	_pass("scenario=%s seed=%d" % [_scenario, _seed])


func _start_live_game() -> void:
	# The production title card pauses the tree.  Use its production transition,
	# rather than a verification-only reset, then let normal physics take over.
	get_tree().paused = false
	await get_tree().process_frame
	await get_tree().physics_frame
	if _flow.state == 0:
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


func _crib_margin_does_not_award_a_win() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 120
	var crib: Node = _main.get_node("Crib")
	# The visible/physics crib half-width is 1.6 m.  At +1.95 m the capsule
	# centre is beside it, but still inside GameFlow's 0.4 m fallback margin.
	var beside_crib: Vector3 = crib.global_position + Vector3(1.95, 0.6, 0.0)
	_player.global_position = beside_crib
	_snack.call("reveal_at", beside_crib)
	_require(_snack.call("pick_up", _player), "crib-margin setup could not collect snack")
	await _wait_physics(3)
	if _flow.state == WON:
		print("QA FINDING: crib-margin win reproduced outside the physical crib width")
	else:
		print("QA crib-margin: no boundary win reproduced")
	print("QA crib-margin metrics: offset=%.2f state=%s" % [
		_player.global_position.distance_to(crib.global_position), _flow.state,
	])
	_require(_flow.state == PLAYING, "outside crib-rail case still produced a win")
	if _failed:
		return
	# Approach through the open end at the same inside position guarded by A6.
	_player.global_position = crib.global_position + Vector3(0.0, 0.15, 1.95)
	await _wait_physics(3)
	_require(_flow.state == WON, "inside crib position no longer produced a win")
	print("QA crib-margin inside: offset=%.2f state=%s" % [
		_player.global_position.distance_to(crib.global_position), _flow.state,
	])


func _expiry_during_requested_actor_state() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 120
	var state_name := _qa_state_from_args()
	_player.global_position = Vector3(-30.0, 0.6, -20.0)
	_player.set_carrying_snack(false)
	await _wait_physics(24)
	await _prepare_expiry_state(state_name)
	if _failed:
		return
	await _wait_physics(4)
	_require(_flow.state == PLAYING, "expiry setup left PLAYING before clock expiry: %s" % state_name)
	_end_count = 0
	if not _flow.game_ended.is_connected(_on_qa_game_ended):
		_flow.game_ended.connect(_on_qa_game_ended)
	GameClock.time_remaining = 0.001
	await get_tree().process_frame
	await get_tree().process_frame
	_require(_end_count == 1, "expiry emitted %d end events in %s" % [_end_count, state_name])
	_require(_flow.state == LOST, "expiry in %s did not end as a clean loss" % state_name)
	_require(not GameClock.running, "expiry in %s left clock running" % state_name)
	_require(_player.input_locked, "expiry in %s left player input enabled" % state_name)
	print("QA expiry metrics: actor_state=%s end_events=%d terminal=LOST" % [state_name, _end_count])


func _qa_state_from_args() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-state="):
			return argument.trim_prefix("--qa-state=")
	return "carry"


func _prepare_expiry_state(state_name: String) -> void:
	match state_name:
		"carry":
			var catch_position := Vector3(-2.0, 0.7, -3.0)
			_parent.global_position = catch_position + Vector3(-0.4, 0.0, 0.0)
			_player.global_position = catch_position
			_parent.call("_begin_found_or_carry")
			_require(_parent.call("get_state_name") == &"CARRY", "could not enter CARRY")
		"found":
			_parent.global_position = Vector3(-2.0, 0.7, -3.0)
			_player.global_position = Vector3(2.0, 0.6, -3.0)
			_parent.call("_begin_found")
			_require(_parent.call("get_state_name") == &"FOUND", "could not enter FOUND")
		"investigate":
			_parent.call("_begin_or_update_investigate", Vector3(4.0, 0.7, -3.0), true)
			_require(_parent.call("get_state_name") == &"INVESTIGATE", "could not enter INVESTIGATE")
		"searchlight":
			var dining_switch: Node = _main.get_node("Level/DiningSwitch")
			_parent.set("_parent_operating_switch", true)
			for zone: String in LightSystem.VALID_ZONES:
				LightSystem.set_zone_enabled(zone, false)
			dining_switch.call("set_state", false, false)
			_parent.set("_parent_operating_switch", false)
			_parent.call("_refresh_light_state_snapshot")
			_parent.global_position = Vector3(-2.0, 0.7, -0.8)
			_parent.call("_begin_or_update_investigate", Vector3(5.2, 0.7, -0.8), true)
			await _wait_physics(90)
			_require(bool(_parent.get("_searchlight_active")), "could not enter active searchlight diversion")
		_:
			var states := {
				"epilogue-exit": 6,
				"epilogue-close": 7,
				"epilogue-hall": 8,
				"epilogue-reopen": 9,
				"epilogue-peek": 10,
				"epilogue-reclose": 11,
				"epilogue-kitchen": 12,
				"epilogue-room-enter": 13,
				"epilogue-room-dwell": 14,
				"epilogue-room-exit": 15,
			}
			_require(states.has(state_name), "unknown expiry actor state: %s" % state_name)
			_parent.call("_set_state", int(states.get(state_name, 6)))


func _restart_fuzz_on_terminal_transitions() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 120
	_flow.reload_scene_on_restart = false
	_restart_count = 0
	_restart_on_end = true
	_flow.restart_requested.connect(_on_qa_restart_requested)
	if not _flow.game_ended.is_connected(_on_qa_game_ended):
		_flow.game_ended.connect(_on_qa_game_ended)
	# Restart on the same frame as a loss, then spam the loss screen.
	GameClock.scrub(GameClock.run_length)
	await get_tree().process_frame
	_require(_flow.state == LOST, "restart loss setup did not produce loss")
	if _failed:
		return
	_restart_on_end = false
	for _press_index: int in range(39):
		_send_restart_to_flow()
	await get_tree().process_frame
	_require(_flow.restart_was_requested, "restart was not registered on loss screen")
	_require(_restart_count == 40, "loss restart fuzz dropped restart events")
	_require(_flow.state == LOST, "suppressed-reload restart mutated losing terminal state")
	print("QA restart metrics: terminal=LOST restart_events=%d same_frame=covered" % _restart_count)
	# Reset through the production title transition to exercise the win edge too.
	_flow.call("_enter_title")
	get_tree().paused = false
	_flow.call("_start_game")
	await _wait_physics(4)
	_require(_flow.state == PLAYING, "could not restart live game after loss fuzz")
	_restart_count = 0
	_restart_on_end = true
	var crib: Node = _main.get_node("Crib")
	# Use the open-end crib approach; its aggregate prop collider makes a
	# centre teleport resolve outward before GameFlow evaluates the win.
	_player.global_position = crib.global_position + Vector3(0.0, 0.15, 1.95)
	_snack.call("reveal_at", _player.global_position)
	_require(_snack.call("pick_up", _player), "restart win setup could not collect snack")
	await _wait_physics(8)
	print("QA restart setup: carrying=%s in_crib=%s state=%s" % [
		_player.carrying_snack, _flow.call("_is_player_in_crib"), _flow.state,
	])
	_require(_flow.state == WON, "restart fuzz setup did not produce win")
	if _failed:
		return
	_restart_on_end = false
	for _press_index: int in range(39):
		_send_restart_to_flow()
	await get_tree().process_frame
	_require(_flow.restart_was_requested, "restart was not registered on result screen")
	_require(_restart_count == 40, "restart fuzz dropped restart events")
	_require(_flow.state == WON, "suppressed-reload restart mutated winning terminal state")
	print("QA restart metrics: terminal=WON restart_events=%d same_frame=covered" % _restart_count)


func _send_restart_to_flow() -> void:
	var event := InputEventAction.new()
	event.action = &"restart"
	event.pressed = true
	_flow.call("_input", event)


func _on_qa_game_ended(_did_win: bool) -> void:
	_end_count += 1
	if _restart_on_end:
		_send_restart_to_flow()


func _on_qa_restart_requested() -> void:
	_restart_count += 1


func _nasty_snack_placements() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 120
	var crib: Node = _main.get_node("Crib")
	var dining_switch: Node = _main.get_node("Level/DiningSwitch")
	var placements: Array[Dictionary] = [
		{"label": "wall", "position": Vector3(-4.3, 0.6, -4.05)},
		{"label": "switch", "position": dining_switch.global_position},
		{"label": "off-navmesh", "position": Vector3(18.0, 0.6, 9.0)},
	]
	for placement: Dictionary in placements:
		var label: String = placement.label
		var position: Vector3 = placement.position
		_player.global_position = Vector3(-30.0, 0.6, -20.0)
		_snack.call("drop_at", position)
		await _wait_physics(100)
		_require(_flow.state == PLAYING, "snack resting at %s won without player" % label)
		_player.global_position = position
		await _wait_physics(3)
		_require(_player.carrying_snack, "snack at %s was not recollectable" % label)
		_player.set_carrying_snack(false)
		_snack.call("drop_at", position)
	# Sitting in the crib must not win by itself; only the player holding it may.
	var crib_position: Vector3 = (
		crib.global_position + Vector3(0.0, 0.15, 1.95)
	)
	_player.global_position = Vector3(-30.0, 0.6, -20.0)
	_snack.call("drop_at", crib_position)
	await _wait_physics(100)
	_require(_flow.state == PLAYING, "snack resting in crib won without player")
	_player.global_position = crib_position
	await _wait_physics(3)
	_require(_player.carrying_snack, "snack resting in crib was not recollectable")
	_require(_flow.state == WON, "player holding snack in crib did not win")
	print("QA snack-placement metrics: tested=wall,switch,off-navmesh,crib passive_crib_win=false")


func _carry_and_epilogue_collisions() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 120
	var pet: Node = _main.get_node("Pet")
	# Catch during the peek must replace the epilogue with exactly one carry.
	_parent.call("_set_state", 10)
	_parent.global_position = Vector3(-2.0, 0.7, -3.0)
	_player.global_position = Vector3(-1.6, 0.6, -3.0)
	_parent.call("_begin_found_or_carry")
	_require(_parent.call("get_state_name") == &"CARRY", "peek collision did not enter carry")
	# A second catch request during carry must be idempotent.
	_parent.call("_begin_found_or_carry")
	_require(_parent.call("get_state_name") == &"CARRY", "second catch disrupted active carry")
	# Complete the production carry transition, then catch the released player.
	_parent.call("_finish_carry")
	await _wait_physics(2)
	_require(not _player.call("is_attached_to_carrier"), "carry completion left player attached")
	_parent.global_position = Vector3(-2.0, 0.7, -3.0)
	_player.global_position = Vector3(-1.6, 0.6, -3.0)
	pet.call("_set_state", 4)
	_parent.call("_begin_found_or_carry")
	_require(_parent.call("get_state_name") == &"CARRY", "second catch after deposit failed")
	_require(pet.call("get_state_name") == &"INVESTIGATE", "pet investigation was lost during catch")
	print("QA carry-collision metrics: peek_carry=true double_catch=true pet_investigate=true")


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
