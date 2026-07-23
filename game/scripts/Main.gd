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
	var capture_path: String = _capture_path_from_args()
	if not capture_path.is_empty():
		_capture_layout(capture_path)


func _verify_input_map() -> void:
	for action: String in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			push_error("Missing required input action: %s" % action)
			return
	print("A0 input map verified: %d required actions present." % REQUIRED_ACTIONS.size())


func _verify_light_system() -> void:
	var bedroom_anchor: Vector3 = Vector3(-10.0, 0.0, 0.5)
	assert(is_equal_approx(LightSystem.get_brightness_at(bedroom_anchor), 1.0))
	assert(is_zero_approx(LightSystem.get_brightness_at(Vector3(-20.0, 0.0, 0.5))))

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
	assert(tv_mask > 0.0)
	assert(speaker_mask > 0.0)

	NoiseSystem.set_ambient_source_enabled("tv", false)
	assert(is_zero_approx(NoiseSystem.get_mask_at(tv_position)))
	NoiseSystem.set_ambient_source_enabled("tv", true)
	assert(is_equal_approx(NoiseSystem.get_mask_at(tv_position), tv_mask))

	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", false)
	assert(is_zero_approx(NoiseSystem.get_mask_at(speaker_position)))
	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", true)
	assert(is_equal_approx(NoiseSystem.get_mask_at(speaker_position), speaker_mask))
	print("A4 verification passed: TV/speaker masks register and vanish when disabled.")


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

	var bathroom_door: Node3D = get_node("Level/BathroomDoor") as Node3D
	assert(
		bathroom_door.find_children("*", "CollisionObject3D", true, false).is_empty(),
		"Bathroom door dressing added collision to the walkway."
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


func _capture_path_from_args() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-layout="):
			return argument.trim_prefix("--capture-layout=")
	return ""


func _capture_layout(capture_path: String) -> void:
	for frame: int in range(capture_warmup_frames):
		await get_tree().process_frame
	var image: Image = get_viewport().get_texture().get_image()
	var result: Error = image.save_png(capture_path)
	if result != OK:
		push_error("Could not save layout capture to %s (error %d)." % [capture_path, result])
	else:
		print("A0 layout capture saved: %s" % capture_path)
	get_tree().quit()
