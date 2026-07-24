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
	if OS.get_cmdline_user_args().has("--verify-a11"):
		_verify_a11_dress_pack()
		return
	if OS.get_cmdline_user_args().has("--verify-a12"):
		_verify_a12_lighting_contrast()
		return
	if OS.get_cmdline_user_args().has("--verify-a16"):
		_verify_a16_world_pack()
		return
	if OS.get_cmdline_user_args().has("--verify-a17"):
		_verify_a17_acceptance_fixes()
		return
	if OS.get_cmdline_user_args().has("--verify-a18"):
		_verify_a18_polish_pack()
		return
	if OS.get_cmdline_user_args().has("--verify-a19"):
		_verify_a19_geometry_audit()
		return
	if OS.get_cmdline_user_args().has("--verify-a20"):
		_verify_a20_snack_identity()
		return
	if OS.get_cmdline_user_args().has("--verify-a21"):
		_verify_a21_light_and_switch_support()
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

	var zone_probe: Vector3 = Vector3(60.0, 0.0, 0.0)
	LightSystem.register_light(
		"a1_zone_toggle",
		"bedroom",
		zone_probe,
		10.0
	)
	assert(is_equal_approx(LightSystem.get_brightness_at(zone_probe), 1.0))
	LightSystem.set_zone_enabled("bedroom", false)
	assert(is_zero_approx(LightSystem.get_brightness_at(zone_probe)))
	LightSystem.set_zone_enabled("bedroom", true)
	assert(is_equal_approx(LightSystem.get_brightness_at(zone_probe), 1.0))
	LightSystem.unregister_light("a1_zone_toggle")
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
	assert(
		fridge_hinge.global_position.distance_to(
			Vector3(12.55, 0.0, -4.2)
		) < 0.01
	)
	assert(is_equal_approx(fridge_panel.position.x, 1.2))
	assert(is_zero_approx(fridge_panel.position.z))
	fridge.set("openness", 1.0)
	fridge.call("_apply_visual")
	assert(is_equal_approx(fridge_hinge.rotation_degrees.y, -90.0))
	var panel_aabb: AABB = fridge_panel.global_transform * fridge_panel.get_aabb()
	assert(
		panel_aabb.size.z > 2.3
		and panel_aabb.position.z >= fridge_hinge.global_position.z,
		"Open fridge panel does not point south from its south-west hinge."
	)

	var parent: Node3D = $Parent
	var rows: Array = parent.get("routine_rows") as Array
	assert(rows.size() >= 6)
	var timing_anchors: Array[Vector2] = [
		Vector2(0.0, 53.0),
		Vector2(60.0, 15.0),
		Vector2(82.0, 98.0),
	]
	for row_index: int in range(timing_anchors.size()):
		var row: Dictionary = rows[row_index]
		assert(
			is_equal_approx(
				float(row["time"]),
				timing_anchors[row_index].x
			)
		)
		assert(
			is_equal_approx(
				float(row["dwell"]),
				timing_anchors[row_index].y
			)
		)
	assert((rows[5]["position"] as Vector3).is_equal_approx(Vector3(-5.8, 0.7, -3.5)))

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
		and $AudioDirector/PlayerFootsteps is AudioStreamPlayer3D
		and $AudioDirector/TVBed is AudioStreamPlayer3D
	)
	print(
		"A18 audio verification passed: denoised family pools with CC0 fallbacks, "
		+ "soft idle giggles, context catch branches, no-repeat VO priority, "
		+ "sneak/run mix separation, one-shot pickup, 2.5 s wrapper audio, "
		+ "positional sources, and zero bus effects."
	)
	audio_director.end_audio_verification()
	for settle_frame: int in range(8):
		await get_tree().process_frame
	await _settle_verification_audio()
	get_tree().quit()


func _verify_a20_snack_identity() -> void:
	var snack: DinnerSnack = $Snack as DinnerSnack
	var snack_visual: SnackVisualPresenter = $Snack/Visual as SnackVisualPresenter
	var audio_director: DinnerAudioDirector = (
		$AudioDirector as DinnerAudioDirector
	)

	snack.set_snack_type(DinnerSnack.TYPE_CHIPS)
	assert(snack_visual.get_presented_type() == DinnerSnack.TYPE_CHIPS)
	var packet: BoxMesh = snack_visual.mesh as BoxMesh
	assert(packet != null)
	assert(packet.size.x >= 0.5 and packet.size.y >= 0.65)
	assert(snack_visual.get_node_or_null("FoilBand") is MeshInstance3D)
	for pantry_material: StandardMaterial3D in (
		snack_visual.get_pulse_materials()
	):
		assert(pantry_material.emission_enabled)

	snack.set_snack_type(DinnerSnack.TYPE_ICE_CREAM)
	assert(snack_visual.get_presented_type() == DinnerSnack.TYPE_ICE_CREAM)
	var scoop: SphereMesh = snack_visual.mesh as SphereMesh
	var cone_part: MeshInstance3D = (
		snack_visual.get_node_or_null("Cone") as MeshInstance3D
	)
	assert(scoop != null and scoop.radius >= 0.299)
	assert(cone_part != null and cone_part.mesh is CylinderMesh)
	for fridge_material: StandardMaterial3D in (
		snack_visual.get_pulse_materials()
	):
		assert(fridge_material.emission_enabled)

	snack_visual.set("_pulse_elapsed", 0.0)
	snack_visual.call("_apply_pulse")
	var pulse_low: float = snack_visual.scale.x
	snack_visual.set("_pulse_elapsed", 0.25 / snack_visual.pulse_speed)
	snack_visual.call("_apply_pulse")
	assert(snack_visual.scale.x > pulse_low)

	audio_director.verify_configuration()
	audio_director.verify_a20_snack_audio_skin()
	assert(is_equal_approx(($Player as DinnerPlayer).snack_noise_loudness, 0.3))
	assert(is_equal_approx(($Player as DinnerPlayer).snack_noise_interval, 0.6))
	print(
		"A20 verification passed: chips packet and ice-cream cone/scoop swap "
		+ "by Snack identity; pickup/carry skins differ with locked 0.3/0.6 "
		+ "gameplay noise."
	)
	audio_director.end_audio_verification()
	for settle_frame: int in range(8):
		await get_tree().process_frame
	await _settle_verification_audio()
	get_tree().quit()


func _verify_a21_light_and_switch_support() -> void:
	for settle_frame: int in range(12):
		await get_tree().physics_frame
	var level: Node3D = $Level as Node3D
	var required_height: float = maxf(
		float(level.get("wall_shadow_occluder_height")),
		float(level.get("omni_source_height")) + 0.7
	)
	var wall_names: PackedStringArray = [
		"NorthWall",
		"SouthWall",
		"WestWall",
		"EastWall",
		"KidSouthA",
		"KidSouthB",
		"KidBathDivider",
		"BathLivingDivider",
		"DogKitchenDivider",
		"AdultNorthA",
		"AdultNorthB",
		"AdultEast",
		"LVertical",
		"LHorizontal",
		"PantryWest",
	]
	for wall_name: String in wall_names:
		var wall: StaticBody3D = level.get_node(wall_name) as StaticBody3D
		var visible_wall: MeshInstance3D = wall.get_child(0) as MeshInstance3D
		var occluder: MeshInstance3D = (
			wall.get_node("ShadowOccluder") as MeshInstance3D
		)
		var wall_aabb: AABB = (
			visible_wall.global_transform * visible_wall.get_aabb()
		)
		var occluder_aabb: AABB = (
			occluder.global_transform * occluder.get_aabb()
		)
		assert(occluder.is_in_group("wall_shadow_occluder"))
		assert(
			occluder.cast_shadow
			== GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		)
		assert(
			is_equal_approx(occluder_aabb.position.y, 0.0)
			and occluder_aabb.end.y >= required_height - 0.001,
			"%s shadow blocker does not span floor-to-source." % wall_name
		)
		assert(
			is_equal_approx(occluder_aabb.position.x, wall_aabb.position.x)
			and is_equal_approx(occluder_aabb.end.x, wall_aabb.end.x)
			and is_equal_approx(occluder_aabb.position.z, wall_aabb.position.z)
			and is_equal_approx(occluder_aabb.end.z, wall_aabb.end.z),
			"%s shadow blocker does not cover its visible wall." % wall_name
		)

	var lintel_rows: Array[Dictionary] = [
		{"name": "KidDoorShadowLintel", "width": 2.3},
		{"name": "BathroomDoorShadowLintel", "width": 2.95},
		{"name": "AdultDoorShadowLintel", "width": 2.3},
		{"name": "PantryDoorShadowLintel", "width": 3.55},
	]
	for lintel_row: Dictionary in lintel_rows:
		var lintel: MeshInstance3D = level.get_node(
			lintel_row["name"]
		) as MeshInstance3D
		var lintel_aabb: AABB = lintel.global_transform * lintel.get_aabb()
		assert(lintel.is_in_group("doorway_shadow_lintel"))
		assert(
			lintel.cast_shadow
			== GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		)
		assert(
			is_equal_approx(
				lintel_aabb.position.y,
				float(level.get("doorway_shadow_opening_height"))
			)
			and lintel_aabb.end.y >= required_height - 0.001
		)
		assert(
			is_equal_approx(
				lintel_aabb.size.x,
				float(lintel_row["width"])
			)
		)

	var kid_wall_occluder: MeshInstance3D = (
		$Level/KidSouthB/ShadowOccluder as MeshInstance3D
	)
	assert(
		(kid_wall_occluder.global_transform * kid_wall_occluder.get_aabb()).end.y
		> ($Level/HallDoorLampVisual/Light as OmniLight3D).global_position.y
	)

	var switch_count: int = 0
	for switch_node: Node in get_tree().get_nodes_in_group("world_switch"):
		var wall_switch: DinnerWorldSwitch = switch_node as DinnerWorldSwitch
		var nearest: Dictionary = LightSystem.nearest_switch_to(
			wall_switch.global_position
		)
		assert(nearest["switch"] == wall_switch)
		assert(
			nearest["light_id"]
			== StringName(wall_switch.target_light_id)
		)
		assert(is_zero_approx(float(nearest["distance"])))
		switch_count += 1
	assert(switch_count == 5)

	var navigation_region: NavigationRegion3D = (
		$Level/NavigationRegion3D as NavigationRegion3D
	)
	var polygon_count: int = (
		navigation_region.navigation_mesh.get_polygon_count()
	)
	assert(polygon_count == 164)
	print(
		"A21 metrics: %d floor-to-%.1f m wall blockers, %d doorway lintels, "
		% [wall_names.size(), required_height, lintel_rows.size()]
		+ "%d nearest-switch mappings; nav=%d polygons."
		% [switch_count, polygon_count]
	)
	print(
		"A21 verification passed: solid inter-room walls block above-source "
		+ "light, doorway openings retain spill, and LightSystem resolves the "
		+ "nearest switch plus controlled light id."
	)
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
	bedroom_door.openness_rate = bedroom_door.creak_slow_rate
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
	bedroom_door.openness_rate = bedroom_door.creak_fast_rate
	bedroom_door.openness += 1.0 / 60.0
	audio_director.call("_update_door_creak", 1.0 / 60.0)
	assert(door_creak_player.playing)
	assert(door_creak_player.volume_db > slow_creak_volume)

	var snack: DinnerSnack = $Snack as DinnerSnack
	var player: DinnerPlayer = $Player as DinnerPlayer
	var snack_visual: SnackVisualPresenter = (
		$Snack/Visual as SnackVisualPresenter
	)
	fridge.openness = 0.6
	fridge.call("_apply_visual")
	snack.reveal_at(fridge.global_position, DinnerSnack.TYPE_ICE_CREAM)
	snack_visual.apply_reveal_clearance()
	var snack_mesh: SphereMesh = snack_visual.mesh as SphereMesh
	assert(snack_visual.visible)
	assert(snack_mesh.radius >= 0.3 and snack_visual.position.y > snack_mesh.radius)
	_assert_snack_clear_of_panel(snack_visual, $Fridge/DoorVisual/Panel)
	assert(snack.pick_up(player))
	assert(($AudioDirector/SnackPickup as AudioStreamPlayer3D).playing)

	var drop_position: Vector3 = Vector3(0.0, 0.0, 0.0)
	snack.drop_at(drop_position)
	assert(snack_visual.visible)
	assert(($AudioDirector/SnackDrop as AudioStreamPlayer3D).playing)
	var pantry: DinnerDoor = $Pantry as DinnerDoor
	pantry.openness = 0.6
	pantry.call("_apply_visual")
	snack.reveal_at(pantry.global_position, DinnerSnack.TYPE_CHIPS)
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
	await _settle_verification_audio()
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

	var pantry: DinnerDoor = $Pantry as DinnerDoor
	pantry.openness = 0.6
	pantry.call("_apply_visual")
	snack.reveal_at(pantry.global_position, DinnerSnack.TYPE_CHIPS)
	snack_visual.apply_reveal_clearance()
	var snack_mesh: BoxMesh = snack_visual.mesh as BoxMesh
	var snack_material: StandardMaterial3D = (
		snack_visual.material_override as StandardMaterial3D
	)
	assert(snack_mesh.size.x >= 0.5 and snack_mesh.size.y >= 0.65)
	assert(snack_material.emission_enabled)
	assert(snack_material.emission_energy_multiplier > 0.0)
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
	assert(($AudioDirector/SnackPickup as AudioStreamPlayer3D).playing)
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
	await _settle_verification_audio()
	get_tree().quit()


func _verify_a9_practical_lighting() -> void:
	var environment: Environment = ($WorldEnvironment as WorldEnvironment).environment
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))

	var level: Node3D = $Level as Node3D
	var configured_range: float = float(level.get("lamp_range"))
	assert(configured_range >= 7.0 and configured_range <= 9.0)
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
		var analytic_anchor: Vector3 = Vector3(
			fixture.global_position.x,
			0.0,
			fixture.global_position.z
		)
		if fixture_name == "MidLampVisual":
			analytic_anchor = Vector3(-0.5, 0.0, 0.5)
		assert(
			is_equal_approx(
				LightSystem.get_brightness_at(analytic_anchor),
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

	player.global_position = Vector3(-5.75, 0.6, -0.8)
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
		"A9 verification passed: five cool emissive practicals, 7.8 m visual pools, "
		+ "A16 0.05 ambient floor, and live capsule/HUD brightness tracking."
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
	assert(closed_panel_aabb.size.x > 2.3 and closed_panel_aabb.size.z < 0.2)
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
			swept_aabb.position.z - fridge_body_aabb.end.z
		)
	var open_panel_aabb: AABB = (
		fridge_panel.global_transform * fridge_panel.get_aabb()
	)
	assert(open_panel_aabb.size.z > 2.3 and open_panel_aabb.size.x < 0.2)
	assert(minimum_fridge_clearance >= 0.0)
	assert(open_panel_aabb.position.z >= fridge_hinge.global_position.z)
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


func _verify_a11_dress_pack() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	assert(
		int(
			ProjectSettings.get_setting(
				"rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality"
			)
		) == 4,
		"Positional soft-shadow filter quality is not High."
	)
	var shadowed_lights: Array[Node] = find_children(
		"*",
		"Light3D",
		true,
		false
	)
	var shadowed_count: int = 0
	var shadowed_omni_count: int = 0
	for light_node: Node in shadowed_lights:
		var light: Light3D = light_node as Light3D
		if not light.shadow_enabled:
			continue
		shadowed_count += 1
		assert(is_equal_approx(light.shadow_opacity, 0.8))
		if light is OmniLight3D:
			shadowed_omni_count += 1
			assert(is_equal_approx(light.shadow_blur, 2.0))
	assert(shadowed_count == 8)
	assert(shadowed_omni_count == 8)

	var level: Node3D = $Level as Node3D
	var fixture_names: PackedStringArray = [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
	]
	for fixture_name: String in fixture_names:
		var fixture: Node3D = level.get_node(fixture_name) as Node3D
		var shade: MeshInstance3D = fixture.get_node("Shade") as MeshInstance3D
		var source: OmniLight3D = fixture.get_node("Light") as OmniLight3D
		assert(is_equal_approx(source.global_position.y, 4.5))
		assert(shade.global_position.y < 2.0)
		assert(source.global_position.distance_to(shade.global_position) > 2.5)
		if fixture_name != "MidLampVisual":
			assert(
				Vector2(source.global_position.x, source.global_position.z)
				.distance_to(Vector2(fixture.position.x, fixture.position.z))
				> 0.4
			)

	var front_table: StaticBody3D = (
		$Level/FrontDoorSideTable as StaticBody3D
	)
	assert(front_table.position.z > 5.5 and front_table.position.x > 9.2)
	assert(
		front_table.find_children(
			"*",
			"CollisionShape3D",
			true,
			false
		).size() == 1
	)
	assert(
		front_table.find_children("*", "MeshInstance3D", true, false).size()
		== 5
	)
	var front_fixture: Node3D = $Level/AlcoveLampVisual as Node3D
	assert(
		Vector2(front_fixture.position.x, front_fixture.position.z)
		.distance_to(Vector2(front_table.position.x, front_table.position.z))
		< 0.01
	)

	var dog_body: MeshInstance3D = $Pet/Body as MeshInstance3D
	assert(dog_body.mesh is CapsuleMesh)
	assert(absf(absf(dog_body.rotation_degrees.x) - 90.0) < 0.01)
	assert(absf(dog_body.rotation_degrees.z) < 0.01)
	var dog_snout: MeshInstance3D = $Pet/Snout as MeshInstance3D
	assert(dog_snout.position.z < -0.35 and dog_snout.position.y < 0.0)
	for ear_name: String in ["EarLeft", "EarRight"]:
		var ear: MeshInstance3D = $Pet.get_node(ear_name) as MeshInstance3D
		assert(ear.mesh is BoxMesh)
		assert(ear.position.z < 0.0 and ear.position.y > 0.0)

	var table_expected_mesh_counts: Dictionary = {
		"DiningTable": 13,
		"KitchenTable": 11,
	}
	for table_name: String in table_expected_mesh_counts:
		var table: StaticBody3D = level.get_node(table_name) as StaticBody3D
		var table_collisions: Array[Node] = table.find_children(
			"*",
			"CollisionShape3D",
			true,
			false
		)
		assert(
			table_collisions.size() == 1,
			"%s needs one simplified collision box." % table_name
		)
		assert((table_collisions[0] as CollisionShape3D).shape is BoxShape3D)
		assert(
			table.find_children("*", "MeshInstance3D", true, false).size()
			== int(table_expected_mesh_counts[table_name])
		)

	var navigation_mesh: NavigationMesh = (
		$Level/NavigationRegion3D as NavigationRegion3D
	).navigation_mesh
	var navigation_polygon_count: int = navigation_mesh.get_polygon_count()
	assert(navigation_polygon_count >= 150)
	var navigation_map: RID = get_world_3d().navigation_map
	var route_path: PackedVector3Array = NavigationServer3D.map_get_path(
		navigation_map,
		Vector3(-12.4, 0.0, -4.0),
		Vector3(13.2, 0.0, 4.4),
		true
	)
	assert(route_path.size() > 2)

	var hardwood_luminance: float = (
		level.get("hardwood_color") as Color
	).get_luminance()
	for creak_name: String in [
		"CreakTeacher",
		"CreakKitchen",
		"CreakAdult",
	]:
		var creak: NoiseSurface = level.get_node(creak_name) as NoiseSurface
		var plank_meshes: Array[Node] = creak.find_children(
			"*",
			"MeshInstance3D",
			true,
			false
		)
		assert(plank_meshes.size() == 3)
		assert(
			creak.find_children(
				"*",
				"CollisionShape3D",
				true,
				false
			).size() == 1
		)
		var first_material: StandardMaterial3D = (
			(plank_meshes[0] as MeshInstance3D).material_override
			as StandardMaterial3D
		)
		var second_material: StandardMaterial3D = (
			(plank_meshes[1] as MeshInstance3D).material_override
			as StandardMaterial3D
		)
		assert(first_material.albedo_color != second_material.albedo_color)
		for material: StandardMaterial3D in [first_material, second_material]:
			var plank_luminance: float = material.albedo_color.get_luminance()
			assert(plank_luminance > hardwood_luminance)
			assert(plank_luminance - hardwood_luminance < 0.12)
			assert(not material.emission_enabled)
	for toy_name: String in ["ToyHallRug", "ToyDining", "ToyCarpet"]:
		assert(
			(level.get_node(toy_name) as NoiseSurface).find_children(
				"*",
				"MeshInstance3D",
				true,
				false
			).size() >= 1
		)

	var debug_tools: DinnerDebugTools = $DebugTools as DinnerDebugTools
	var screen_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	var trial_lamp: Node3D = debug_tools.spawn_trial_lamp_at_screen_point(
		screen_center
	)
	assert(trial_lamp != null)
	var trial_source: OmniLight3D = trial_lamp.get_node("Light") as OmniLight3D
	var trial_shade: MeshInstance3D = (
		trial_lamp.get_node("Shade") as MeshInstance3D
	)
	assert(is_equal_approx(trial_source.global_position.y, 4.5))
	assert(trial_shade.global_position.y < 2.0)
	assert(is_equal_approx(trial_source.shadow_blur, 2.0))
	assert(is_equal_approx(trial_source.shadow_opacity, 0.8))
	assert(
		debug_tools.remove_nearest_trial_lamp_at_screen_point(screen_center)
	)

	print(
		(
			"A11 metrics: %d nav polygons, %d shadowed lights "
			+ "(%d omnis), sources y=4.50, dining 4 chairs, "
			+ "kitchen 3 chairs, creaks 3 planks."
		)
		% [
			navigation_polygon_count,
			shadowed_count,
			shadowed_omni_count,
		]
	)
	print(
		"A11 verification passed: soft high lights, leading dog silhouette, "
		+ "table groups, front-door lamp, and subtle creaky planks."
	)
	get_tree().quit()


func _verify_a12_lighting_contrast() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var environment: Environment = ($WorldEnvironment as WorldEnvironment).environment
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))

	var level: Node3D = $Level as Node3D
	var configured_attenuation: float = float(
		level.get("omni_visual_attenuation")
	)
	var configured_energy: float = float(level.get("lamp_energy"))
	assert(is_equal_approx(configured_attenuation, 1.45))
	assert(configured_energy > 2.2)

	var fixture_names: PackedStringArray = [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
	]
	for fixture_name: String in fixture_names:
		var fixture_light: OmniLight3D = (
			level.get_node("%s/Light" % fixture_name) as OmniLight3D
		)
		assert(
			is_equal_approx(
				fixture_light.omni_attenuation,
				configured_attenuation
			)
		)
		assert(fixture_light.light_energy >= configured_energy * 0.85)

	var dining_table: StaticBody3D = $Level/DiningTable as StaticBody3D
	var dining_fixture: Node3D = $Level/MidLampVisual as Node3D
	var dining_source: OmniLight3D = (
		$Level/MidLampVisual/Light as OmniLight3D
	)
	var dining_center: Vector2 = Vector2(
		dining_table.global_position.x,
		dining_table.global_position.z
	)
	assert(
		Vector2(
			dining_fixture.global_position.x,
			dining_fixture.global_position.z
		).distance_to(dining_center) < 0.01
	)
	assert(
		Vector2(
			dining_source.global_position.x,
			dining_source.global_position.z
		).distance_to(dining_center) < 0.01
	)

	# The rendered source moved to the table, but the locked analytic source
	# remains at its pre-A12 floor anchor and keeps its linear falloff.
	var analytic_mid_anchor: Vector3 = Vector3(-0.5, 0.0, 0.5)
	var analytic_dining_probe: Vector3 = Vector3(0.95, 0.0, 0.9)
	var configured_range: float = float(level.get("analytic_light_range"))
	var expected_dining_brightness: float = 1.0 - (
		analytic_mid_anchor.distance_to(analytic_dining_probe)
		/ configured_range
	)
	assert(
		is_equal_approx(
			LightSystem.get_brightness_at(analytic_mid_anchor),
			1.0
		)
	)
	assert(
		is_equal_approx(
			LightSystem.get_brightness_at(analytic_dining_probe),
			expected_dining_brightness
		)
	)

	var player: DinnerPlayer = $Player as DinnerPlayer
	var capsule_material: StandardMaterial3D = player.get(
		"_capsule_material"
	) as StandardMaterial3D
	player.global_position = Vector3(-10.2, 0.6, -5.6)
	player.call("_update_capsule_readout")
	var capsule_brightness: float = LightSystem.get_brightness_at(
		player.global_position
	)
	var expected_capsule_energy: float = lerpf(
		float(player.get("shadow_emission_energy")),
		float(player.get("lit_emission_energy")),
		capsule_brightness
	)
	assert(
		is_equal_approx(
			capsule_material.emission_energy_multiplier,
			expected_capsule_energy
		)
	)
	var brightness_readout: CanvasLayer = $BrightnessReadout as CanvasLayer
	brightness_readout.call("_process", 0.11)
	assert(
		($BrightnessReadout/Label as Label).text
		== "Brightness: %.2f" % capsule_brightness
	)

	var parent_threshold: float = float($Parent.get("brightness_threshold"))
	assert(is_equal_approx(parent_threshold, 0.35))
	for zone: String in LightSystem.VALID_ZONES:
		LightSystem.set_zone_enabled(zone, false)
	var threshold_anchor: Vector3 = Vector3(40.0, 0.0, 0.0)
	LightSystem.register_dynamic_light("a12_threshold_probe", threshold_anchor)
	LightSystem.set_dynamic_light("a12_threshold_probe", 10.0, 1.0)
	var exact_threshold_brightness: float = LightSystem.get_brightness_at(
		threshold_anchor + Vector3(6.5, 0.0, 0.0)
	)
	var just_visible_brightness: float = LightSystem.get_brightness_at(
		threshold_anchor + Vector3(6.49, 0.0, 0.0)
	)
	assert(is_equal_approx(exact_threshold_brightness, parent_threshold))
	assert(exact_threshold_brightness <= parent_threshold)
	assert(just_visible_brightness > parent_threshold)
	LightSystem.unregister_dynamic_light("a12_threshold_probe")
	for zone: String in LightSystem.VALID_ZONES:
		LightSystem.set_zone_enabled(zone, true)

	print(
		(
			"A12 metrics: ambient=%.2f, attenuation=%.1f, energy=%.1f, "
			+ "dining analytic=%.3f, capsule=%.3f, threshold=%.3f/%.3f."
		)
		% [
			environment.ambient_light_energy,
			configured_attenuation,
			configured_energy,
			expected_dining_brightness,
			capsule_brightness,
			exact_threshold_brightness,
			just_visible_brightness,
		]
	)
	print(
		"A12 verification passed: steeper visual pools and centered dining "
		+ "fixture preserve analytic brightness, capsule feedback, and the "
		+ "0.35 visibility boundary."
	)
	get_tree().quit()


func _verify_a16_world_pack() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var level: Node3D = $Level as Node3D
	assert(not level.has_node("LivingSouth"))
	var nav_region: NavigationRegion3D = (
		$Level/NavigationRegion3D as NavigationRegion3D
	)
	var polygon_count: int = nav_region.navigation_mesh.get_polygon_count()
	assert(polygon_count > 0)

	var switches: Array[Node] = get_tree().get_nodes_in_group("world_switch")
	assert(switches.size() == 5)
	var expected_switch_ids: Array[StringName] = [
		&"dining",
		&"kitchen",
		&"foyer",
		&"bathroom",
		&"kid_hall",
	]
	for switch_id: StringName in expected_switch_ids:
		var found: bool = false
		for node: Node in switches:
			if node.get("switch_id") == switch_id:
				found = true
				assert(is_equal_approx(float(node.get("click_loudness")), 0.8))
				assert(node.get_node("Click") is AudioStreamPlayer3D)
		assert(found, "Missing A16 switch %s." % switch_id)
	var kid_hall_switch: DinnerWorldSwitch = (
		$Level/KidHallSwitch as DinnerWorldSwitch
	)
	assert(not kid_hall_switch.is_on)
	assert(not ($Level/HallDoorLampVisual as Node3D).visible)
	kid_hall_switch.set_state(true, false)
	assert(($Level/HallDoorLampVisual as Node3D).visible)
	assert(LightSystem.is_light_enabled("HallDoorLampVisual"))
	kid_hall_switch.set_state(false, false)

	assert(not has_node("Sun"))
	var environment: Environment = (
		$WorldEnvironment as WorldEnvironment
	).environment
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))
	for fixture_name: String in [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
		"BathroomLampVisual",
		"HallDoorLampVisual",
	]:
		var light: OmniLight3D = (
			level.get_node("%s/Light" % fixture_name) as OmniLight3D
		)
		assert(is_equal_approx(light.omni_attenuation, 1.45))

	# Renderer falloff changed; locked analytic linear falloff did not.
	LightSystem.register_light(
		"a16_analytic_guard",
		"bedroom",
		Vector3(50.0, 0.0, 0.0),
		10.0
	)
	assert(
		is_equal_approx(
			LightSystem.get_brightness_at(Vector3(56.5, 0.0, 0.0)),
			0.35
		)
	)
	LightSystem.unregister_light("a16_analytic_guard")

	var fridge: DinnerDoor = $Fridge as DinnerDoor
	var hinge: Node3D = $Fridge/DoorVisual as Node3D
	var panel: MeshInstance3D = $Fridge/DoorVisual/Panel as MeshInstance3D
	assert(
		hinge.global_position.distance_to(Vector3(12.55, 0.0, -4.2))
		< 0.01
	)
	for openness_sample: float in [0.0, 0.25, 0.5, 0.75, 1.0]:
		fridge.openness = openness_sample
		fridge.call("_apply_visual")
		assert(panel.global_position.x >= hinge.global_position.x - 0.01)
		assert(panel.global_position.z >= hinge.global_position.z - 0.01)
	assert(absf(panel.global_position.x - hinge.global_position.x) < 0.02)
	assert(panel.global_position.z > hinge.global_position.z + 1.1)
	fridge.openness = 0.0
	fridge.call("_apply_visual")

	var audio_director: DinnerAudioDirector = (
		$AudioDirector as DinnerAudioDirector
	)
	for child: Node in audio_director.get_children():
		if child.name in [&"WinSting", &"CaughtSting", &"Voice"]:
			continue
		assert(
			child is AudioStreamPlayer3D,
			"Gameplay SFX must be positional: %s." % child.name
		)
	for door: Node in get_tree().get_nodes_in_group("interactable"):
		if door is DinnerDoor:
			var door_hinge: Vector3 = audio_director.call(
				"_get_door_hinge_position",
				door
			)
			var door_visual: Node3D = door.get_node(
				(door as DinnerDoor).door_visual_path
			) as Node3D
			assert(door_hinge.distance_to(door_visual.global_position) < 0.001)

	assert($GameFlow/InteractHUD is DinnerInteractHUD)
	var tv_notes: TVNoteEmitter = $Level/TVNotes as TVNoteEmitter
	($PhaseDirector as PhaseDirector).apply_phase(1)
	assert(tv_notes.visible)
	tv_notes.call("_spawn_note")
	assert(tv_notes.get_child_count() == 1)
	($PhaseDirector as PhaseDirector).apply_phase(2)
	assert(not tv_notes.visible)

	for toy_name: String in ["ToyHallRug", "ToyDining", "ToyCarpet"]:
		var toy: NoiseSurface = level.get_node(toy_name) as NoiseSurface
		assert(toy.surface_height <= 0.03)
		assert(
			toy.find_children("*", "CollisionShape3D", true, false).size()
			== 1
		)
		assert(
			toy.find_children("*", "MeshInstance3D", true, false).size()
			>= 1
		)
	var dog_bed: StaticBody3D = $Level/DogBed as StaticBody3D
	assert(
		dog_bed.find_children("*", "CollisionShape3D", true, false).size()
		== 1
	)
	assert(($Level/DogBed/RoundBed as MeshInstance3D).mesh is CylinderMesh)
	assert(($Level/KitchenBowl as Node3D).position.z > dog_bed.position.z)

	print(
		"A16 verification passed: nav=%d polygons, switches=%d, "
		% [polygon_count, switches.size()]
		+ "shadowed practicals, south-sweep fridge, positional SFX, "
		+ "interaction HUD, TV notes, and dressed hazard/pet props."
	)
	get_tree().quit()


func _verify_a17_acceptance_fixes() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var level: Node3D = $Level as Node3D
	var environment: Environment = (
		$WorldEnvironment as WorldEnvironment
	).environment
	assert(not has_node("Sun"))
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))
	assert(is_equal_approx(float(level.get("omni_visual_attenuation")), 1.45))
	assert(is_equal_approx(float(level.get("lamp_energy")), 6.5))
	assert(is_equal_approx(float(level.get("area_light_energy")), 2.2))
	for fixture_name: String in [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
	]:
		var light: OmniLight3D = (
			level.get_node("%s/Light" % fixture_name) as OmniLight3D
		)
		assert(is_equal_approx(light.omni_attenuation, 1.45))
		assert(light.light_energy >= 4.4)

	for pool_id: StringName in [
		&"footstep_carpet_walk",
		&"footstep_carpet_sprint",
		&"footstep_wood",
	]:
		var pool: Dictionary = DinnerAudioCasting.POOLS[pool_id] as Dictionary
		var streams: Array = pool["streams"] as Array
		assert(streams.size() >= 8)
		for stream: AudioStream in streams:
			assert(
				stream.resource_path.begins_with(
					"res://audio/cc0/footsteps/"
				)
			)
	var parent_pool: Dictionary = (
		DinnerAudioCasting.POOLS[&"parent_footstep"] as Dictionary
	)
	assert(
		(parent_pool["streams"] as Array)[0].resource_path.begins_with(
			"res://audio/denoised/foley/"
		)
	)

	var audio_director: DinnerAudioDirector = (
		$AudioDirector as DinnerAudioDirector
	)
	for candidate: Node in get_tree().get_nodes_in_group("interactable"):
		if candidate is DinnerDoor:
			var door: DinnerDoor = candidate as DinnerDoor
			assert(
				audio_director.call("_get_door_hinge_position", door)
				.distance_to(door.get_hinge_global_position()) < 0.001
			)

	var player: DinnerPlayer = $Player as DinnerPlayer
	var bedroom_door: DinnerDoor = $BedroomDoor as DinnerDoor
	var kid_switch: DinnerWorldSwitch = (
		$Level/KidHallSwitch as DinnerWorldSwitch
	)
	assert(
		bedroom_door.global_position.distance_to(kid_switch.global_position)
		> 2.5
	)
	var saved_player_position: Vector3 = player.global_position
	var saved_input_locked: bool = player.input_locked
	var saved_switch_state: bool = kid_switch.is_on
	var saved_openness: float = bedroom_door.openness
	player.input_locked = false
	player.global_position = (
		bedroom_door.global_position + kid_switch.global_position
	) * 0.5
	assert(
		player.get_nearest_interactable() == bedroom_door,
		"Door must outrank a switch at equal interaction distance."
	)
	var press: InputEventAction = InputEventAction.new()
	press.action = &"interact"
	press.pressed = true
	kid_switch.call("_unhandled_input", press)
	assert(
		kid_switch.is_on == saved_switch_state,
		"A door-targeted press also toggled the nearby switch."
	)

	var hud: DinnerInteractHUD = $GameFlow/InteractHUD as DinnerInteractHUD
	player.global_position = kid_switch.global_position + Vector3(0.0, -0.4, 0.0)
	hud.call("_process", 0.0)
	assert(hud.visible)
	assert(hud.get_current_interactable() == kid_switch)
	var camera: Camera3D = get_viewport().get_camera_3d()
	var expected_switch_center: Vector2 = camera.unproject_position(
		kid_switch.global_position + Vector3.UP * hud.world_anchor_height
	) + hud.prompt_offset
	assert(hud.get_prompt_center().distance_to(expected_switch_center) < 0.1)

	player.global_position = bedroom_door.global_position + Vector3.UP * 0.6
	bedroom_door.openness = 0.4
	Input.action_press("interact")
	hud.call("_process", 0.0)
	assert(hud.get_current_interactable() == bedroom_door)
	assert(is_equal_approx(hud.get_seconds_remaining(), 3.0))
	Input.action_release("interact")
	bedroom_door.openness = saved_openness
	bedroom_door.call("_apply_visual")
	kid_switch.set_state(saved_switch_state, false)
	player.global_position = saved_player_position
	player.input_locked = saved_input_locked

	for switch: Node in get_tree().get_nodes_in_group("world_switch"):
		assert(is_equal_approx(float(switch.get("click_loudness")), 0.8))

	var bathroom_fixture: Node3D = $Level/BathroomLampVisual as Node3D
	var bathroom_switch: DinnerWorldSwitch = (
		$Level/BathroomSwitch as DinnerWorldSwitch
	)
	assert(not bathroom_fixture.visible)
	assert(not bathroom_switch.is_on)
	var bathroom_shade: MeshInstance3D = (
		$Level/BathroomLampVisual/Shade as MeshInstance3D
	)
	assert(bathroom_shade.mesh is CylinderMesh)
	assert(bathroom_shade.position.y <= 1.2)
	assert(
		bathroom_fixture.find_children(
			"*",
			"MeshInstance3D",
			true,
			false
		).size() == 1
	)

	var toilet: StaticBody3D = $Level/BathroomToilet as StaticBody3D
	assert(($Level/BathroomToilet/Tank as MeshInstance3D).mesh is BoxMesh)
	assert(($Level/BathroomToilet/Bowl as MeshInstance3D).mesh is CylinderMesh)
	assert(
		toilet.find_children(
			"*",
			"CollisionShape3D",
			true,
			false
		).size() == 1
	)
	var nav_region: NavigationRegion3D = (
		$Level/NavigationRegion3D as NavigationRegion3D
	)
	var polygon_count: int = nav_region.navigation_mesh.get_polygon_count()
	assert(polygon_count > 0)

	print(
		(
			"A17 metrics: lamp energy=%.1f, attenuation=%.1f, "
			+ "ambient=%.2f, footsteps=%d carpet/%d wood, nav=%d polygons."
		)
		% [
			float(level.get("lamp_energy")),
			float(level.get("omni_visual_attenuation")),
			environment.ambient_light_energy,
			(
				DinnerAudioCasting.POOLS[
					&"footstep_carpet_walk"
				]["streams"] as Array
			).size(),
			(
				DinnerAudioCasting.POOLS[
					&"footstep_wood"
				]["streams"] as Array
			).size(),
			polygon_count,
		]
	)
	print(
		"A17 verification passed: brighter practical pools, CC0 player steps, "
		+ "hinge audio, exclusive anchored interaction, quiet switches, and "
		+ "the dark-start bathroom/toilet pass."
	)
	await _settle_verification_audio()
	get_tree().quit()


func _verify_a18_polish_pack() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	var level: Node3D = $Level as Node3D
	var environment: Environment = (
		$WorldEnvironment as WorldEnvironment
	).environment
	assert(not has_node("Sun"))
	assert(is_equal_approx(environment.ambient_light_energy, 0.05))
	assert(is_equal_approx(float(level.get("lamp_energy")), 6.5))
	assert(is_equal_approx(float(level.get("lamp_range")), 7.8))
	assert(is_equal_approx(float(level.get("analytic_light_range")), 5.8))
	assert(
		is_equal_approx(
			float(level.get("omni_visual_attenuation")),
			1.45
		)
	)

	var shadowed_omni_count: int = 0
	for candidate: Node in get_tree().root.find_children(
		"*",
		"OmniLight3D",
		true,
		false
	):
		var omni: OmniLight3D = candidate as OmniLight3D
		assert(omni.shadow_enabled, "%s must cast practical shadows." % omni.name)
		assert(is_equal_approx(omni.shadow_blur, 2.0))
		assert(is_equal_approx(omni.shadow_opacity, 0.8))
		shadowed_omni_count += 1
	assert(shadowed_omni_count >= 8)

	var wall_names: PackedStringArray = [
		"NorthWall",
		"SouthWall",
		"WestWall",
		"EastWall",
		"KidSouthA",
		"KidSouthB",
		"KidBathDivider",
		"BathLivingDivider",
		"DogKitchenDivider",
		"AdultNorthA",
		"AdultNorthB",
		"AdultEast",
		"LVertical",
		"LHorizontal",
		"PantryWest",
	]
	for wall_name: String in wall_names:
		var wall: StaticBody3D = level.get_node(wall_name) as StaticBody3D
		var occluder: MeshInstance3D = (
			wall.get_node("ShadowOccluder") as MeshInstance3D
		)
		assert(
			occluder.cast_shadow
			== GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		)
		var occluder_mesh: BoxMesh = occluder.mesh as BoxMesh
		assert(
			is_equal_approx(
				occluder_mesh.size.y,
				float(level.get("wall_shadow_occluder_height"))
			)
		)

	# Lighting v3 is renderer-only. The gameplay light remains the locked
	# five-point-eight-metre linear source used by the capsule/AI thresholds.
	var analytic_mid_anchor: Vector3 = Vector3(-0.5, 0.0, 0.5)
	var analytic_probe: Vector3 = Vector3(0.95, 0.0, 0.9)
	var expected_probe: float = 1.0 - (
		analytic_mid_anchor.distance_to(analytic_probe) / 5.8
	)
	assert(
		is_equal_approx(
			LightSystem.get_brightness_at(analytic_mid_anchor),
			1.0
		)
	)
	assert(
		is_equal_approx(
			LightSystem.get_brightness_at(analytic_probe),
			expected_probe
		)
	)

	var denoised_stream_count: int = 0
	for pool_id: StringName in DinnerAudioCasting.POOLS:
		var pool: Dictionary = DinnerAudioCasting.POOLS[pool_id] as Dictionary
		for stream: AudioStream in pool.get("streams", []):
			assert(
				not stream.resource_path.begins_with("res://audio/original/"),
				"Runtime family pool still references an original: %s."
				% stream.resource_path
			)
			if stream.resource_path.begins_with("res://audio/denoised/"):
				denoised_stream_count += 1
	assert(denoised_stream_count >= 60)
	assert(
		(
			DinnerAudioCasting.POOLS[&"idle_giggle"][
				"streams"
			] as Array
		).size() >= 3
	)
	assert(
		is_equal_approx(
			float(
				DinnerAudioCasting.POOLS[&"idle_giggle"].get(
					"volume_offset_db",
					0.0
				)
			),
			-8.0
		)
	)

	var audio_director: DinnerAudioDirector = (
		$AudioDirector as DinnerAudioDirector
	)
	assert(is_equal_approx(audio_director.carpet_step_volume_db, -42.0))
	assert(is_equal_approx(audio_director.hardwood_step_volume_db, -28.0))
	assert(is_equal_approx(audio_director.run_carpet_step_volume_db, -20.0))
	assert(is_equal_approx(audio_director.run_hardwood_step_volume_db, -7.0))
	assert(is_equal_approx(audio_director.creak_step_volume_db, -3.0))
	assert(is_equal_approx(audio_director.wrapper_volume_db, -20.0))
	assert(is_equal_approx(audio_director.wrapper_audio_interval, 2.5))
	var player: DinnerPlayer = $Player as DinnerPlayer
	assert(is_equal_approx(player.snack_noise_interval, 0.6))
	assert(
		player.idle_giggled.is_connected(
			Callable(audio_director, "_on_player_idle_giggled")
		)
	)

	print(
		(
			"A18 metrics: %d shadowed omnis, %d wall occluders, "
			+ "%d denoised pool entries, visual range %.1f m, "
			+ "attenuation %.2f, sneak carpet %.0f dB."
		)
		% [
			shadowed_omni_count,
			wall_names.size(),
			denoised_stream_count,
			float(level.get("lamp_range")),
			float(level.get("omni_visual_attenuation")),
			audio_director.carpet_step_volume_db,
		]
	)
	print(
		"A18 verification passed: room-scale wall-blocked practicals, locked "
		+ "analytic light, denoised family pools, near-silent sneak mix, "
		+ "one-shot pickup/cadenced wrapper audio, and soft idle giggles."
	)
	await _settle_verification_audio()
	get_tree().quit()


func _verify_a19_geometry_audit() -> void:
	get_tree().paused = false
	for settle_frame: int in range(12):
		await get_tree().physics_frame

	_verify_wall_junctions()
	_verify_primary_floor_coverage()
	var level: Node3D = $Level as Node3D

	var floor_names: PackedStringArray = [
		"FailsafeSlab",
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
		"HallRug",
	]
	var wall_names: PackedStringArray = [
		"NorthWall",
		"SouthWall",
		"WestWall",
		"EastWall",
		"KidSouthA",
		"KidSouthB",
		"KidBathDivider",
		"BathLivingDivider",
		"DogKitchenDivider",
		"AdultNorthA",
		"AdultNorthB",
		"AdultEast",
		"LVertical",
		"LHorizontal",
		"PantryWest",
	]
	var simple_prop_names: PackedStringArray = [
		"Nightstand",
		"TVConsole",
		"KitchenCounter",
		"AdultBed",
		"HallShelf",
		"AdultDoorPanel",
		"KitchenSpeaker",
	]
	var composite_prop_names: PackedStringArray = [
		"CribBlock",
		"Couch",
		"DogBed",
		"FridgeBlock",
		"DiningTable",
		"KitchenTable",
		"FrontDoorSideTable",
		"BathroomToilet",
	]
	var matched_body_count: int = 0
	for body_name: String in (
		floor_names
		+ wall_names
		+ simple_prop_names
		+ composite_prop_names
	):
		var body: StaticBody3D = level.get_node(body_name) as StaticBody3D
		_assert_body_collision_matches_visual(body)
		matched_body_count += 1
	assert(matched_body_count == 48)

	for floor_name: String in floor_names:
		var floor_body: StaticBody3D = level.get_node(floor_name) as StaticBody3D
		var floor_bounds: AABB = _visible_mesh_world_aabb(floor_body)
		var expected_top: float = (
			-0.05
			if floor_name == "FailsafeSlab"
			else 0.02 if floor_name == "HallRug" else 0.0
		)
		assert(
			is_equal_approx(floor_bounds.end.y, expected_top),
			"%s top is %.3f, expected %.3f."
			% [floor_name, floor_bounds.end.y, expected_top]
		)

	var door_rows: Array[Dictionary] = [
		{
			"name": "BedroomDoor",
			"node": $BedroomDoor,
			"size": Vector3(2.3, 1.2, 0.25),
			"hinge": Vector3(-13.9, 0.0, -1.5),
		},
		{
			"name": "BathroomDoor",
			"node": $Level/BathroomDoor,
			"size": Vector3(2.95, 1.2, 0.25),
			"hinge": Vector3(-7.125, 0.0, -1.5),
		},
		{
			"name": "Pantry",
			"node": $Pantry,
			"size": Vector3(3.55, 1.2, 0.25),
			"hinge": Vector3(11.325, 0.0, 2.2),
		},
		{
			"name": "Fridge",
			"node": $Fridge,
			"size": Vector3(2.4, 2.2, 0.12),
			"hinge": Vector3(12.55, 0.0, -4.2),
		},
	]
	for door_row: Dictionary in door_rows:
		var door: DinnerDoor = door_row["node"] as DinnerDoor
		door.close_immediately()
		await get_tree().physics_frame
		var panel: MeshInstance3D = door.get_node(
			"DoorVisual/Panel"
		) as MeshInstance3D
		var panel_bounds: AABB = (
			panel.global_transform * panel.get_aabb()
		)
		var expected_size: Vector3 = door_row["size"] as Vector3
		assert(
			panel_bounds.size.distance_to(expected_size) < 0.01,
			"%s panel size %s does not fill %s."
			% [door_row["name"], panel_bounds.size, expected_size]
		)
		assert(is_equal_approx(panel_bounds.position.y, 0.0))
		var blocker: CollisionShape3D = door.get_node(
			"Blocker/CollisionShape3D"
		) as CollisionShape3D
		var blocker_shape: BoxShape3D = blocker.shape as BoxShape3D
		assert(
			blocker_shape.size.distance_to(expected_size) < 0.01,
			"%s blocker %s does not match its panel %s."
			% [door_row["name"], blocker_shape.size, expected_size]
		)
		assert(
			door.get_hinge_global_position().distance_to(
				door_row["hinge"] as Vector3
			) < 0.01
		)

	var adult_panel: StaticBody3D = $Level/AdultDoorPanel as StaticBody3D
	var adult_panel_bounds: AABB = _visible_mesh_world_aabb(adult_panel)
	assert(
		adult_panel_bounds.size.distance_to(Vector3(2.3, 1.2, 0.25))
		< 0.01
	)
	assert(is_equal_approx(adult_panel_bounds.position.y, 0.0))

	var front_door: Node3D = $Level/FrontDoor as Node3D
	var front_door_bounds: AABB = _visible_mesh_world_aabb(front_door)
	assert(
		front_door_bounds.size.distance_to(Vector3(2.4, 1.2, 0.15))
		< 0.01
	)
	assert(is_equal_approx(front_door_bounds.position.y, 0.0))
	assert(
		is_equal_approx(
			front_door_bounds.end.z,
			_wall_world_aabb($Level/SouthWall).position.z
		)
	)

	var switch_rows: Array[Dictionary] = [
		{
			"switch": "DiningSwitch",
			"wall": "LVertical",
			"normal": Vector3.RIGHT,
		},
		{
			"switch": "KitchenSwitch",
			"wall": "DogKitchenDivider",
			"normal": Vector3.RIGHT,
		},
		{
			"switch": "FoyerSwitch",
			"wall": "SouthWall",
			"normal": Vector3.FORWARD,
		},
		{
			"switch": "BathroomSwitch",
			"wall": "BathLivingDivider",
			"normal": Vector3.LEFT,
		},
		{
			"switch": "KidHallSwitch",
			"wall": "KidSouthB",
			"normal": Vector3.BACK,
		},
	]
	for switch_row: Dictionary in switch_rows:
		var wall_bounds: AABB = _wall_world_aabb(
			level.get_node(switch_row["wall"]) as Node3D
		)
		var wall_switch: Node3D = level.get_node(
			switch_row["switch"]
		) as Node3D
		var plate: MeshInstance3D = wall_switch.get_child(0) as MeshInstance3D
		var plate_bounds: AABB = plate.global_transform * plate.get_aabb()
		var normal: Vector3 = switch_row["normal"] as Vector3
		var contact_gap: float = 0.0
		if normal.x > 0.5:
			contact_gap = plate_bounds.position.x - wall_bounds.end.x
		elif normal.x < -0.5:
			contact_gap = wall_bounds.position.x - plate_bounds.end.x
		elif normal.z > 0.5:
			contact_gap = plate_bounds.position.z - wall_bounds.end.z
		else:
			contact_gap = wall_bounds.position.z - plate_bounds.end.z
		assert(
			absf(contact_gap) < 0.01,
			"%s floats %.3f m from %s."
			% [
				switch_row["switch"],
				contact_gap,
				switch_row["wall"],
			]
		)
		var toggle: MeshInstance3D = wall_switch.get_node(
			"Toggle"
		) as MeshInstance3D
		assert(toggle.position.normalized().dot(normal) > 0.99)

	var fixture_rows: Array[Dictionary] = [
		{"fixture": "KidLampVisual", "support": "Nightstand"},
		{"fixture": "KitchenLampVisual", "support": "KitchenCounter"},
		{
			"fixture": "MidLampVisual",
			"support": "DiningTable",
			"surface": "Top",
		},
		{"fixture": "AlcoveLampVisual", "support": "FrontDoorSideTable"},
	]
	for fixture_row: Dictionary in fixture_rows:
		var fixture: Node3D = level.get_node(
			fixture_row["fixture"]
		) as Node3D
		var base: MeshInstance3D = fixture.get_node("Base") as MeshInstance3D
		var base_bounds: AABB = base.global_transform * base.get_aabb()
		var support: Node3D = level.get_node(
			fixture_row["support"]
		) as Node3D
		var support_bounds: AABB
		if fixture_row.has("surface"):
			var surface: MeshInstance3D = support.get_node(
				fixture_row["surface"]
			) as MeshInstance3D
			support_bounds = surface.global_transform * surface.get_aabb()
		else:
			support_bounds = _visible_mesh_world_aabb(support)
		assert(
			absf(base_bounds.position.y - support_bounds.end.y) < 0.01,
			"%s does not sit on %s."
			% [fixture_row["fixture"], fixture_row["support"]]
		)
	for floor_fixture_name: String in [
		"LivingLampVisual",
		"HallDoorLampVisual",
	]:
		var floor_base: MeshInstance3D = level.get_node(
			"%s/Base" % floor_fixture_name
		) as MeshInstance3D
		var floor_base_bounds: AABB = (
			floor_base.global_transform * floor_base.get_aabb()
		)
		assert(is_equal_approx(floor_base_bounds.position.y, 0.0))
	var bathroom_disc: MeshInstance3D = (
		$Level/BathroomLampVisual/Shade as MeshInstance3D
	)
	var bathroom_disc_bounds: AABB = (
		bathroom_disc.global_transform * bathroom_disc.get_aabb()
	)
	assert(is_equal_approx(bathroom_disc_bounds.end.y, 1.2))

	var bowl: MeshInstance3D = $Level/KitchenBowl/Bowl as MeshInstance3D
	var bowl_bounds: AABB = bowl.global_transform * bowl.get_aabb()
	assert(is_equal_approx(bowl_bounds.position.y, 0.0))
	var doormat: Node3D = $Level/DoorMat as Node3D
	assert(is_equal_approx(_visible_mesh_world_aabb(doormat).position.y, 0.0))

	var hazard_support_tops: Dictionary = {
		"CreakTeacher": 0.02,
		"CreakKitchen": 0.0,
		"CreakAdult": 0.0,
		"ToyHallRug": 0.02,
		"ToyDining": 0.0,
		"ToyCarpet": 0.0,
	}
	for hazard_name: String in hazard_support_tops:
		var hazard: NoiseSurface = level.get_node(hazard_name) as NoiseSurface
		var hazard_collision: CollisionShape3D = hazard.find_children(
			"*",
			"CollisionShape3D",
			true,
			false
		)[0] as CollisionShape3D
		var hazard_bounds: AABB = _collision_world_aabb(hazard_collision)
		assert(
			is_equal_approx(
				hazard_bounds.position.y,
				float(hazard_support_tops[hazard_name])
			)
		)

	var navigation_region: NavigationRegion3D = (
		$Level/NavigationRegion3D as NavigationRegion3D
	)
	var polygon_count: int = (
		navigation_region.navigation_mesh.get_polygon_count()
	)
	assert(polygon_count > 0)
	print(
		(
			"A19 metrics: %d matched visual/collider bodies, %d floors, "
			+ "%d walls, %d fitted doors, %d flush switches, "
			+ "%d nav polygons."
		)
		% [
			matched_body_count,
			floor_names.size(),
			wall_names.size(),
			door_rows.size() + 1,
			switch_rows.size(),
			polygon_count,
		]
	)
	print(
		"A19 geometry verification passed: fitted doorway panels/blockers, "
		+ "sealed wall/floor seams, grounded props, matched colliders, "
		+ "flush switches, and supported practical fixtures."
	)
	get_tree().quit()


func _assert_body_collision_matches_visual(body: StaticBody3D) -> void:
	var collisions: Array[Node] = body.find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	)
	assert(
		collisions.size() == 1,
		"%s needs one fitted collision shape." % body.name
	)
	var visual_bounds: AABB = _visible_mesh_world_aabb(body)
	var collision_bounds: AABB = _collision_world_aabb(
		collisions[0] as CollisionShape3D
	)
	assert(
		visual_bounds.position.distance_to(collision_bounds.position) < 0.01,
		"%s collision starts at %s but visual starts at %s."
		% [body.name, collision_bounds.position, visual_bounds.position]
	)
	assert(
		visual_bounds.size.distance_to(collision_bounds.size) < 0.01,
		"%s collision is %s but visual bounds are %s."
		% [body.name, collision_bounds.size, visual_bounds.size]
	)


func _visible_mesh_world_aabb(root: Node3D) -> AABB:
	var meshes: Array[Node] = root.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	)
	var found: bool = false
	var combined: AABB
	for mesh_node: Node in meshes:
		if mesh_node.name == &"ShadowOccluder":
			continue
		var mesh: MeshInstance3D = mesh_node as MeshInstance3D
		if mesh.mesh == null:
			continue
		var bounds: AABB = mesh.global_transform * mesh.get_aabb()
		combined = combined.merge(bounds) if found else bounds
		found = true
	assert(found, "%s has no visible geometry." % root.name)
	return combined


func _collision_world_aabb(collision: CollisionShape3D) -> AABB:
	var local_bounds: AABB
	if collision.shape is BoxShape3D:
		var box: BoxShape3D = collision.shape as BoxShape3D
		local_bounds = AABB(-box.size * 0.5, box.size)
	elif collision.shape is CylinderShape3D:
		var cylinder: CylinderShape3D = collision.shape as CylinderShape3D
		var size: Vector3 = Vector3(
			cylinder.radius * 2.0,
			cylinder.height,
			cylinder.radius * 2.0
		)
		local_bounds = AABB(-size * 0.5, size)
	else:
		assert(false, "A19 does not support %s." % collision.shape)
	return collision.global_transform * local_bounds


func _assert_snack_clear_of_panel(
	snack_visual: SnackVisualPresenter,
	panel: MeshInstance3D
) -> void:
	var snack_world_aabb: AABB = snack_visual.get_visual_world_aabb()
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
	var capture_a16_fridge_open: bool = OS.get_cmdline_user_args().has(
		"--capture-a16-fridge-open"
	)
	var capture_a16_fridge_closed: bool = OS.get_cmdline_user_args().has(
		"--capture-a16-fridge-closed"
	)
	var capture_a18_wall_proof: bool = OS.get_cmdline_user_args().has(
		"--capture-a18-wall-proof"
	)
	var capture_a19_geometry: bool = OS.get_cmdline_user_args().has(
		"--capture-a19-geometry"
	)
	var capture_a21_before: bool = OS.get_cmdline_user_args().has(
		"--capture-a21-before"
	)
	var capture_a21_after: bool = OS.get_cmdline_user_args().has(
		"--capture-a21-after"
	)
	if (
		capture_a10_fridge_open
		or capture_a10_fridge_closed
		or capture_a16_fridge_open
		or capture_a16_fridge_closed
	):
		_configure_a16_fridge_capture(
			capture_a10_fridge_open or capture_a16_fridge_open
		)
	if OS.get_cmdline_user_args().has("--capture-a7-snack"):
		var pantry: DinnerDoor = $Pantry as DinnerDoor
		pantry.openness = 0.6
		pantry.call("_apply_visual")
		var snack: DinnerSnack = $Snack as DinnerSnack
		snack.reveal_at(pantry.global_position, DinnerSnack.TYPE_CHIPS)
		($Snack/Visual as SnackVisualPresenter).apply_reveal_clearance()
	if capture_a18_wall_proof:
		_configure_a18_wall_blocking_capture()
	if capture_a19_geometry:
		_configure_a19_geometry_capture()
	if capture_a21_before or capture_a21_after:
		_configure_a21_wall_blocking_capture(capture_a21_before)
	for frame: int in range(capture_warmup_frames):
		await get_tree().process_frame
	if capture_a19_geometry:
		_apply_a19_capture_state()
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


func _configure_a21_wall_blocking_capture(is_before: bool) -> void:
	var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
	phase_director.set_process(false)
	phase_director.set_physics_process(false)

	for fixture_name: String in [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
		"BathroomLampVisual",
	]:
		var fixture: Node3D = $Level.get_node(fixture_name) as Node3D
		fixture.visible = false
	for area_name: String in ["TVGlow", "WindowGlow", "DoorStripGlow"]:
		($Level.get_node(area_name) as Light3D).visible = false
	($Level/KidHallSwitch as DinnerWorldSwitch).set_state(true, false)

	var bedroom_door: DinnerDoor = $BedroomDoor as DinnerDoor
	bedroom_door.openness = 1.0
	bedroom_door.call("_apply_visual")

	var camera_target: Vector3 = Vector3(-10.8, 0.0, -1.5)
	var camera_rig: Node3D = $CameraRig as Node3D
	camera_rig.global_position = camera_target + Vector3(0.0, 18.0, 7.0)
	camera_rig.look_at(camera_target, Vector3.UP)
	($CameraRig/OrthoCamera as Camera3D).size = 10.5

	var proof_layer: CanvasLayer = CanvasLayer.new()
	proof_layer.name = "A21WallBlockingProof"
	proof_layer.layer = 30
	add_child(proof_layer)
	var proof_label: Label = Label.new()
	proof_label.text = (
		"A21 BEFORE — HALL LIGHT / KID WALL AUDIT\n"
		+ "UNBOUNDED DOOR GAP OVERSPILLS ABOVE THE HALF-HEIGHT WALL"
		if is_before
		else
		"A21 AFTER — HALL LIGHT / KID WALL AUDIT\n"
		+ "FULL-HEIGHT WALL BLOCK • ONLY THE DOOR OPENING SPILLS"
	)
	proof_label.position = Vector2(32.0, 76.0)
	proof_label.add_theme_font_size_override("font_size", 27)
	proof_label.add_theme_color_override("font_color", Color("#f2f5f9"))
	proof_label.add_theme_color_override("font_outline_color", Color("#111820"))
	proof_label.add_theme_constant_override("outline_size", 7)
	proof_layer.add_child(proof_label)

	for marker_row: Dictionary in [
		{
			"text": "KID ROOM — SOLID WALL",
			"position": Vector3(-9.4, 0.35, -3.0),
			"color": Color("#c8d2df"),
		},
		{
			"text": "OPEN DOORWAY",
			"position": Vector3(-12.75, 0.35, -2.5),
			"color": Color("#d889de"),
		},
	]:
		var marker: Label3D = Label3D.new()
		marker.text = marker_row["text"]
		marker.position = marker_row["position"]
		marker.font_size = 34
		marker.outline_size = 7
		marker.pixel_size = 0.004
		marker.modulate = marker_row["color"]
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.no_depth_test = true
		add_child(marker)


func _configure_a19_geometry_capture() -> void:
	var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
	phase_director.set_process(false)
	phase_director.set_physics_process(false)
	_apply_a19_capture_state()

	var audit_layer: CanvasLayer = CanvasLayer.new()
	audit_layer.name = "A19GeometryAuditLayer"
	audit_layer.layer = 30
	add_child(audit_layer)
	var audit_label: Label = Label.new()
	audit_label.text = (
		"A19 GEOMETRY AUDIT — CURRENT LAYOUT PRESERVED\n"
		+ "FITTED DOORS • SEALED SEAMS • GROUNDED PROPS • MATCHED COLLIDERS"
	)
	audit_label.position = Vector2(32.0, 76.0)
	audit_label.add_theme_font_size_override("font_size", 26)
	audit_label.add_theme_color_override("font_color", Color("#f2f5f9"))
	audit_label.add_theme_color_override("font_outline_color", Color("#111820"))
	audit_label.add_theme_constant_override("outline_size", 7)
	audit_layer.add_child(audit_label)

	var bath_marker: Label3D = Label3D.new()
	bath_marker.name = "A19BathroomDoorLabel"
	bath_marker.text = "BATH DOOR 2.95 m — FRAME FIT"
	bath_marker.position = Vector3(-5.65, 0.35, -1.15)
	bath_marker.font_size = 44
	bath_marker.outline_size = 7
	bath_marker.pixel_size = 0.007
	bath_marker.modulate = Color("#d889de")
	bath_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bath_marker.no_depth_test = true
	add_child(bath_marker)


func _apply_a19_capture_state() -> void:
	for fixture_name: String in [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
		"BathroomLampVisual",
		"HallDoorLampVisual",
	]:
		var fixture: Node3D = $Level.get_node(fixture_name) as Node3D
		fixture.visible = true
		(fixture.get_node("Light") as OmniLight3D).visible = true
	for door: DinnerDoor in [
		$BedroomDoor as DinnerDoor,
		$Level/BathroomDoor as DinnerDoor,
		$Pantry as DinnerDoor,
		$Fridge as DinnerDoor,
	]:
		door.close_immediately()


func _configure_a18_wall_blocking_capture() -> void:
	var phase_director: PhaseDirector = $PhaseDirector as PhaseDirector
	phase_director.set_process(false)
	phase_director.set_physics_process(false)

	for fixture_name: String in [
		"KidLampVisual",
		"LivingLampVisual",
		"KitchenLampVisual",
		"MidLampVisual",
		"AlcoveLampVisual",
		"BathroomLampVisual",
	]:
		var fixture: Node3D = $Level.get_node(fixture_name) as Node3D
		fixture.visible = false
	var hall_switch: DinnerWorldSwitch = (
		$Level/KidHallSwitch as DinnerWorldSwitch
	)
	hall_switch.set_state(true, false)

	var bedroom_door: DinnerDoor = $BedroomDoor as DinnerDoor
	bedroom_door.openness = 1.0
	bedroom_door.call("_apply_visual")

	var camera_target: Vector3 = Vector3(-10.8, 0.0, 1.2)
	var camera_rig: Node3D = $CameraRig as Node3D
	camera_rig.global_position = camera_target + Vector3(0.0, 18.0, 0.01)
	camera_rig.look_at(camera_target, Vector3.UP)
	($CameraRig/OrthoCamera as Camera3D).size = 12.5

	var proof_layer: CanvasLayer = CanvasLayer.new()
	proof_layer.name = "A18WallBlockingProof"
	proof_layer.layer = 30
	add_child(proof_layer)
	var proof_label: Label = Label.new()
	proof_label.text = (
		"A18 LIGHTING V3 — HALL LIGHT ONLY\n"
		+ "SOLID WALL BLOCKS • OPEN BEDROOM DOOR SPILLS"
	)
	proof_label.position = Vector2(32.0, 80.0)
	proof_label.add_theme_font_size_override("font_size", 28)
	proof_label.add_theme_color_override("font_color", Color("#f2f5f9"))
	proof_label.add_theme_color_override("font_outline_color", Color("#111820"))
	proof_label.add_theme_constant_override("outline_size", 7)
	proof_layer.add_child(proof_label)

	for marker_row: Dictionary in [
		{
			"text": "WALL BLOCK",
			"position": Vector3(-9.0, 0.4, 2.4),
			"color": Color("#c8d2df"),
		},
		{
			"text": "DOORWAY SPILL",
			"position": Vector3(-12.75, 0.4, 2.4),
			"color": Color("#d889de"),
		},
	]:
		var marker: Label3D = Label3D.new()
		marker.text = marker_row["text"]
		marker.position = marker_row["position"]
		marker.font_size = 28
		marker.outline_size = 7
		marker.pixel_size = 0.003
		marker.modulate = marker_row["color"]
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.no_depth_test = true
		add_child(marker)


func _configure_a16_fridge_capture(is_open: bool) -> void:
	var fridge: DinnerDoor = $Fridge as DinnerDoor
	fridge.provides_snack = false
	fridge.openness = 1.0 if is_open else 0.0
	fridge.call("_apply_visual")
	var camera_target: Vector3 = Vector3(13.2, 0.2, -4.5)
	var camera_rig: Node3D = $CameraRig as Node3D
	camera_rig.global_position = camera_target + Vector3(0.0, 18.0, 0.01)
	camera_rig.look_at(camera_target, Vector3.UP)
	($CameraRig/OrthoCamera as Camera3D).size = 9.0

	var state_layer: CanvasLayer = CanvasLayer.new()
	state_layer.name = "A10FridgeStateLayer"
	state_layer.layer = 30
	add_child(state_layer)
	var state_label: Label = Label.new()
	state_label.name = "State"
	state_label.text = (
		"FRIDGE OPEN — SOUTH-WEST HINGE / PANEL POINTS SOUTH"
		if is_open
		else "FRIDGE CLOSED — SOUTH FACE / SOUTH-WEST HINGE"
	)
	state_label.position = Vector2(32.0, 82.0)
	state_label.add_theme_font_size_override("font_size", 30)
	state_label.add_theme_color_override("font_color", Color("#f2f5f9"))
	state_label.add_theme_color_override("font_outline_color", Color("#111820"))
	state_label.add_theme_constant_override("outline_size", 7)
	state_layer.add_child(state_label)

	var wall_label: Label3D = Label3D.new()
	wall_label.name = "A16SouthDirectionLabel"
	wall_label.text = "SOUTH / DOWN-SCREEN"
	wall_label.position = Vector3(13.2, 0.5, -1.5)
	wall_label.font_size = 30
	wall_label.outline_size = 7
	wall_label.pixel_size = 0.003
	wall_label.modulate = Color("#c9d8eb")
	wall_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wall_label.no_depth_test = true
	add_child(wall_label)

	var hinge_label: Label3D = Label3D.new()
	hinge_label.name = "A16HingeLabel"
	hinge_label.text = "HINGE"
	hinge_label.position = Vector3(12.55, 0.35, -4.2)
	hinge_label.font_size = 30
	hinge_label.outline_size = 7
	hinge_label.pixel_size = 0.003
	hinge_label.modulate = Color("#d889de")
	hinge_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hinge_label.no_depth_test = true
	add_child(hinge_label)


func _settle_verification_audio() -> void:
	var audio_players: Array[Node] = []
	audio_players.append_array(
		get_tree().root.find_children("*", "AudioStreamPlayer", true, false)
	)
	audio_players.append_array(
		get_tree().root.find_children("*", "AudioStreamPlayer2D", true, false)
	)
	audio_players.append_array(
		get_tree().root.find_children("*", "AudioStreamPlayer3D", true, false)
	)
	for node in audio_players:
		node.call("stop")
		node.set("stream", null)
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
