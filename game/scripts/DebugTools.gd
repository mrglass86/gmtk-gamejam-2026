extends Node
class_name DinnerDebugTools

## Throwaway tuning affordances required by brief 10.1. All input and world
## mutation is rejected outside debug builds.

const NOISE_SURFACE_SCENE: PackedScene = preload("res://scenes/NoiseSurface.tscn")

@export_group("Scene References")
@export_node_path("Node3D") var level_path: NodePath = NodePath("../Level")
@export_node_path("CharacterBody3D") var player_path: NodePath = NodePath("../Player")
@export_node_path("Node3D") var parent_path: NodePath = NodePath("../Parent")
@export_node_path("Node3D") var pet_path: NodePath = NodePath("../Pet")
@export_node_path("Camera3D") var camera_path: NodePath = NodePath("../CameraRig/OrthoCamera")

@export_group("Clock")
@export var scrub_seconds: float = 30.0

@export_group("Cursor Tools")
@export var teleport_height: float = 0.6
@export var ray_length: float = 100.0
@export var noise_loudness_min: float = 0.25
@export var noise_loudness_max: float = 5.0
@export var noise_loudness_step: float = 0.25
@export var debug_surface_size: Vector2 = Vector2(1.0, 1.0)
@export var debug_surface_height: float = 0.02

@export_group("Trial Lamps")
@export var trial_lamp_height: float = 1.42
@export var trial_lamp_source_height: float = 4.5
@export var trial_lamp_radius_default: float = 5.8
@export var trial_lamp_radius_min: float = 1.0
@export var trial_lamp_radius_max: float = 10.0
@export var trial_lamp_radius_step: float = 0.25
@export var trial_lamp_energy: float = 1.8
@export_range(0.0, 10.0) var trial_lamp_visual_attenuation: float = 1.8
@export var trial_lamp_analytic_energy: float = 1.0
@export var trial_lamp_shadow_blur: float = 2.0
@export_range(0.0, 1.0) var trial_lamp_shadow_opacity: float = 0.8
@export var trial_lamp_zone: String = "hall"

var noise_loudness: float = 1.0
var last_loudness: float = 0.0

var _level: Node3D
var _player: CharacterBody3D
var _parent: Node3D
var _pet: Node3D
var _camera: Camera3D
var _overlay_layer: CanvasLayer
var _overlay_label: Label
var _trial_lamps: Array[Node3D] = []
var _active_trial_lamp: Node3D
var _next_trial_lamp_id: int = 1


func _ready() -> void:
	_level = get_node_or_null(level_path) as Node3D
	_player = get_node_or_null(player_path) as CharacterBody3D
	_parent = get_node_or_null(parent_path) as Node3D
	_pet = get_node_or_null(pet_path) as Node3D
	_camera = get_node_or_null(camera_path) as Camera3D
	_build_overlay()
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)


func _process(_delta: float) -> void:
	if _overlay_layer.visible:
		_update_overlay()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_skip"):
		GameClock.scrub(scrub_seconds)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_rewind"):
		GameClock.scrub(-scrub_seconds)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_overlay"):
		_overlay_layer.visible = not _overlay_layer.visible
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_teleport"):
		teleport_player_to_screen_point(get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_spawn_noise"):
		spawn_noise_surface_at_screen_point(get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_spawn_lamp"):
		spawn_trial_lamp_at_screen_point(get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_remove_lamp"):
		remove_nearest_trial_lamp_at_screen_point(
			get_viewport().get_mouse_position()
		)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if is_instance_valid(_active_trial_lamp):
				adjust_active_trial_radius(trial_lamp_radius_step)
			else:
				_cycle_noise_loudness(noise_loudness_step)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if is_instance_valid(_active_trial_lamp):
				adjust_active_trial_radius(-trial_lamp_radius_step)
			else:
				_cycle_noise_loudness(-noise_loudness_step)
			get_viewport().set_input_as_handled()


func teleport_player_to_screen_point(screen_point: Vector2) -> bool:
	if not OS.is_debug_build() or _player == null:
		return false
	var nav_position: Variant = _cursor_nav_position(screen_point)
	if nav_position == null:
		return false
	var target: Vector3 = nav_position as Vector3
	_player.global_position = target + Vector3.UP * teleport_height
	_player.velocity = Vector3.ZERO
	return true


func spawn_noise_surface_at_screen_point(screen_point: Vector2) -> NoiseSurface:
	if not OS.is_debug_build() or _level == null:
		return null
	var nav_position: Variant = _cursor_nav_position(screen_point)
	if nav_position == null:
		return null
	var surface: NoiseSurface = NOISE_SURFACE_SCENE.instantiate() as NoiseSurface
	surface.name = "DebugNoiseSurface"
	surface.loudness_multiplier = noise_loudness
	surface.surface_size = debug_surface_size
	surface.surface_height = minf(debug_surface_height, 0.03)
	surface.surface_group = &"surface_creaky"
	_level.add_child(surface)
	surface.global_position = nav_position as Vector3
	return surface


func spawn_trial_lamp_at_screen_point(screen_point: Vector2) -> Node3D:
	if not OS.is_debug_build() or _level == null:
		return null
	var nav_position: Variant = _cursor_nav_position(screen_point)
	if nav_position == null:
		return null
	var lamp: Node3D = Node3D.new()
	var lamp_number: int = _next_trial_lamp_id
	_next_trial_lamp_id += 1
	lamp.name = "TrialLamp%02d" % lamp_number
	lamp.set_meta(&"light_id", "debug_trial_lamp_%02d" % lamp_number)
	lamp.set_meta(&"radius", trial_lamp_radius_default)
	_level.add_child(lamp)
	var floor_position: Vector3 = nav_position as Vector3
	floor_position.y = 0.0
	lamp.global_position = floor_position
	_add_trial_lamp_visual(lamp)
	_trial_lamps.append(lamp)
	_active_trial_lamp = lamp
	_register_trial_lamp(lamp)
	return lamp


func remove_nearest_trial_lamp_at_screen_point(screen_point: Vector2) -> bool:
	if not OS.is_debug_build() or _trial_lamps.is_empty():
		return false
	var nav_position: Variant = _cursor_nav_position(screen_point)
	if nav_position == null:
		return false
	var target_position: Vector3 = nav_position as Vector3
	var nearest: Node3D
	var nearest_distance: float = INF
	for lamp: Node3D in _trial_lamps:
		if not is_instance_valid(lamp):
			continue
		var distance: float = lamp.global_position.distance_squared_to(
			target_position
		)
		if distance < nearest_distance:
			nearest = lamp
			nearest_distance = distance
	if nearest == null:
		return false
	var light_id: String = str(nearest.get_meta(&"light_id"))
	LightSystem.unregister_dynamic_light(light_id)
	_trial_lamps.erase(nearest)
	nearest.queue_free()
	_active_trial_lamp = _nearest_trial_lamp_to(target_position)
	return true


func adjust_active_trial_radius(delta: float) -> float:
	if not OS.is_debug_build() or not is_instance_valid(_active_trial_lamp):
		return 0.0
	var next_radius: float = clampf(
		float(_active_trial_lamp.get_meta(&"radius")) + delta,
		trial_lamp_radius_min,
		trial_lamp_radius_max
	)
	_active_trial_lamp.set_meta(&"radius", next_radius)
	var light: OmniLight3D = _active_trial_lamp.get_node("Light") as OmniLight3D
	light.omni_range = next_radius
	var light_id: String = str(_active_trial_lamp.get_meta(&"light_id"))
	LightSystem.set_dynamic_light(
		light_id,
		next_radius,
		trial_lamp_analytic_energy
	)
	return next_radius


func get_trial_lamp_rows() -> PackedStringArray:
	var rows: PackedStringArray = []
	for lamp: Node3D in _trial_lamps:
		if not is_instance_valid(lamp):
			continue
		var floor_position: Vector3 = lamp.global_position
		var radius: float = float(lamp.get_meta(&"radius"))
		rows.append(
			'_add_omni("%s", "%s", Vector3(%.2f, %.2f, %.2f), 0.90, 0.00, %.2f)'
			% [
				lamp.name,
				trial_lamp_zone,
				floor_position.x,
				trial_lamp_height,
				floor_position.z,
				radius,
			]
		)
	return rows


func is_overlay_visible() -> bool:
	return _overlay_layer != null and _overlay_layer.visible


func _cursor_nav_position(screen_point: Vector2) -> Variant:
	if _camera == null:
		return null
	var ray_origin: Vector3 = _camera.project_ray_origin(screen_point)
	var ray_direction: Vector3 = _camera.project_ray_normal(screen_point)
	var floor_plane: Plane = Plane(Vector3.UP, 0.0)
	var floor_hit: Variant = floor_plane.intersects_ray(ray_origin, ray_direction)
	if floor_hit == null:
		return null
	var navigation_map: RID = get_viewport().world_3d.navigation_map
	return NavigationServer3D.map_get_closest_point(navigation_map, floor_hit as Vector3)


func _cycle_noise_loudness(delta: float) -> void:
	noise_loudness += delta
	if noise_loudness > noise_loudness_max:
		noise_loudness = noise_loudness_min
	elif noise_loudness < noise_loudness_min:
		noise_loudness = noise_loudness_max


func _add_trial_lamp_visual(lamp: Node3D) -> void:
	var marker: MeshInstance3D = MeshInstance3D.new()
	marker.name = "Shade"
	marker.position = Vector3(0.0, trial_lamp_height, 0.0)
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var marker_mesh: BoxMesh = BoxMesh.new()
	marker_mesh.size = Vector3(0.42, 0.22, 0.42)
	var marker_material: StandardMaterial3D = StandardMaterial3D.new()
	marker_material.albedo_color = Color("#dce9ff")
	marker_material.emission_enabled = true
	marker_material.emission = Color("#dce9ff")
	marker_material.emission_energy_multiplier = 1.2
	marker.mesh = marker_mesh
	marker.material_override = marker_material
	lamp.add_child(marker)

	var light: OmniLight3D = OmniLight3D.new()
	light.name = "Light"
	light.position = Vector3(0.0, trial_lamp_source_height, 0.0)
	light.light_color = Color("#d6e1f2")
	light.light_energy = trial_lamp_energy
	light.omni_range = trial_lamp_radius_default
	light.omni_attenuation = trial_lamp_visual_attenuation
	light.shadow_enabled = true
	light.shadow_blur = trial_lamp_shadow_blur
	light.shadow_opacity = trial_lamp_shadow_opacity
	lamp.add_child(light)


func _register_trial_lamp(lamp: Node3D) -> void:
	var light_id: String = str(lamp.get_meta(&"light_id"))
	LightSystem.register_dynamic_light(light_id, lamp.global_position)
	LightSystem.set_dynamic_light(
		light_id,
		float(lamp.get_meta(&"radius")),
		trial_lamp_analytic_energy
	)


func _nearest_trial_lamp_to(world_position: Vector3) -> Node3D:
	var nearest: Node3D
	var nearest_distance: float = INF
	for lamp: Node3D in _trial_lamps:
		if not is_instance_valid(lamp):
			continue
		var distance: float = lamp.global_position.distance_squared_to(
			world_position
		)
		if distance < nearest_distance:
			nearest = lamp
			nearest_distance = distance
	return nearest


func _on_noise_emitted(_pos: Vector3, loudness: float, _source: Node) -> void:
	last_loudness = loudness


func _build_overlay() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.name = "DebugOverlay"
	_overlay_layer.layer = 20
	_overlay_layer.visible = false
	add_child(_overlay_layer)

	_overlay_label = Label.new()
	_overlay_label.position = Vector2(24.0, 72.0)
	_overlay_label.add_theme_font_size_override("font_size", 18)
	_overlay_label.add_theme_color_override("font_color", Color("#e5e9ee"))
	_overlay_layer.add_child(_overlay_label)


func _update_overlay() -> void:
	var brightness: float = 0.0
	var mask: float = 0.0
	if _player != null:
		brightness = LightSystem.get_brightness_at(_player.global_position)
		mask = NoiseSystem.get_mask_at(_player.global_position)
	var parent_state: String = _state_name(_parent)
	var pet_state: String = _state_name(_pet)
	var suspicion: float = float(_parent.get("suspicion")) if _parent != null else 0.0
	var overlay_text: String = (
		"t %.1f  phase %d\nparent %s  suspicion %.1f\npet %s\n"
		+ "brightness %.2f  mask %.2f\nlast noise %.2f  surface %.2f"
	) % [
		GameClock.time_remaining,
		GameClock.phase,
		parent_state,
		suspicion,
		pet_state,
		brightness,
		mask,
		last_loudness,
		noise_loudness,
	]
	var lamp_rows: PackedStringArray = get_trial_lamp_rows()
	overlay_text += "\n\ntrial lamps (LevelBuilder rows):"
	if lamp_rows.is_empty():
		overlay_text += "\n(none; L add, scroll radius, K remove)"
	else:
		overlay_text += "\n" + "\n".join(lamp_rows)
	_overlay_label.text = overlay_text


func _state_name(actor: Node3D) -> String:
	if actor != null and actor.has_method("get_state_name"):
		return str(actor.call("get_state_name"))
	return "--"
