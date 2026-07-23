extends Node3D

## A0 procedural greybox. It uses only primitive meshes and builds static
## collision for the authored floor and walls. The completed collider set is
## baked exactly once at startup into the NavigationRegion3D below this node.

@export var wall_height: float = 1.2
@export var wall_thickness: float = 0.25
@export var floor_thickness: float = 0.2
@export var prop_height: float = 0.8
@export var lamp_energy: float = 2.0
@export var lamp_range: float = 7.0

@export_group("Ambient Masking")
@export var tv_mask_radius: float = 5.5
@export_range(0.0, 1.0) var tv_mask_strength: float = 0.7
@export var speaker_mask_radius: float = 4.5
@export_range(0.0, 1.0) var speaker_mask_strength: float = 0.6

@export var wall_color: Color = Color("#6d727a")
@export var carpet_color: Color = Color("#353a42")
@export var hardwood_color: Color = Color("#72777d")
@export var creaky_color: Color = Color("#9ba0a5")
@export var toy_color: Color = Color("#c4c9ce")
@export var prop_color: Color = Color("#50565f")


func _ready() -> void:
	_build_floors()
	_build_walls()
	_build_props()
	_build_lights()
	_register_ambient_sources()
	_bake_navigation_once()
	if _is_layout_capture():
		_add_review_labels()


func _build_floors() -> void:
	_add_floor("KidCarpet", Vector3(-11.1, 0.0, -3.95), Vector2(7.75, 4.9), carpet_color, "surface_carpet")
	_add_floor("BathFloor", Vector3(-5.8, 0.0, -3.95), Vector2(2.9, 4.9), hardwood_color, "surface_hardwood")
	_add_floor("LivingFloor", Vector3(1.25, 0.0, -4.0), Vector2(11.1, 4.8), hardwood_color, "surface_hardwood")
	_add_floor("KitchenFloor", Vector3(10.9, 0.0, -2.1), Vector2(8.2, 8.6), hardwood_color, "surface_hardwood")
	_add_floor("MiddleFloor", Vector3(-4.1, 0.0, 0.0), Vector2(21.8, 3.0), hardwood_color, "surface_hardwood")
	_add_floor("DiningSouthFloor", Vector3(1.275, 0.0, 2.475), Vector2(11.05, 1.95), hardwood_color, "surface_hardwood")
	_add_floor("LivingThreshold", Vector3(3.6, 0.0, -1.55), Vector2(6.4, 0.2), hardwood_color, "surface_hardwood")
	_add_floor("AdultBedroomFloor", Vector3(-11.15, 0.0, 3.95), Vector2(7.7, 4.9), hardwood_color, "surface_hardwood")
	_add_floor("ApproachFloor", Vector3(-5.75, 0.0, 3.95), Vector2(3.05, 4.9), hardwood_color, "surface_hardwood")
	_add_floor("CarpetFloor", Vector3(0.25, 0.0, 5.05), Vector2(9.5, 2.7), carpet_color, "surface_carpet")
	_add_floor("AlcoveFloor", Vector3(8.1, 0.0, 4.9), Vector2(6.2, 2.95), hardwood_color, "surface_hardwood")
	_add_floor("CarpetAlcoveThreshold", Vector3(5.0, 0.0, 5.05), Vector2(0.4, 2.7), hardwood_color, "surface_hardwood")
	_add_floor("AlcoveDiningThreshold", Vector3(5.9, 0.0, 3.45), Vector2(1.8, 0.4), hardwood_color, "surface_hardwood")
	_add_floor("PantryFloor", Vector3(13.2, 0.0, 4.4), Vector2(3.6, 4.0), hardwood_color, "surface_hardwood")
	_add_floor("PantryThreshold", Vector3(13.2, 0.0, 2.3), Vector2(3.6, 0.4), hardwood_color, "surface_hardwood")
	_add_floor("HallRug", Vector3(-8.5, 0.02, 0.05), Vector2(9.0, 2.2), carpet_color, "surface_carpet")


func _build_walls() -> void:
	_add_wall("NorthWall", Vector3(0.0, wall_height * 0.5, -6.4), Vector3(30.5, wall_height, wall_thickness))
	_add_wall("SouthWall", Vector3(0.0, wall_height * 0.5, 6.4), Vector3(30.5, wall_height, wall_thickness))
	_add_wall("WestWall", Vector3(-15.0, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, 13.05))
	_add_wall("EastWall", Vector3(15.0, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, 13.05))
	_add_wall("KidSouthA", Vector3(-14.45, wall_height * 0.5, -1.5), Vector3(1.1, wall_height, wall_thickness))
	_add_wall("KidSouthB", Vector3(-9.55, wall_height * 0.5, -1.5), Vector3(4.1, wall_height, wall_thickness))
	_add_wall("KidBathDivider", Vector3(-7.25, wall_height * 0.5, -3.95), Vector3(wall_thickness, wall_height, 4.9))
	_add_wall("BathLivingDivider", Vector3(-4.3, wall_height * 0.5, -3.95), Vector3(wall_thickness, wall_height, 4.9))
	_add_wall("LivingSouth", Vector3(-1.95, wall_height * 0.5, -1.7), Vector3(4.7, wall_height, wall_thickness))
	_add_wall("DogKitchenDivider", Vector3(6.8, wall_height * 0.5, -3.9), Vector3(wall_thickness, wall_height, 5.0))
	_add_wall("AdultNorthA", Vector3(-14.45, wall_height * 0.5, 1.5), Vector3(1.1, wall_height, wall_thickness))
	_add_wall("AdultNorthB", Vector3(-9.55, wall_height * 0.5, 1.5), Vector3(4.1, wall_height, wall_thickness))
	_add_wall("AdultEast", Vector3(-7.3, wall_height * 0.5, 3.95), Vector3(wall_thickness, wall_height, 4.9))
	_add_wall("LVertical", Vector3(-4.25, wall_height * 0.5, 2.55), Vector3(wall_thickness, wall_height, 2.3))
	_add_wall("LHorizontal", Vector3(0.25, wall_height * 0.5, 3.45), Vector3(9.5, wall_height, wall_thickness))
	_add_wall("PantryWest", Vector3(11.2, wall_height * 0.5, 4.3), Vector3(wall_thickness, wall_height, 4.2))


func _build_props() -> void:
	_add_prop("CribBlock", Vector3(-8.7, 0.45, -4.7), Vector3(2.3, 0.9, 3.0), prop_color)
	_add_prop("Nightstand", Vector3(-10.2, 0.35, -5.6), Vector3(0.8, 0.7, 0.8), prop_color)
	_add_prop("TVConsole", Vector3(-3.2, 0.75, -4.1), Vector3(0.8, 1.5, 4.0), Color("#627b92"))
	_add_prop("Couch", Vector3(1.55, 0.4, -4.4), Vector3(2.3, 0.8, 3.0), prop_color)
	_add_prop("DogBed", Vector3(5.5, 0.15, -4.75), Vector3(1.8, 0.3, 2.7), prop_color)
	_add_prop("KitchenCounter", Vector3(9.8, 0.45, -5.35), Vector3(5.4, 0.9, 2.1), prop_color)
	_add_prop("FridgeBlock", Vector3(13.75, 1.1, -5.3), Vector3(2.4, 2.2, 2.2), Color("#9aa5b0"))
	_add_prop("KitchenTable", Vector3(10.55, 0.4, -1.2), Vector3(2.5, 0.8, 2.6), prop_color)
	_add_prop("DiningTable", Vector3(0.95, 0.4, 0.9), Vector3(5.1, 0.8, 2.2), prop_color)
	_add_prop("AdultBed", Vector3(-9.8, 0.4, 4.75), Vector3(4.6, 0.8, 3.1), prop_color)
	_add_prop("HallShelf", Vector3(10.1, 0.55, 4.35), Vector3(1.4, 1.1, 3.5), prop_color)
	_add_prop("AdultDoorPanel", Vector3(-12.75, 0.6, 1.5), Vector3(2.3, 1.2, 0.12), wall_color)
	_add_prop("KitchenSpeaker", Vector3(8.5, 1.15, -5.3), Vector3(0.5, 0.5, 0.5), Color("#6f7882"))


func _build_lights() -> void:
	_add_omni("KidLampVisual", "bedroom", Vector3(-11.1, 4.0, -3.9), 0.85)
	_add_omni("LivingLampVisual", "living", Vector3(0.0, 4.0, -4.2), 0.9)
	_add_omni("KitchenLampVisual", "kitchen", Vector3(10.5, 4.0, -3.0), 1.0)
	_add_omni("MidLampVisual", "hall", Vector3(-0.5, 4.0, 0.5), 0.9)
	_add_omni("AlcoveLampVisual", "hall", Vector3(8.0, 4.0, 4.8), 0.85)
	_add_area_glow("TVGlow", Vector3(-2.75, 1.25, -4.1), Vector3(0.0, -90.0, 0.0), Color("#7ea5d8"))
	_add_area_glow("WindowGlow", Vector3(-14.75, 2.4, -4.0), Vector3(0.0, -90.0, 0.0), Color("#c7d5e7"))
	_add_area_glow("DoorStripGlow", Vector3(-12.75, 0.2, 1.3), Vector3(-90.0, 0.0, 0.0), Color("#d5dce8"))


func _register_ambient_sources() -> void:
	NoiseSystem.register_ambient_source(
		"tv", Vector3(-2.75, 0.0, -4.1), tv_mask_radius, tv_mask_strength
	)
	NoiseSystem.register_ambient_source(
		"kitchen_speaker",
		Vector3(8.5, 0.0, -5.3),
		speaker_mask_radius,
		speaker_mask_strength
	)


func _is_layout_capture() -> bool:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-layout="):
			return true
	return false


func _add_review_labels() -> void:
	_add_review_label("KID / CRIB", Vector3(-11.2, 0.3, -4.0))
	_add_review_label("BATH", Vector3(-5.8, 0.3, -4.0))
	_add_review_label("LIVING / TV", Vector3(1.0, 0.3, -4.0))
	_add_review_label("KITCHEN", Vector3(11.0, 0.3, -2.1))
	_add_review_label("HALL RUG", Vector3(-8.5, 0.3, 0.1))
	_add_review_label("DINING", Vector3(0.8, 0.3, 1.0))
	_add_review_label("ADULT ROOM", Vector3(-11.0, 0.3, 4.2))
	_add_review_label("CARPET QUIET ROUTE", Vector3(1.5, 0.3, 5.1))
	_add_review_label("PANTRY", Vector3(13.2, 0.3, 4.4))


func _add_review_label(label_text: String, position_value: Vector3) -> void:
	var label: Label3D = Label3D.new()
	label.text = label_text
	label.position = position_value
	label.font_size = 44
	label.outline_size = 7
	label.pixel_size = 0.007
	label.modulate = Color("#e5e9ee")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	add_child(label)


func _add_floor(node_name: String, center: Vector3, dimensions: Vector2, color: Color, surface_group: String) -> void:
	var floor: StaticBody3D = StaticBody3D.new()
	floor.name = node_name
	floor.position = center + Vector3(0.0, -floor_thickness * 0.5, 0.0)
	floor.add_to_group(surface_group)
	floor.add_to_group("nav_source")
	_add_box_visual(floor, Vector3(dimensions.x, floor_thickness, dimensions.y), color)
	_add_box_collision(floor, Vector3(dimensions.x, floor_thickness, dimensions.y))
	add_child(floor)


func _add_wall(node_name: String, center: Vector3, dimensions: Vector3) -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	wall.name = node_name
	wall.position = center
	wall.add_to_group("nav_source")
	_add_box_visual(wall, dimensions, wall_color)
	_add_box_collision(wall, dimensions)
	add_child(wall)


func _add_prop(node_name: String, center: Vector3, dimensions: Vector3, color: Color) -> void:
	var prop: StaticBody3D = StaticBody3D.new()
	prop.name = node_name
	prop.position = center
	prop.add_to_group("nav_source")
	_add_box_visual(prop, dimensions, color)
	_add_box_collision(prop, dimensions)
	add_child(prop)


func _add_omni(node_name: String, zone: String, position_value: Vector3, energy_scale: float) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = node_name
	light.position = position_value
	light.light_color = Color("#d6e1f2")
	light.light_energy = lamp_energy * energy_scale
	light.omni_range = lamp_range
	light.shadow_enabled = true
	add_child(light)
	LightSystem.register_light(node_name, zone, Vector3(position_value.x, 0.0, position_value.z), lamp_range)


func _add_area_glow(node_name: String, position_value: Vector3, rotation_degrees_value: Vector3, color: Color) -> void:
	var glow: AreaLight3D = AreaLight3D.new()
	glow.name = node_name
	glow.position = position_value
	glow.rotation_degrees = rotation_degrees_value
	glow.light_color = color
	glow.light_energy = lamp_energy * 0.45
	glow.shadow_enabled = false
	add_child(glow)


func _add_box_visual(parent: Node3D, dimensions: Vector3, color: Color) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _add_box_collision(parent: Node3D, dimensions: Vector3) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	parent.add_child(collision)


func _bake_navigation_once() -> void:
	var navigation_region: NavigationRegion3D = $NavigationRegion3D
	navigation_region.bake_navigation_mesh(false)
	var polygon_count: int = navigation_region.navigation_mesh.get_polygon_count()
	assert(polygon_count > 0, "Static navigation bake produced no polygons.")
	print("A0.2 static navmesh baked once: %d polygons." % polygon_count)
