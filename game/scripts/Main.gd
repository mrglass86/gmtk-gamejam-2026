extends Node3D

## Entry-point helpers owned by lane A. The layout capture is opt-in and is used
## only for director review: pass --capture-layout=/absolute/path/to/file.png.

@export var capture_warmup_frames: int = 12

var _a2_received_loudness: float = -1.0

const REQUIRED_ACTIONS: PackedStringArray = [
	"move_left",
	"move_right",
	"move_forward",
	"move_back",
	"run",
	"interact",
	"restart",
	"debug_skip",
	"debug_rewind",
	"debug_overlay",
	"debug_teleport",
	"debug_spawn_noise",
	"debug_spawn_lamp",
	"debug_remove_lamp",
]


func _ready() -> void:
	_verify_input_map()
	if OS.get_cmdline_user_args().has("--verify-a1"):
		_verify_light_system()
		get_tree().quit()
		return
	if OS.get_cmdline_user_args().has("--verify-a2"):
		_verify_noise_system()
		get_tree().quit()
		return
	if OS.get_cmdline_user_args().has("--verify-a3"):
		_verify_noise_indicators()
		return
	if OS.get_cmdline_user_args().has("--verify-a02"):
		_verify_a02_navigation()
		return
	if OS.get_cmdline_user_args().has("--verify-a4"):
		_verify_ambient_masks()
		get_tree().quit()
		return
	if OS.get_cmdline_user_args().has("--verify-a41"):
		_verify_a41_playtest_fixes()
		return
	if OS.get_cmdline_user_args().has("--verify-a5"):
		_verify_a5_clock_and_phases()
		return
	if OS.get_cmdline_user_args().has("--verify-a51"):
		_verify_a51_second_walk_fixes()
		return
	if OS.get_cmdline_user_args().has("--verify-a6"):
		_verify_a6_game_flow()
		return
	if OS.get_cmdline_user_args().has("--verify-a7"):
		_verify_a7_presentation()
		return
	if OS.get_cmdline_user_args().has("--verify-a8"):
		_verify_a8_tuning()
		return
	if OS.get_cmdline_user_args().has("--verify-a9"):
		_verify_a9_practical_lighting()
		return
	if OS.get_cmdline_user_args().has("--verify-a10"):
		_verify_a10_presentation()
		return
	if OS.get_cmdline_user_args().has("--verify-audio"):
		_verify_audio_pass()
		return
	var capture_path: String = _capture_path_from_args()
	if not capture_path.is_empty():
		_capture_layout(capture_path)
		return
	var a6_capture_path: String = _a6_capture_path_from_args()
	if not a6_capture_path.is_empty():
		_capture_layout(a6_capture_path)


func _verify_input_map() -> void:
	for action: String in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			push_error("Missing required input action: %s" % action)
			return
	print("A0 input map verified: %d required actions present." % REQUIRED_ACTIONS.size())


func _verify_light_system() -> void:
	var bedroom_anchor: Vector3 = Vector3(-10.2, 0.0, -5.6)
	assert(is_equal_approx(LightSystem.get_brightness_at(bedroom_anchor), 1.0))
	assert(is_zero_approx(LightSystem.get_brightness_at(Vector3(-30.0, 0.0, 0.0))))

	var max_probe: Vector3 = Vector3(30.0, 0.0, 0.0)
	LightSystem.register_light("a1_max_low", "bedroom", Vector3(33.0, 0.0, 0.0), 10.0)
	LightSystem.register_light("a1_max_high", "bedroom", Vector3(34.0, 0.0, 0.0), 10.0)
	assert(is_equal_approx(LightSystem.get_brightness_at(max_probe), 0.7))
	LightSystem.unregister_light("a1_max_low")
	LightSystem.unregister_light("a1_max_high")

	LightSystem.set_zone_enabled("bedroom", false)
	assert(is_zero_approx(LightSystem.get_brightness_at(bedroom_anchor)))
	LightSystem.set_zone_enabled("bedroom", true)
	assert(is_equal_approx(LightSystem.get_brightness_at(bedroom_anchor), 1.0))
	print("A1 LightSystem verification passed: linear falloff, max contribution, and zone toggling.")


func _verify_noise_system() -> void:
	NoiseSystem.noise_emitted.connect(_capture_a2_noise)
	NoiseSystem.emit_noise(Vector3.ZERO, 1.25, self)
	NoiseSystem.noise_emitted.disconnect(_capture_a2_noise)
	assert(is_equal_approx(_a2_received_loudness, 1.25))

	var mask_probe: Vector3 = Vector3(40.0, 0.0, 0.0)
	assert(is_zero_approx(NoiseSystem.get_mask_at(mask_probe)))
	NoiseSystem.register_ambient_source("a2_low", mask_probe, 10.0, 0.3)
	NoiseSystem.register_ambient_source("a2_high", mask_probe, 10.0, 0.8)
	assert(is_equal_approx(NoiseSystem.get_mask_at(mask_probe), 0.8))
	NoiseSystem.unregister_ambient_source("a2_low")
	NoiseSystem.unregister_ambient_source("a2_high")

	LightSystem.register_dynamic_light("a2_fridge_probe", mask_probe)
	LightSystem.set_dynamic_light("a2_fridge_probe", 10.0, 0.6)
	assert(is_equal_approx(LightSystem.get_brightness_at(mask_probe), 0.6))
	LightSystem.unregister_dynamic_light("a2_fridge_probe")
	print("A2 verification passed: pure noise broadcast, strongest ambient mask, and dynamic fridge light.")


func _capture_a2_noise(_pos: Vector3, loudness: float, _source: Node) -> void:
	_a2_received_loudness = loudness


func _verify_noise_indicators() -> void:
	NoiseSystem.emit_noise(Vector3.ZERO, 0.08, self)
	NoiseSystem.emit_noise(Vector3.ZERO, 0.40, self)
	NoiseSystem.emit_noise(Vector3.ZERO, 1.0, self)
	NoiseSystem.emit_noise(Vector3.ZERO, 1.2, self)
	NoiseSystem.emit_noise(Vector3.ZERO, 4.0, self)
	await get_tree().process_frame
	var manager: Node3D = $NoiseIndicatorManager
	assert(manager.get_child_count() == 4)
	var loudest_indicator: Node = manager.get_child(3)
	assert(is_equal_approx(float(loudest_indicator.get("max_radius")), 20.0))
	print("A3 verification passed: absolute 0.25 gate and 20 m audibility cap.")
	get_tree().quit()


func _verify_a02_navigation() -> void:
	var navigation_map: RID = get_world_3d().navigation_map
	for sync_frame: int in range(12):
		await get_tree().physics_frame
	assert(
		NavigationServer3D.map_get_iteration_id(navigation_map) > 0,
		"Navigation map did not complete its first synchronization."
	)
	var l_wall_path: PackedVector3Array = NavigationServer3D.map_get_path(
		navigation_map, Vector3(0.0, 0.0, 5.4), Vector3(0.0, 0.0, 2.5), true
	)
	assert(l_wall_path.size() > 2, "L-wall path did not detour.")
	var l_wall_detour: bool = false
	for point: Vector3 in l_wall_path:
		if point.x < -4.7 or point.x > 5.2:
			l_wall_detour = true
			break
	assert(l_wall_detour, "Navigation path crossed the L-wall instead of routing around it.")

	var pantry_path: PackedVector3Array = NavigationServer3D.map_get_path(
		navigation_map, Vector3(8.0, 0.0, 5.8), Vector3(13.2, 0.0, 4.4), true
	)
	assert(pantry_path.size() > 2, "Pantry-wall path did not detour.")
	var used_pantry_door: bool = false
	for point: Vector3 in pantry_path:
		if point.z < 2.6:
			used_pantry_door = true
			break
	assert(used_pantry_door, "Navigation path crossed PantryWest instead of using the north opening.")
	print("A0.2 navigation verification passed: L-wall and pantry-wall detours.")
	get_tree().quit()


func _verify_ambient_masks() -> void:
	var tv_position: Vector3 = Vector3(-2.75, 0.0, -4.1)
	var speaker_position: Vector3 = Vector3(8.5, 0.0, -5.3)
	var tv_mask: float = NoiseSystem.get_mask_at(tv_position)
	var speaker_mask: float = NoiseSystem.get_mask_at(speaker_position)
	assert(tv_mask > 0.0 and tv_mask <= 0.6)
	assert(speaker_mask > 0.0 and speaker_mask <= 0.6)
	assert(is_zero_approx(NoiseSystem.get_mask_at(tv_position + Vector3(0.0, 0.0, 3.3))))
	assert(
		is_zero_approx(
			NoiseSystem.get_mask_at(speaker_position + Vector3(0.0, 0.0, 2.5))
		)
	)

	var player: DinnerPlayer = $Player as DinnerPlayer
	var indicator_manager: Node3D = $NoiseIndicatorManager as Node3D
	player.global_position = Vector3(2.0, 0.6, 0.0)
	player.call("_emit_masked_noise", 1.0)
	var clear_ring: NoiseIndicator = indicator_manager.get_child(
		indicator_manager.get_child_count() - 1
	) as NoiseIndicator
	player.global_position = tv_position + Vector3.UP * 0.6
	player.call("_emit_masked_noise", 1.0)
	var tv_ring: NoiseIndicator = indicator_manager.get_child(
		indicator_manager.get_child_count() - 1
	) as NoiseIndicator
	assert(tv_ring.max_radius > 0.0)
	assert(
		tv_ring.max_radius < clear_ring.max_radius,
		"Player ring did not visibly shrink inside the TV mask."
	)
	clear_ring.free()
	tv_ring.free()

	NoiseSystem.set_ambient_source_enabled("tv", false)
	assert(is_zero_approx(NoiseSystem.get_mask_at(tv_position)))
	NoiseSystem.set_ambient_source_enabled("tv", true)
	assert(is_equal_approx(NoiseSystem.get_mask_at(tv_position), tv_mask))

	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", false)
	assert(is_zero_approx(NoiseSystem.get_mask_at(speaker_position)))
	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", true)
	assert(is_equal_approx(NoiseSystem.get_mask_at(speaker_position), speaker_mask))
	print(
		"A4 verification passed: tight nonzero masks register, player rings shrink, "
		+ "and sources vanish when disabled."
	)


func _verify_a41_playtest_fixes() -> void:
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var player: CharacterBody3D = get_tree().get_first_node_in_group("player") as CharacterBody3D
	assert(player != null, "Brightness/player lookup group is not wired.")

	var hazard_names: PackedStringArray = [
		"CreakTeacher",
		"CreakKitchen",
		"CreakAdult",
		"ToyHallRug",
		"ToyDining",
		"ToyCarpet",
	]
	for hazard_name: String in hazard_names:
		var hazard: NoiseSurface = get_node("Level/%s" % hazard_name) as NoiseSurface
		assert(hazard.surface_height <= 0.03, "%s is too tall to walk over." % hazard_name)
		var collisions: Array[Node] = hazard.find_children("*", "CollisionShape3D", true, false)
		assert(collisions.size() == 1, "%s needs exactly one overlay collider." % hazard_name)
		var collision: CollisionShape3D = collisions[0] as CollisionShape3D
		assert(collision.position.y >= 0.0, "%s collision is not floor-flush." % hazard_name)

	var bathroom_door: DinnerDoor = get_node(
		"Level/BathroomDoor"
	) as DinnerDoor
	assert(bathroom_door != null)
	assert(
		bathroom_door.get_node_or_null("Blocker/CollisionShape3D") != null,
		"Bathroom quiet-zone door has no scripted doorway blocker."
	)
	_verify_wall_junctions()

	var indicator_manager: Node3D = $NoiseIndicatorManager
	assert(indicator_manager.get_child_count() == 0)
	assert(is_equal_approx(float(player.get("_current_surface_multiplier")), 0.2))
	Input.action_press("move_right")
	await get_tree().create_timer(0.5).timeout
	Input.action_release("move_right")
	await get_tree().process_frame
	assert(
		indicator_manager.get_child_count() == 0,
		"Sneaking on kid-room carpet rendered a noise indicator."
	)

	NoiseSystem.emit_noise(player.global_position, 0.24, player)
	await get_tree().process_frame
	assert(indicator_manager.get_child_count() == 0, "Sub-threshold noise rendered.")
	NoiseSystem.emit_noise(player.global_position, 0.4, player)
	await get_tree().process_frame
	assert(indicator_manager.get_child_count() == 1, "Audible noise did not render one ring.")
	var indicator: Node3D = indicator_manager.get_child(0) as Node3D
	var anchored_position: Vector3 = indicator.global_position
	player.global_position += Vector3(0.5, 0.0, 0.0)
	await get_tree().process_frame
	assert(
		indicator.global_position.is_equal_approx(anchored_position),
		"Noise indicator followed the player instead of staying world-anchored."
	)
	await get_tree().create_timer(1.3).timeout
	assert(indicator_manager.get_child_count() == 0, "Noise indicator did not expire.")
	print("A4.1 verification passed: seams, overlays, set dressing, brightness lookup, and rings.")
	get_tree().quit()


func _verify_wall_junctions() -> void:
	var junctions: Array[PackedStringArray] = [
		PackedStringArray(["NorthWall", "WestWall"]),
		PackedStringArray(["NorthWall", "EastWall"]),
		PackedStringArray(["SouthWall", "WestWall"]),
		PackedStringArray(["SouthWall", "EastWall"]),
		PackedStringArray(["KidSouthA", "WestWall"]),
		PackedStringArray(["KidSouthB", "KidBathDivider"]),
		PackedStringArray(["KidBathDivider", "NorthWall"]),
		PackedStringArray(["BathLivingDivider", "NorthWall"]),
		PackedStringArray(["BathLivingDivider", "LivingSouth"]),
		PackedStringArray(["DogKitchenDivider", "NorthWall"]),
		PackedStringArray(["AdultNorthA", "WestWall"]),
		PackedStringArray(["AdultNorthB", "AdultEast"]),
		PackedStringArray(["AdultEast", "SouthWall"]),
		PackedStringArray(["LVertical", "LHorizontal"]),
		PackedStringArray(["PantryWest", "SouthWall"]),
	]
	var minimum_overlap: float = 0.249
	for junction: PackedStringArray in junctions:
		var first_aabb: AABB = _wall_world_aabb(get_node("Level/%s" % junction[0]) as Node3D)
		var second_aabb: AABB = _wall_world_aabb(get_node("Level/%s" % junction[1]) as Node3D)
		var overlap: Vector3 = first_aabb.intersection(second_aabb).size
		assert(
			overlap.x >= minimum_overlap and overlap.z >= minimum_overlap,
			"Wall seam at %s/%s has only %s overlap." % [junction[0], junction[1], overlap]
		)


func _wall_world_aabb(wall: Node3D) -> AABB:
	var mesh_instance: MeshInstance3D = wall.get_child(0) as MeshInstance3D
	return mesh_instance.global_transform * mesh_instance.get_aabb()


func _verify_a5_clock_and_phases() -> void:
	await get_tree().process_frame
	var phase_director: Node = $PhaseDirector
	var debug_tools: Node = $DebugTools
	var clock_label: Label3D = $NightstandClock as Label3D

	GameClock.start()
	GameClock.running = false
	await get_tree().process_frame
	assert(GameClock.phase == 0 and is_equal_approx(GameClock.time_remaining, 300.0))
	clock_label.call("_update_text")
	assert(clock_label.text == "5:00")
	assert(clock_label.modulate.r > 0.8 and clock_label.modulate.g < 0.2)
	assert(($Level/LivingLampVisual as Node3D).visible)
	assert(NoiseSystem.get_mask_at(Vector3(-2.75, 0.0, -4.1)) > 0.0)

	GameClock.scrub(60.0)
	assert(GameClock.phase == 1 and is_equal_approx(GameClock.time_remaining, 240.0))
	assert(not ($Level/LivingLampVisual as Node3D).visible)

	GameClock.scrub(60.0)
	assert(GameClock.phase == 2 and is_equal_approx(GameClock.time_remaining, 180.0))
	assert(not ($Level/TVGlow as Node3D).visible)
	assert(is_zero_approx(NoiseSystem.get_mask_at(Vector3(-2.75, 0.0, -4.1))))

	GameClock.scrub(60.0)
	assert(GameClock.phase == 3 and is_equal_approx(GameClock.time_remaining, 120.0))
	assert(not ($Level/KitchenLampVisual as Node3D).visible)
	assert(is_zero_approx(NoiseSystem.get_mask_at(Vector3(8.5, 0.0, -5.3))))

	GameClock.scrub(60.0)
	assert(GameClock.phase == 4 and is_equal_approx(GameClock.time_remaining, 60.0))
	assert(not ($Level/MidLampVisual as Node3D).visible)
	assert(not ($Level/AlcoveLampVisual as Node3D).visible)

	GameClock.scrub(-120.0)
	assert(GameClock.phase == 2 and is_equal_approx(GameClock.time_remaining, 180.0))
	assert(($Level/KitchenLampVisual as Node3D).visible)
	assert(($Level/MidLampVisual as Node3D).visible)
	assert(NoiseSystem.get_mask_at(Vector3(8.5, 0.0, -5.3)) > 0.0)
	assert(not ($Level/LivingLampVisual as Node3D).visible)
	assert(not ($Level/TVGlow as Node3D).visible)

	GameClock.start()
	GameClock.running = false
	var skip_event: InputEventAction = InputEventAction.new()
	skip_event.action = &"debug_skip"
	skip_event.pressed = true
	debug_tools.call("_unhandled_input", skip_event)
	assert(is_equal_approx(GameClock.time_remaining, 270.0))
	var rewind_event: InputEventAction = InputEventAction.new()
	rewind_event.action = &"debug_rewind"
	rewind_event.pressed = true
	debug_tools.call("_unhandled_input", rewind_event)
	assert(is_equal_approx(GameClock.time_remaining, 300.0))
	var overlay_event: InputEventAction = InputEventAction.new()
	overlay_event.action = &"debug_overlay"
	overlay_event.pressed = true
	debug_tools.call("_unhandled_input", overlay_event)
	assert(bool(debug_tools.call("is_overlay_visible")))

	for sync_frame: int in range(12):
		await get_tree().physics_frame
	var screen_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	assert(bool(debug_tools.call("teleport_player_to_screen_point", screen_center)))
	var debug_surface: NoiseSurface = debug_tools.call(
		"spawn_noise_surface_at_screen_point", screen_center
	) as NoiseSurface
	assert(debug_surface != null and debug_surface.surface_height <= 0.03)
	debug_surface.queue_free()

	phase_director.call("apply_phase", 0)
	assert(($Level/LivingLampVisual as Node3D).visible)
	assert(($Level/TVGlow as Node3D).visible)
	print("A5 verification passed: clock thresholds, pure phase restore, debug tools, and world clock.")
	get_tree().quit()


func _verify_a51_second_walk_fixes() -> void:
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var failsafe: StaticBody3D = $Level/FailsafeSlab as StaticBody3D
	assert(failsafe.is_in_group("surface_hardwood"))
	assert(not failsafe.is_in_group("nav_source"))
	var failsafe_mesh: MeshInstance3D = failsafe.get_child(0) as MeshInstance3D
	var failsafe_aabb: AABB = failsafe_mesh.global_transform * failsafe_mesh.get_aabb()
	assert(is_equal_approx(failsafe_aabb.size.x, 30.0))
	assert(is_equal_approx(failsafe_aabb.size.z, 12.8))
	assert(is_equal_approx(failsafe_aabb.end.y, -0.05))
	assert(
		not failsafe.find_children("*", "CollisionShape3D", true, false).is_empty(),
		"Failsafe slab has no collision."
	)
	_verify_primary_floor_coverage()

	var player: CharacterBody3D = $Player as CharacterBody3D
	player.global_position = Vector3(9.0, 0.6, 2.8)
	player.velocity = Vector3.ZERO
	for fall_frame: int in range(12):
		await get_tree().physics_frame
	assert(player.global_position.y >= 0.5, "Player fell through the repaired east-hall floor.")
	assert(player.is_on_floor(), "Player did not settle on the repaired east-hall floor.")

	var fridge: DinnerDoor = $Fridge as DinnerDoor
	var fridge_hinge: Node3D = $Fridge/DoorVisual
	var fridge_panel: MeshInstance3D = $Fridge/DoorVisual/Panel as MeshInstance3D
	assert(is_equal_approx(fridge_hinge.position.z, -1.1))
	assert(is_equal_approx(fridge_panel.position.z, 1.1))
	fridge.set("openness", 1.0)
	fridge.call("_apply_visual")
	assert(is_equal_approx(fridge_hinge.rotation_degrees.y, -90.0))
	var panel_aabb: AABB = fridge_panel.global_transform * fridge_panel.get_aabb()
	var north_wall_aabb: AABB = _wall_world_aabb($Level/NorthWall as Node3D)
	assert(
		panel_aabb.intersects(north_wall_aabb),
		"Open fridge panel does not rest against the north wall."
	)

	var parent: Node3D = $Parent
	var rows: Array = parent.get("routine_rows") as Array
	var expected_times: PackedFloat32Array = [
		0.0, 60.0, 82.0, 182.8, 187.5, 189.4, 206.3, 211.0,
		213.8, 242.8, 244.8, 251.9, 258.0, 268.9, 289.3,
	]
	var expected_dwells: PackedFloat32Array = [
		53.0, 15.0, 98.0, 0.0, 0.0, 15.0, 0.0, 0.0,
		26.2, 0.0, 2.0, 2.0, 5.0, 5.0, 10.7,
	]
	assert(rows.size() == expected_times.size())
	for row_index: int in range(rows.size()):
		var row: Dictionary = rows[row_index]
		assert(is_equal_approx(float(row["time"]), expected_times[row_index]))
		assert(is_equal_approx(float(row["dwell"]), expected_dwells[row_index]))
	assert((rows[5]["position"] as Vector3).is_equal_approx(Vector3(-5.8, 0.7, -3.5)))
	assert((rows[13]["position"] as Vector3).is_equal_approx(Vector3(8.0, 0.7, 4.8)))
	assert((rows[14]["position"] as Vector3).is_equal_approx(Vector3(-12.75, 0.7, -0.8)))

	print("A5.1/B5 wiring verification passed: floor/fridge fixes and authoritative route table.")
	get_tree().quit()


func _verify_a6_game_flow() -> void:
	var flow: DinnerGameFlow = $GameFlow as DinnerGameFlow
	var player: DinnerPlayer = $Player as DinnerPlayer
	var title_card: Control = $GameFlow/TitleCard as Control
	var result_card: Control = $GameFlow/ResultCard as Control
	var camera: Camera3D = $CameraRig/OrthoCamera as Camera3D
	var brightness_readout: CanvasLayer = $BrightnessReadout as CanvasLayer

	if GameClock.has_meta(&"a6_restart_verification"):
		GameClock.remove_meta(&"a6_restart_verification")
		assert(flow.state == DinnerGameFlow.State.TITLE)
		assert(title_card.visible and not result_card.visible)
		assert(not GameClock.running and player.input_locked and get_tree().paused)
		print(
			"A6/A6.1 verification passed: camera, title, clock, immediate/expiry outcomes, "
			+ "real scene reload, and release HUD gate."
		)
		get_tree().paused = false
		await get_tree().physics_frame
		await get_tree().process_frame
		get_tree().quit()
		return

	assert(flow.state == DinnerGameFlow.State.TITLE)
	assert(camera.keep_aspect == Camera3D.KEEP_WIDTH)
	assert(is_equal_approx(camera.size, 31.0))
	assert(brightness_readout.visible == OS.is_debug_build())
	assert($GameFlow.find_children("*", "AudioStreamPlayer", true, false).is_empty())
	assert(title_card.visible and not result_card.visible)
	assert(not GameClock.running and is_equal_approx(GameClock.time_remaining, 300.0))
	assert(player.input_locked and get_tree().paused)
	assert(
		($GameFlow/TitleCard/Panel/Controls as Label).text.contains("WASD / ARROWS")
	)
	assert(($GameFlow/TitleCard/Panel/Controls as Label).text.contains("HOLD E"))
	assert($GameFlow.find_children("*", "Button", true, false).is_empty())

	var start_event: InputEventKey = InputEventKey.new()
	start_event.pressed = true
	start_event.physical_keycode = KEY_SPACE
	flow.call("_input", start_event)
	assert(flow.state == DinnerGameFlow.State.PLAYING)
	assert(GameClock.running and not player.input_locked and not get_tree().paused)
	assert(not title_card.visible)
	assert(flow.qualifies_for_expiry_win(true, true))
	assert(not flow.qualifies_for_expiry_win(true, false))
	assert(not flow.qualifies_for_expiry_win(false, true))
	await get_tree().process_frame
	await get_tree().physics_frame

	player.global_position = Vector3(-8.7, 0.6, -2.75)
	player.set_carrying_snack(true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(
		flow.state == DinnerGameFlow.State.WON,
		"Crib goal missed player at %s; overlaps=%s." % [
			player.global_position,
			($Crib/WinArea as Area3D).get_overlapping_bodies(),
		]
	)
	assert(result_card.visible and not GameClock.running and player.input_locked)
	assert(($GameFlow/ResultCard/Panel/ResultHeading as Label).text == "BACK IN BED")

	flow.prepare_verification_case()
	flow.call("_input", start_event)
	player.global_position = Vector3(-8.7, 0.6, -2.75)
	player.set_carrying_snack(true)
	GameClock.time_expired.emit()
	assert(flow.state == DinnerGameFlow.State.WON)
	assert(($GameFlow/ResultCard/Panel/ResultHeading as Label).text == "BACK IN BED")

	flow.prepare_verification_case()
	flow.call("_input", start_event)
	player.global_position = Vector3(-12.4, 0.6, -4.0)
	player.set_carrying_snack(false)
	GameClock.time_expired.emit()
	assert(flow.state == DinnerGameFlow.State.LOST)
	assert(($GameFlow/ResultCard/Panel/ResultHeading as Label).text == "BEDTIME")

	var restart_event: InputEventAction = InputEventAction.new()
	restart_event.action = &"restart"
	restart_event.pressed = true
	flow.reload_scene_on_restart = true
	GameClock.set_meta(&"a6_restart_verification", true)
	start_event = null
	flow.call("_input", restart_event)


func _verify_audio_pass() -> void:
	var audio_director: DinnerAudioDirector = $AudioDirector as DinnerAudioDirector
	audio_director.verify_configuration()
	audio_director.begin_audio_verification()
	await get_tree().process_frame
	assert(
		$AudioDirector/TVClickOff is AudioStreamPlayer3D
		and $AudioDirector/PlayerFootsteps is AudioStreamPlayer
		and $AudioDirector/TVBed is AudioStreamPlayer3D
	)
	print(
		"Audio verification passed: first-input beds, countdown tells, footsteps, "
		+ "pet/result/snack cues, positional sources, and zero bus effects."
	)
	audio_director.end_audio_verification()
	for settle_frame: int in range(8):
		await get_tree().process_frame
	get_tree().quit()


func _verify_a7_presentation() -> void:
	assert(
		int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 1920
	)
	assert(
		int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 1080
	)
	assert(bool(ProjectSettings.get_setting("display/window/size/resizable")))
	assert(
		String(ProjectSettings.get_setting("display/window/stretch/mode"))
		== "canvas_items"
	)
	assert(
		String(ProjectSettings.get_setting("display/window/stretch/aspect"))
		== "expand"
	)

	var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
	var fridge: DinnerDoor = $Fridge as DinnerDoor
	var fridge_light: OmniLight3D = $Fridge/SpillLight as OmniLight3D
	phase_director.apply_fridge_open_rate(0.25)
	assert(
		is_equal_approx(
			fridge_light.light_energy,
			0.25 * fridge.fridge_spill_energy_per_open_rate
		)
	)
	assert(
		is_equal_approx(
			fridge_light.omni_range,
			0.25 * fridge.fridge_spill_radius_per_open_rate
		)
	)
	phase_director.apply_fridge_open_rate(0.0)
	assert(is_zero_approx(fridge_light.light_energy))

	var tv_glow: AreaLight3D = $Level/TVGlow as AreaLight3D
	phase_director.apply_phase(1)
	phase_director.set("_tv_flicker_time", 0.35)
	phase_director.apply_tv_flicker()
	var tv_base_energy: float = float(phase_director.get("_tv_base_energy"))
	assert(not is_equal_approx(tv_glow.light_energy, tv_base_energy))
	assert(
		tv_glow.light_energy
		>= tv_base_energy * (1.0 - phase_director.tv_flicker_amount)
		and tv_glow.light_energy
		<= tv_base_energy * (1.0 + phase_director.tv_flicker_amount)
	)
	phase_director.apply_phase(2)
	assert(not tv_glow.visible)

	var audio_director: DinnerAudioDirector = $AudioDirector as DinnerAudioDirector
	audio_director.call("_on_game_started")
	var bedroom_door: DinnerDoor = $BedroomDoor as DinnerDoor
	bedroom_door.openness += 0.2 / 60.0
	audio_director.call("_update_door_creak", 1.0 / 60.0)
	var door_creak_player: AudioStreamPlayer3D = (
		$AudioDirector/DoorCreak as AudioStreamPlayer3D
	)
	assert(
		door_creak_player.playing,
		"Door creak player must play while openness changes."
	)
	var slow_creak_volume: float = door_creak_player.volume_db
	audio_director.call("_update_door_creak", 1.0 / 60.0)
	assert(not door_creak_player.playing)
	bedroom_door.openness += 1.0 / 60.0
	audio_director.call("_update_door_creak", 1.0 / 60.0)
	assert(door_creak_player.playing)
	assert(door_creak_player.volume_db > slow_creak_volume)

	var snack: DinnerSnack = $Snack as DinnerSnack
	var player: DinnerPlayer = $Player as DinnerPlayer
	var snack_visual: SnackVisualPresenter = (
		$Snack/Visual as SnackVisualPresenter
	)
	var snack_mesh: SphereMesh = snack_visual.mesh as SphereMesh
	fridge.openness = 0.6
	fridge.call("_apply_visual")
	snack.reveal_at(fridge.global_position)
	snack_visual.apply_reveal_clearance()
	assert(snack_visual.visible)
	assert(snack_mesh.radius >= 0.3 and snack_visual.position.y > snack_mesh.radius)
	_assert_snack_clear_of_panel(snack_visual, $Fridge/DoorVisual/Panel)
	assert(snack.pick_up(player))
	assert(($AudioDirector/SnackPickup as AudioStreamPlayer).playing)

	var drop_position: Vector3 = Vector3(0.0, 0.0, 0.0)
	snack.drop_at(drop_position)
	assert(snack_visual.visible)
	assert(($AudioDirector/SnackDrop as AudioStreamPlayer3D).playing)
	var pantry: DinnerDoor = $Pantry as DinnerDoor
	pantry.openness = 0.6
	pantry.call("_apply_visual")
	snack.reveal_at(pantry.global_position)
	snack_visual.apply_reveal_clearance()
	_assert_snack_clear_of_panel(snack_visual, $Pantry/DoorVisual/Panel)

	audio_director.end_audio_verification()
	phase_director.apply_fridge_open_rate(0.0)
	for settle_frame: int in range(8):
		await get_tree().process_frame
	print(
		"A7 verification passed: display stretch, visible fridge spill, TV flicker, "
		+ "rate-driven creak, snack audio, and clear revealed snack mesh."
	)
	get_tree().quit()


func _verify_a8_tuning() -> void:
	_verify_ambient_masks()

	var audio_director: DinnerAudioDirector = $AudioDirector as DinnerAudioDirector
	audio_director.call("_on_game_started")
	assert(audio_director.snack_pickup_volume_db >= -2.0)
	assert(is_equal_approx(audio_director.tv_bed_max_distance, 3.2))
	assert(is_equal_approx(audio_director.speaker_bed_max_distance, 2.4))

	var snack: DinnerSnack = $Snack as DinnerSnack
	var snack_visual: SnackVisualPresenter = $Snack/Visual as SnackVisualPresenter
	var snack_mesh: SphereMesh = snack_visual.mesh as SphereMesh
	var snack_material: StandardMaterial3D = (
		snack_visual.material_override as StandardMaterial3D
	)
	assert(snack_mesh.radius >= 0.349)
	assert(snack_material.emission_enabled)
	assert(snack_material.emission_energy_multiplier > 0.0)

	var pantry: DinnerDoor = $Pantry as DinnerDoor
	pantry.openness = 0.6
	pantry.call("_apply_visual")
	snack.reveal_at(pantry.global_position)
	snack_visual.apply_reveal_clearance()
	snack_visual.set("_pulse_elapsed", 0.0)
	snack_visual.call("_apply_pulse")
	var pulse_low: float = snack_visual.scale.x
	snack_visual.set("_pulse_elapsed", 0.25 / snack_visual.pulse_speed)
	snack_visual.call("_apply_pulse")
	var pulse_high: float = snack_visual.scale.x
	assert(pulse_high > pulse_low, "Revealed snack does not pulse.")
	_assert_snack_clear_of_panel(snack_visual, $Pantry/DoorVisual/Panel)
	assert(
		snack_visual.pantry_reveal_offset.x >= 1.0
		and snack_visual.pantry_reveal_offset.z > 0.0,
		"Pantry snack is not on the camera-visible side of the wide panel."
	)

	var player: DinnerPlayer = $Player as DinnerPlayer
	var presentation: Node3D = $Player/PresentationPivot as Node3D
	assert(snack.pick_up(player))
	snack_visual.call("_process", 0.0)
	assert(snack_visual.visible)
	assert(
		snack_visual.global_position.distance_to(
			player.to_global(snack_visual.carried_offset)
		) < 0.01,
		"Carried snack visual did not follow the player."
	)
	assert(($AudioDirector/SnackPickup as AudioStreamPlayer).playing)
	var pickup_pop: Tween = snack_visual.get("_pickup_pop_tween") as Tween
	assert(pickup_pop != null and pickup_pop.is_valid())
	pickup_pop.custom_step(0.11)
	assert(presentation.scale.x > 1.0, "Player pickup scale-pop did not rise.")
	pickup_pop.custom_step(0.22)
	assert(
		presentation.scale.is_equal_approx(Vector3.ONE),
		"Player pickup scale-pop did not settle in 0.3 seconds."
	)
	if pickup_pop.is_valid():
		pickup_pop.kill()

	audio_director.end_audio_verification()
	for settle_frame: int in range(8):
		await get_tree().process_frame
	print(
		"A8 verification passed: tight nonzero masks, smaller TV rings, emissive "
		+ "pulsing carried snack, louder pickup, pantry clearance, and pickup pop."
	)
	get_tree().quit()


func _verify_a9_practical_lighting() -> void:
	var environment: Environment = ($WorldEnvironment as WorldEnvironment).environment
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))

	var level: Node3D = $Level as Node3D
	var configured_range: float = float(level.get("lamp_range"))
	assert(configured_range >= 5.5 and configured_range <= 6.0)
	var fixture_names: PackedStringArray = [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
	]
	for fixture_name: String in fixture_names:
		var fixture: Node3D = level.get_node(fixture_name) as Node3D
		var fixture_light: OmniLight3D = fixture.get_node("Light") as OmniLight3D
		assert(is_equal_approx(fixture_light.omni_range, configured_range))
		var fixture_parts: Array[Node] = fixture.find_children(
			"*",
			"MeshInstance3D",
			true,
			false
		)
		assert(fixture_parts.size() == 3)
		var shade: MeshInstance3D = fixture.get_node("Shade") as MeshInstance3D
		var shade_material: StandardMaterial3D = (
			shade.material_override as StandardMaterial3D
		)
		assert(shade_material.emission_enabled)
		assert(shade_material.emission.b >= shade_material.emission.r)
		assert(
			is_equal_approx(
				LightSystem.get_brightness_at(
					Vector3(fixture.global_position.x, 0.0, fixture.global_position.z)
				),
				1.0
			)
		)

	var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
	phase_director.apply_phase(0)
	var player: DinnerPlayer = $Player as DinnerPlayer
	var capsule_material: StandardMaterial3D = player.get(
		"_capsule_material"
	) as StandardMaterial3D
	player.global_position = Vector3(-10.2, 0.6, -5.6)
	player.call("_update_capsule_readout")
	var lit_brightness: float = LightSystem.get_brightness_at(
		player.global_position
	)
	assert(lit_brightness > 0.85)
	var lit_capsule_energy: float = capsule_material.emission_energy_multiplier
	var brightness_readout: CanvasLayer = $BrightnessReadout as CanvasLayer
	brightness_readout.call("_process", 0.11)
	assert(
		($BrightnessReadout/Label as Label).text
		== "Brightness: %.2f" % lit_brightness
	)

	player.global_position = Vector3(-5.75, 0.6, -3.9)
	player.call("_update_capsule_readout")
	var pocket_brightness: float = LightSystem.get_brightness_at(
		player.global_position
	)
	assert(pocket_brightness > 0.0 and pocket_brightness < 0.5)
	assert(capsule_material.emission_energy_multiplier < lit_capsule_energy)
	brightness_readout.call("_process", 0.11)
	assert(
		($BrightnessReadout/Label as Label).text
		== "Brightness: %.2f" % pocket_brightness
	)

	print(
		"A9 verification passed: five cool emissive practicals, 5.8 m pools, "
		+ "0.05 ambient contrast, and live capsule/HUD brightness tracking."
	)
	get_tree().quit()


func _verify_a10_presentation() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var environment: Environment = ($WorldEnvironment as WorldEnvironment).environment
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))

	var bathroom_door: DinnerDoor = $Level/BathroomDoor as DinnerDoor
	assert(bathroom_door != null)
	assert(bathroom_door.player_path == NodePath("../../Player"))
	assert(bathroom_door.snack_path == NodePath("../../Snack"))
	var bathroom_panel: MeshInstance3D = (
		$Level/BathroomDoor/DoorVisual/Panel as MeshInstance3D
	)
	var bathroom_blocker: CollisionShape3D = (
		$Level/BathroomDoor/Blocker/CollisionShape3D as CollisionShape3D
	)
	assert(bathroom_panel != null and bathroom_blocker != null)
	assert(
		($Level/BathroomDoor/DoorVisual as StaticBody3D).collision_layer == 0,
		"Bathroom visual panel still has physical collision."
	)
	assert(not bathroom_blocker.disabled)
	bathroom_door.openness = 0.4
	bathroom_door.call("_apply_visual")
	bathroom_door.call("_update_blocker_collision")
	await get_tree().physics_frame
	assert(bathroom_blocker.disabled)
	bathroom_door.close_immediately()
	await get_tree().physics_frame
	assert(not bathroom_blocker.disabled)

	var parent_has_bathroom_path: bool = false
	for property: Dictionary in $Parent.get_property_list():
		if property["name"] == &"bathroom_door_path":
			parent_has_bathroom_path = true
			break
	if parent_has_bathroom_path:
		assert(
			$Parent.get("bathroom_door_path")
			== NodePath("../Level/BathroomDoor")
		)

	var crib: StaticBody3D = $Level/CribBlock as StaticBody3D
	var crib_meshes: Array[Node] = crib.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	)
	assert(crib_meshes.size() == 8, "Crib needs four posts and four side rails.")
	var couch: StaticBody3D = $Level/Couch as StaticBody3D
	var couch_meshes: Array[Node] = couch.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	)
	assert(couch_meshes.size() == 4, "Couch needs seat, back, and two arms.")
	assert(($Pet/Body as MeshInstance3D).mesh is CapsuleMesh)
	assert($Pet/Snout != null)
	var bowl: Node3D = $Level/KitchenBowl as Node3D
	assert((bowl.get_node("Bowl") as MeshInstance3D).mesh is CylinderMesh)
	assert(
		bowl.find_children("*", "CollisionObject3D", true, false).is_empty(),
		"Kitchen bowl blocks the nav-reachable floor."
	)
	var navigation_map: RID = get_world_3d().navigation_map
	var bowl_nav_point: Vector3 = NavigationServer3D.map_get_closest_point(
		navigation_map,
		bowl.global_position
	)
	assert(
		Vector2(bowl_nav_point.x, bowl_nav_point.z).distance_to(
			Vector2(bowl.global_position.x, bowl.global_position.z)
		) < 0.2,
		"Kitchen bowl is not on reachable navigation."
	)

	var fridge: DinnerDoor = $Fridge as DinnerDoor
	var fridge_hinge: Node3D = $Fridge/DoorVisual as Node3D
	var fridge_panel: MeshInstance3D = (
		$Fridge/DoorVisual/Panel as MeshInstance3D
	)
	var fridge_body: MeshInstance3D = (
		$Level/FridgeBlock.get_child(0) as MeshInstance3D
	)
	var fridge_body_aabb: AABB = (
		fridge_body.global_transform * fridge_body.get_aabb()
	)
	fridge.openness = 0.0
	fridge.call("_apply_visual")
	var closed_panel_aabb: AABB = (
		fridge_panel.global_transform * fridge_panel.get_aabb()
	)
	assert(closed_panel_aabb.size.z > 2.1)
	assert(not closed_panel_aabb.intersects(fridge_body_aabb))
	var minimum_fridge_clearance: float = INF
	for openness_step: int in range(9):
		fridge.openness = float(openness_step) / 8.0
		fridge.call("_apply_visual")
		var swept_aabb: AABB = (
			fridge_panel.global_transform * fridge_panel.get_aabb()
		)
		assert(
			not swept_aabb.intersects(fridge_body_aabb),
			"Fridge visual swept through its body at %.3f openness."
			% fridge.openness
		)
		minimum_fridge_clearance = minf(
			minimum_fridge_clearance,
			fridge_body_aabb.position.x - swept_aabb.end.x
		)
	var open_panel_aabb: AABB = (
		fridge_panel.global_transform * fridge_panel.get_aabb()
	)
	var north_wall_aabb: AABB = _wall_world_aabb($Level/NorthWall as Node3D)
	assert(open_panel_aabb.size.x > 2.1 and open_panel_aabb.size.z < 0.2)
	assert(open_panel_aabb.intersects(north_wall_aabb))
	assert(
		not fridge_panel.find_children("*", "CollisionShape3D", true, false)
	)
	assert(is_equal_approx(fridge_hinge.rotation_degrees.y, -90.0))
	fridge.close_immediately()

	var tv_glow: AreaLight3D = $Level/TVGlow as AreaLight3D
	var couch_target: Vector3 = Vector3(1.55, 0.4, -4.4)
	var tv_to_couch: Vector3 = (
		couch_target - tv_glow.global_position
	).normalized()
	assert((-tv_glow.global_basis.z).normalized().dot(tv_to_couch) > 0.99)
	var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
	assert(phase_director.tv_flicker_amount >= 0.15)
	phase_director.apply_phase(0)
	var minimum_tv_energy: float = INF
	var maximum_tv_energy: float = 0.0
	for flicker_step: int in range(120):
		phase_director.set("_tv_flicker_time", float(flicker_step) / 120.0)
		phase_director.apply_tv_flicker()
		minimum_tv_energy = minf(minimum_tv_energy, tv_glow.light_energy)
		maximum_tv_energy = maxf(maximum_tv_energy, tv_glow.light_energy)
	assert(maximum_tv_energy - minimum_tv_energy > 0.3)
	phase_director.apply_phase(2)
	assert(not tv_glow.visible)
	phase_director.apply_phase(0)

	var audio_director: DinnerAudioDirector = $AudioDirector as DinnerAudioDirector
	var carpet_volume_gap: float = (
		audio_director.hardwood_step_volume_db
		- audio_director.carpet_step_volume_db
	)
	assert(carpet_volume_gap >= 14.0)

	var debug_tools: DinnerDebugTools = $DebugTools as DinnerDebugTools
	var screen_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	var trial_lamp: Node3D = debug_tools.spawn_trial_lamp_at_screen_point(
		screen_center
	)
	assert(trial_lamp != null)
	var initial_trial_radius: float = float(trial_lamp.get_meta(&"radius"))
	var adjusted_trial_radius: float = debug_tools.adjust_active_trial_radius(
		0.5
	)
	assert(is_equal_approx(adjusted_trial_radius, initial_trial_radius + 0.5))
	var trial_rows: PackedStringArray = debug_tools.get_trial_lamp_rows()
	assert(
		trial_rows.size() == 1
		and trial_rows[0].begins_with('_add_omni("TrialLamp')
		and trial_rows[0].contains("%.2f)" % adjusted_trial_radius)
	)
	assert(
		debug_tools.remove_nearest_trial_lamp_at_screen_point(screen_center)
	)
	await get_tree().process_frame
	assert(debug_tools.get_trial_lamp_rows().is_empty())

	print(
		(
			"A10 metrics: ambient=%.2f, crib=%d parts, couch=%d parts, "
			+ "fridge sweep clearance=%.3f m, TV energy=%.2f..%.2f, "
			+ "carpet gap=%.1f dB, trial radius=%.2f m."
		)
		% [
			environment.ambient_light_energy,
			crib_meshes.size(),
			couch_meshes.size(),
			minimum_fridge_clearance,
			minimum_tv_energy,
			maximum_tv_energy,
			carpet_volume_gap,
			adjusted_trial_radius,
		]
	)
	print(
		"A10 verification passed: quiet door, silhouettes, outward fridge, "
		+ "TV cue, dark house, lamp tool, and carpet whisper."
	)
	get_tree().quit()


func _assert_snack_clear_of_panel(
	snack_visual: MeshInstance3D,
	panel: MeshInstance3D
) -> void:
	var snack_world_aabb: AABB = (
		snack_visual.global_transform * snack_visual.get_aabb()
	)
	var panel_world_aabb: AABB = panel.global_transform * panel.get_aabb()
	assert(
		not snack_world_aabb.intersects(panel_world_aabb),
		"Revealed snack mesh overlaps door panel: snack=%s panel=%s"
		% [snack_world_aabb, panel_world_aabb]
	)
	assert(snack_world_aabb.position.y >= 0.0)


func _verify_primary_floor_coverage() -> void:
	var floor_names: PackedStringArray = [
		"KidCarpet",
		"BathFloor",
		"LivingFloor",
		"KitchenFloor",
		"MiddleFloor",
		"DiningSouthFloor",
		"LivingThreshold",
		"AdultBedroomFloor",
		"ApproachFloor",
		"CarpetFloor",
		"AlcoveFloor",
		"CarpetAlcoveThreshold",
		"AlcoveDiningThreshold",
		"EastHallFloor",
		"PantryFloor",
		"PantryThreshold",
	]
	var floor_aabbs: Array[AABB] = []
	for floor_name: String in floor_names:
		var floor_body: StaticBody3D = get_node("Level/%s" % floor_name) as StaticBody3D
		var floor_mesh: MeshInstance3D = floor_body.get_child(0) as MeshInstance3D
		floor_aabbs.append(
			(floor_mesh.global_transform * floor_mesh.get_aabb()).grow(0.001)
		)

	var sample_step: float = 0.2
	var sample_x: float = -14.9
	while sample_x <= 14.9:
		var sample_z: float = -6.3
		while sample_z <= 6.3:
			var covered: bool = false
			var sample_point: Vector3 = Vector3(sample_x, -0.1, sample_z)
			for floor_aabb: AABB in floor_aabbs:
				if floor_aabb.has_point(sample_point):
					covered = true
					break
			assert(
				covered,
				"Primary floor rectangles leave a hole near (%.2f, %.2f)." % [sample_x, sample_z]
			)
			sample_z += sample_step
		sample_x += sample_step


func _capture_path_from_args() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-layout="):
			return argument.trim_prefix("--capture-layout=")
	return ""


func _a6_capture_path_from_args() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-a6-title="):
			return argument.trim_prefix("--capture-a6-title=")
	return ""


func _capture_layout(capture_path: String) -> void:
	var capture_fridge_light: bool = OS.get_cmdline_user_args().has(
		"--capture-a7-fridge"
	)
	var capture_a10_fridge_open: bool = OS.get_cmdline_user_args().has(
		"--capture-a10-fridge-open"
	)
	var capture_a10_fridge_closed: bool = OS.get_cmdline_user_args().has(
		"--capture-a10-fridge-closed"
	)
	if capture_a10_fridge_open or capture_a10_fridge_closed:
		_configure_a10_fridge_capture(capture_a10_fridge_open)
	if OS.get_cmdline_user_args().has("--capture-a7-snack"):
		var pantry: DinnerDoor = $Pantry as DinnerDoor
		pantry.openness = 0.6
		pantry.call("_apply_visual")
		var snack: DinnerSnack = $Snack as DinnerSnack
		snack.reveal_at(pantry.global_position)
		($Snack/Visual as SnackVisualPresenter).apply_reveal_clearance()
	for frame: int in range(capture_warmup_frames):
		await get_tree().process_frame
	if capture_fridge_light:
		var fridge: DinnerDoor = $Fridge as DinnerDoor
		fridge.openness = 0.6
		fridge.call("_apply_visual")
		var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
		phase_director.set_physics_process(false)
		phase_director.apply_fridge_open_rate(1.0)
		await get_tree().process_frame
	var image: Image = get_viewport().get_texture().get_image()
	var result: Error = image.save_png(capture_path)
	if result != OK:
		push_error("Could not save layout capture to %s (error %d)." % [capture_path, result])
	else:
		print("A0 layout capture saved: %s" % capture_path)
	get_tree().quit()


func _configure_a10_fridge_capture(is_open: bool) -> void:
	var fridge: DinnerDoor = $Fridge as DinnerDoor
	fridge.provides_snack = false
	fridge.openness = 1.0 if is_open else 0.0
	fridge.call("_apply_visual")
	var camera_target: Vector3 = Vector3(12.3, 0.8, -5.1)
	var camera_rig: Node3D = $CameraRig as Node3D
	camera_rig.global_position = camera_target + Vector3(0.0, 16.0, 6.0)
	camera_rig.look_at(camera_target, Vector3.UP)
	($CameraRig/OrthoCamera as Camera3D).size = 9.0

	var state_layer: CanvasLayer = CanvasLayer.new()
	state_layer.name = "A10FridgeStateLayer"
	state_layer.layer = 30
	add_child(state_layer)
	var state_label: Label = Label.new()
	state_label.name = "State"
	state_label.text = (
		"FRIDGE OPEN — OUTWARD SWEEP / NORTH-WALL REST"
		if is_open
		else "FRIDGE CLOSED — WALL-SIDE HINGE"
	)
	state_label.position = Vector2(32.0, 82.0)
	state_label.add_theme_font_size_override("font_size", 30)
	state_label.add_theme_color_override("font_color", Color("#f2f5f9"))
	state_label.add_theme_color_override("font_outline_color", Color("#111820"))
	state_label.add_theme_constant_override("outline_size", 7)
	state_layer.add_child(state_label)

	var wall_label: Label3D = Label3D.new()
	wall_label.name = "A10NorthWallLabel"
	wall_label.text = "NORTH WALL"
	wall_label.position = Vector3(10.8, 0.5, -6.15)
	wall_label.font_size = 30
	wall_label.outline_size = 7
	wall_label.pixel_size = 0.003
	wall_label.modulate = Color("#c9d8eb")
	wall_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wall_label.no_depth_test = true
	add_child(wall_label)

	var hinge_label: Label3D = Label3D.new()
	hinge_label.name = "A10HingeLabel"
	hinge_label.text = "HINGE"
	hinge_label.font_size = 28
	hinge_label.outline_size = 7
	hinge_label.pixel_size = 0.003
	hinge_label.modulate = Color("#dce9ff")
	hinge_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hinge_label.no_depth_test = true
	add_child(hinge_label)
	hinge_label.global_position = (
		$Fridge/DoorVisual as Node3D
	).global_position + Vector3.UP * 1.65
