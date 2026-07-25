extends Node3D

## A0 procedural greybox. It uses only primitive meshes and builds static
## collision for the authored floor and walls. The completed collider set is
## baked exactly once at startup into the NavigationRegion3D below this node.

const WORLD_SWITCH_SCRIPT: Script = preload("res://scripts/WorldSwitch.gd")
## Preloaded rather than referenced by class_name: headless runs resolve
## global class names from the editor-built cache, which does not know about
## agent-added scripts until an editor scan.
const WOOD_FLOOR_MATERIAL = preload("res://scripts/WoodFloorMaterial.gd")

@export var wall_height: float = 1.2
@export var wall_thickness: float = 0.25
@export var floor_thickness: float = 0.2
@export var failsafe_floor_drop: float = 0.05
@export var failsafe_floor_thickness: float = 0.2
@export var failsafe_floor_size: Vector2 = Vector2(30.0, 12.8)
@export var prop_height: float = 0.8
@export var lamp_energy: float = 6.5
@export var area_light_energy: float = 2.2
@export_range(7.0, 9.0) var lamp_range: float = 7.8
@export var analytic_light_range: float = 5.8
@export_range(0.0, 10.0) var omni_visual_attenuation: float = 1.45
@export var omni_source_height: float = 4.5
@export var omni_shadow_blur: float = 2.0
@export_range(0.0, 1.0) var shadow_opacity: float = 0.8
@export var wall_shadow_occluder_height: float = 5.2
@export var doorway_shadow_opening_height: float = 2.4

@export_group("Practical Light Fixtures")
@export var fixture_stand_color: Color = Color("#3c4654")
@export var fixture_glow_color: Color = Color("#dce9ff")
@export var fixture_emission_energy: float = 1.0
@export var fixture_base_size: Vector3 = Vector3(0.34, 0.08, 0.34)
@export var fixture_pole_width: float = 0.07
@export var fixture_shade_size: Vector3 = Vector3(0.54, 0.28, 0.54)

@export_group("Ambient Masking")
@export var tv_mask_radius: float = 3.2
@export_range(0.0, 0.6) var tv_mask_strength: float = 0.6
@export var speaker_mask_radius: float = 2.4
@export_range(0.0, 0.6) var speaker_mask_strength: float = 0.6

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
	_build_switches()
	_register_ambient_sources()
	_bake_navigation_once()
	if _is_layout_capture():
		_add_review_labels()


func _build_floors() -> void:
	_add_failsafe_floor()
	_add_floor("KidCarpet", Vector3(-11.1, 0.0, -3.9), Vector2(7.8, 5.0), carpet_color, "surface_carpet")
	_add_floor("BathFloor", Vector3(-5.75, 0.0, -3.9), Vector2(3.1, 5.0), hardwood_color, "surface_hardwood")
	_add_floor("LivingFloor", Vector3(1.225, 0.0, -3.925), Vector2(11.25, 4.95), hardwood_color, "surface_hardwood")
	_add_floor("KitchenFloor", Vector3(10.875, 0.0, -2.1), Vector2(8.25, 8.6), hardwood_color, "surface_hardwood")
	_add_floor("MiddleFloor", Vector3(-4.1, 0.0, 0.0), Vector2(21.8, 3.2), hardwood_color, "surface_hardwood")
	_add_floor("DiningSouthFloor", Vector3(1.275, 0.0, 2.475), Vector2(11.05, 1.95), hardwood_color, "surface_hardwood")
	_add_floor("LivingThreshold", Vector3(3.6, 0.0, -1.55), Vector2(6.4, 0.2), hardwood_color, "surface_hardwood")
	_add_floor("AdultBedroomFloor", Vector3(-11.1, 0.0, 3.95), Vector2(7.8, 4.9), hardwood_color, "surface_hardwood")
	_add_floor("ApproachFloor", Vector3(-5.75, 0.0, 3.95), Vector2(3.1, 4.9), hardwood_color, "surface_hardwood")
	_add_floor("CarpetFloor", Vector3(0.25, 0.0, 4.925), Vector2(9.5, 2.95), carpet_color, "surface_carpet")
	_add_floor("AlcoveFloor", Vector3(8.1, 0.0, 4.9), Vector2(6.2, 2.95), hardwood_color, "surface_hardwood")
	_add_floor("CarpetAlcoveThreshold", Vector3(5.0, 0.0, 5.05), Vector2(0.4, 2.7), hardwood_color, "surface_hardwood")
	_add_floor("AlcoveDiningThreshold", Vector3(5.9, 0.0, 3.45), Vector2(1.8, 0.4), hardwood_color, "surface_hardwood")
	_add_floor("EastHallFloor", Vector3(9.0, 0.0, 2.8125), Vector2(4.6, 1.425), hardwood_color, "surface_hardwood")
	_add_floor("PantryFloor", Vector3(13.05, 0.0, 4.4), Vector2(3.9, 4.0), hardwood_color, "surface_hardwood")
	_add_floor("PantryThreshold", Vector3(13.05, 0.0, 2.3), Vector2(3.9, 0.4), hardwood_color, "surface_hardwood")
	# Rug starts east of the hidden CreakTeacher (-12.7..-10.9) so the first
	# steps out of the kid bedroom land on honest creak-capable hardwood
	# (director ruling, 2026-07-24 playtest follow-up).
	_add_floor("HallRug", Vector3(-7.35, 0.02, 0.05), Vector2(6.7, 2.2), carpet_color, "surface_carpet")


func _build_walls() -> void:
	_add_wall("NorthWall", Vector3(0.0, wall_height * 0.5, -6.4), Vector3(30.25, wall_height, wall_thickness))
	_add_wall("SouthWall", Vector3(0.0, wall_height * 0.5, 6.4), Vector3(30.25, wall_height, wall_thickness))
	_add_wall("WestWall", Vector3(-15.0, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, 13.05))
	_add_wall("EastWall", Vector3(15.0, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, 13.05))
	# Junction ends cover the adjoining wall's full thickness without protruding
	# past its far face. Doorway/open-route ends retain their authored bounds.
	_add_wall("KidSouthA", Vector3(-14.5125, wall_height * 0.5, -1.5), Vector3(1.225, wall_height, wall_thickness))
	_add_wall("KidSouthB", Vector3(-9.3625, wall_height * 0.5, -1.5), Vector3(4.475, wall_height, wall_thickness))
	_add_wall("KidBathDivider", Vector3(-7.25, wall_height * 0.5, -3.95), Vector3(wall_thickness, wall_height, 5.15))
	_add_wall("BathLivingDivider", Vector3(-4.3, wall_height * 0.5, -4.05), Vector3(wall_thickness, wall_height, 4.95))
	_add_wall("DogKitchenDivider", Vector3(6.8, wall_height * 0.5, -3.9625), Vector3(wall_thickness, wall_height, 5.125))
	_add_wall("AdultNorthA", Vector3(-14.5125, wall_height * 0.5, 1.5), Vector3(1.225, wall_height, wall_thickness))
	_add_wall("AdultNorthB", Vector3(-9.3875, wall_height * 0.5, 1.5), Vector3(4.425, wall_height, wall_thickness))
	_add_wall("AdultEast", Vector3(-7.3, wall_height * 0.5, 3.95), Vector3(wall_thickness, wall_height, 5.15))
	_add_wall("LVertical", Vector3(-4.25, wall_height * 0.5, 2.4875), Vector3(wall_thickness, wall_height, 2.175))
	_add_wall("LHorizontal", Vector3(0.3125, wall_height * 0.5, 3.45), Vector3(9.375, wall_height, wall_thickness))
	_add_wall("PantryWest", Vector3(11.2, wall_height * 0.5, 4.3625), Vector3(wall_thickness, wall_height, 4.325))
	# The low greybox walls need an invisible upper frame around each opening.
	# Segment occluders stop light at solid wall; these lintels stop a 4.5 m
	# source from treating a doorway as an unbounded floor-to-ceiling hole.
	_add_doorway_shadow_lintel(
		"KidDoorShadowLintel",
		Vector3(-12.75, 0.0, -1.5),
		Vector2(2.3, wall_thickness)
	)
	_add_doorway_shadow_lintel(
		"BathroomDoorShadowLintel",
		Vector3(-5.65, 0.0, -1.5),
		Vector2(2.95, wall_thickness)
	)
	_add_doorway_shadow_lintel(
		"AdultDoorShadowLintel",
		Vector3(-12.75, 0.0, 1.5),
		Vector2(2.3, wall_thickness)
	)
	_add_doorway_shadow_lintel(
		"PantryDoorShadowLintel",
		Vector3(13.1, 0.0, 2.2),
		Vector2(3.55, wall_thickness)
	)


func _build_props() -> void:
	_add_crib()
	_add_prop("Nightstand", Vector3(-10.2, 0.35, -5.6), Vector3(0.8, 0.7, 0.8), prop_color)
	_add_prop("TVConsole", Vector3(-3.2, 0.75, -4.1), Vector3(0.8, 1.5, 4.0), Color("#627b92"))
	_add_couch()
	_add_dog_station()
	_add_prop("KitchenCounter", Vector3(9.8, 0.45, -5.35), Vector3(5.4, 0.9, 2.1), prop_color)
	_add_fridge_block()
	_add_kitchen_table()
	_add_kitchen_bowl()
	_add_dining_table()
	_add_toilet()
	_add_prop("AdultBed", Vector3(-9.8, 0.4, 4.75), Vector3(4.6, 0.8, 3.1), prop_color)
	_add_prop("HallShelf", Vector3(10.1, 0.55, 4.35), Vector3(1.4, 1.1, 3.5), prop_color)
	_add_prop("AdultDoorPanel", Vector3(-12.75, 0.6, 1.5), Vector3(2.3, 1.2, 0.25), wall_color)
	_add_prop("KitchenSpeaker", Vector3(8.5, 1.15, -5.3), Vector3(0.5, 0.5, 0.5), Color("#6f7882"))
	_add_visual_prop("FrontDoor", Vector3(8.0, 0.6, 6.2), Vector3(2.4, 1.2, 0.15), Color("#59616b"))
	_add_visual_prop("DoorMat", Vector3(8.0, 0.01, 5.85), Vector3(1.6, 0.02, 0.9), carpet_color)
	_add_front_door_side_table()


func _build_lights() -> void:
	_add_omni(
		"KidLampVisual",
		"bedroom",
		Vector3(-10.2, 1.12, -5.6),
		0.85,
		0.70,
		-1.0,
		Vector3(-10.8, 4.5, -3.8)
	)
	_add_omni(
		"LivingLampVisual",
		"living",
		Vector3(0.15, 1.48, -5.25),
		0.9,
		0.0,
		-1.0,
		Vector3(1.5, 4.5, -3.9)
	)
	_add_omni(
		"KitchenLampVisual",
		"kitchen",
		Vector3(10.7, 1.16, -2.3),
		1.0,
		0.0,
		-1.0,
		Vector3(10.7, 4.5, -2.3),
		Vector3(10.7, 0.0, -2.3),
		true,
		&"ceiling_disc"
	)
	_add_omni(
		"MidLampVisual",
		"hall",
		Vector3(0.95, 1.16, 0.9),
		0.95,
		0.0,
		-1.0,
		Vector3(0.95, 4.5, 0.9),
		Vector3(0.95, 0.0, 0.9),
		true,
		&"ceiling_disc"
	)
	_add_omni(
		"DiningEntryLampVisual",
		"hall",
		Vector3(-0.5, 1.16, 0.5),
		0.85,
		0.0,
		-1.0,
		Vector3(-0.5, 4.5, 0.5),
		Vector3(-0.5, 0.0, 0.5),
		true,
		&"ceiling_disc"
	)
	_add_omni(
		"AlcoveLampVisual",
		"hall",
		Vector3(8.3, 1.16, 4.7),
		1.05,
		0.0,
		-1.0,
		Vector3(8.3, 4.5, 4.7),
		Vector3(8.3, 0.0, 4.7),
		true,
		&"ceiling_disc"
	)
	_add_omni(
		"BathroomLampVisual",
		"bathroom",
		Vector3(-5.75, 1.16, -3.9),
		0.78,
		0.0,
		-1.0,
		Vector3(-5.75, 4.5, -3.9),
		Vector3.ZERO,
		false,
		&"ceiling_disc"
	)
	_add_omni(
		"HallDoorLampVisual",
		"hall",
		Vector3(-9.8, 1.16, 0.0),
		0.85,
		0.0,
		5.6,
		Vector3(-9.8, 4.5, 0.0),
		Vector3(-9.8, 0.0, 0.0),
		false,
		&"ceiling_disc"
	)
	_add_omni(
		"CarpetHallLampWest",
		"hall",
		Vector3(-2.2, 1.16, 4.9),
		0.9,
		0.0,
		-1.0,
		Vector3(-2.2, 4.5, 4.9),
		Vector3(-2.2, 0.0, 4.9),
		true,
		&"ceiling_disc"
	)
	_add_omni(
		"CarpetHallLampEast",
		"hall",
		Vector3(2.7, 1.16, 4.9),
		0.9,
		0.0,
		-1.0,
		Vector3(2.7, 4.5, 4.9),
		Vector3(2.7, 0.0, 4.9),
		true,
		&"ceiling_disc"
	)
	_add_area_glow(
		"TVGlow",
		Vector3(-2.75, 1.25, -4.1),
		Vector3.ZERO,
		Color("#7ea5d8"),
		0.75
	)
	var tv_glow: AreaLight3D = $TVGlow as AreaLight3D
	tv_glow.look_at(Vector3(1.55, 0.4, -4.4), Vector3.UP)
	_add_area_glow("WindowGlow", Vector3(-14.75, 2.4, -4.0), Vector3(0.0, -90.0, 0.0), Color("#c7d5e7"))
	_add_area_glow("DoorStripGlow", Vector3(-12.75, 0.2, 1.3), Vector3(-90.0, 0.0, 0.0), Color("#d5dce8"))


func _build_switches() -> void:
	_add_world_switch(
		"DiningSwitch",
		&"dining",
		Vector3(-4.065, 1.0, 0.85),
		"MidLampVisual",
		true,
		Vector3.RIGHT,
		PackedStringArray(["DiningEntryLampVisual"])
	)
	_add_world_switch(
		"KitchenSwitch",
		&"kitchen",
		Vector3(6.985, 1.0, -1.15),
		"KitchenLampVisual",
		true,
		Vector3.RIGHT
	)
	_add_world_switch(
		"FoyerSwitch",
		&"foyer",
		Vector3(8.75, 1.0, 6.215),
		"AlcoveLampVisual",
		true,
		Vector3.FORWARD
	)
	_add_world_switch(
		"BathroomSwitch",
		&"bathroom",
		Vector3(-4.485, 1.0, -2.15),
		"BathroomLampVisual",
		false,
		Vector3.LEFT
	)
	_add_world_switch(
		"KidHallSwitch",
		&"kid_hall",
		Vector3(-10.15, 1.0, -1.315),
		"HallDoorLampVisual",
		false,
		Vector3.BACK
	)
	_add_world_switch(
		"CarpetHallSwitch",
		&"carpet_hall",
		Vector3(-3.65, 1.0, 3.635),
		"CarpetHallLampWest",
		true,
		Vector3.BACK,
		PackedStringArray(["CarpetHallLampEast"])
	)


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
	var slab_size: Vector3 = Vector3(dimensions.x, floor_thickness, dimensions.y)
	if surface_group == "surface_hardwood":
		_add_box_visual_with_material(floor, slab_size, WOOD_FLOOR_MATERIAL.shared())
	else:
		_add_box_visual(floor, slab_size, color)
	_add_box_collision(floor, slab_size)
	add_child(floor)


func _add_failsafe_floor() -> void:
	var slab: StaticBody3D = StaticBody3D.new()
	slab.name = "FailsafeSlab"
	slab.position = Vector3(
		0.0,
		-failsafe_floor_drop - failsafe_floor_thickness * 0.5,
		0.0
	)
	slab.add_to_group("surface_hardwood")
	_add_box_visual_with_material(
		slab,
		Vector3(failsafe_floor_size.x, failsafe_floor_thickness, failsafe_floor_size.y),
		WOOD_FLOOR_MATERIAL.shared()
	)
	_add_box_collision(
		slab,
		Vector3(failsafe_floor_size.x, failsafe_floor_thickness, failsafe_floor_size.y)
	)
	add_child(slab)


func _add_wall(node_name: String, center: Vector3, dimensions: Vector3) -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	wall.name = node_name
	wall.position = center
	wall.add_to_group("nav_source")
	_add_box_visual(wall, dimensions, wall_color)
	_add_wall_shadow_occluder(wall, dimensions)
	_add_box_collision(wall, dimensions)
	add_child(wall)


func _add_wall_shadow_occluder(
	wall: StaticBody3D,
	dimensions: Vector3
) -> void:
	var resolved_height: float = maxf(
		wall_shadow_occluder_height,
		omni_source_height + 0.7
	)
	var occluder: MeshInstance3D = MeshInstance3D.new()
	occluder.name = "ShadowOccluder"
	occluder.position.y = (
		resolved_height - dimensions.y
	) * 0.5
	occluder.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	)
	occluder.add_to_group("wall_shadow_occluder")
	occluder.set_meta("wall_name", wall.name)
	var occluder_mesh: BoxMesh = BoxMesh.new()
	occluder_mesh.size = Vector3(
		dimensions.x,
		resolved_height,
		dimensions.z
	)
	occluder.mesh = occluder_mesh
	wall.add_child(occluder)


func _add_doorway_shadow_lintel(
	node_name: String,
	floor_center: Vector3,
	opening_size: Vector2
) -> void:
	var resolved_height: float = maxf(
		wall_shadow_occluder_height,
		omni_source_height + 0.7
	)
	var opening_height: float = clampf(
		doorway_shadow_opening_height,
		wall_height,
		resolved_height - 0.1
	)
	var lintel: MeshInstance3D = MeshInstance3D.new()
	lintel.name = node_name
	lintel.position = Vector3(
		floor_center.x,
		(opening_height + resolved_height) * 0.5,
		floor_center.z
	)
	lintel.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	)
	lintel.add_to_group("doorway_shadow_lintel")
	var lintel_mesh: BoxMesh = BoxMesh.new()
	lintel_mesh.size = Vector3(
		opening_size.x,
		resolved_height - opening_height,
		opening_size.y
	)
	lintel.mesh = lintel_mesh
	add_child(lintel)


func _add_prop(node_name: String, center: Vector3, dimensions: Vector3, color: Color) -> void:
	var prop: StaticBody3D = StaticBody3D.new()
	prop.name = node_name
	prop.position = center
	prop.add_to_group("nav_source")
	_add_box_visual(prop, dimensions, color)
	_add_box_collision(prop, dimensions)
	add_child(prop)


func _add_visual_prop(node_name: String, center: Vector3, dimensions: Vector3, color: Color) -> void:
	var prop: Node3D = Node3D.new()
	prop.name = node_name
	prop.position = center
	_add_box_visual(prop, dimensions, color)
	add_child(prop)


func _add_crib() -> void:
	var crib: StaticBody3D = StaticBody3D.new()
	crib.name = "CribBlock"
	crib.position = Vector3(-8.7, 0.0, -4.7)
	crib.add_to_group("nav_source")
	for post_x: float in [-1.02, 1.02]:
		for post_z: float in [-1.36, 1.36]:
			_add_box_visual_part(
				crib,
				"Post",
				Vector3(post_x, 0.55, post_z),
				Vector3(0.18, 1.1, 0.18),
				prop_color
			)
	for rail_x: float in [-1.02, 1.02]:
		for rail_y: float in [0.38, 0.82]:
			_add_box_visual_part(
				crib,
				"SideRail",
				Vector3(rail_x, rail_y, 0.0),
				Vector3(0.14, 0.12, 2.55),
				prop_color
			)
	_add_visual_bounds_box_collision(crib)
	add_child(crib)


func _add_couch() -> void:
	var couch: StaticBody3D = StaticBody3D.new()
	couch.name = "Couch"
	couch.position = Vector3(1.55, 0.0, -4.4)
	couch.add_to_group("nav_source")
	_add_box_visual_part(
		couch,
		"Seat",
		Vector3(-0.15, 0.19, 0.0),
		Vector3(1.75, 0.38, 2.65),
		prop_color
	)
	_add_box_visual_part(
		couch,
		"Back",
		Vector3(0.96, 0.68, 0.0),
		Vector3(0.32, 0.92, 3.0),
		prop_color
	)
	for arm_z: float in [-1.37, 1.37]:
		_add_box_visual_part(
			couch,
			"Arm",
			Vector3(-0.08, 0.56, arm_z),
			Vector3(1.78, 0.62, 0.26),
			prop_color
		)
	_add_visual_bounds_box_collision(couch)
	add_child(couch)


func _add_kitchen_bowl() -> void:
	var bowl: Node3D = Node3D.new()
	bowl.name = "KitchenBowl"
	bowl.position = Vector3(5.5, 0.06, -3.05)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "Bowl"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.32
	mesh.bottom_radius = 0.25
	mesh.height = 0.12
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color("#7f8d9c")
	material.roughness = 0.72
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	bowl.add_child(mesh_instance)
	add_child(bowl)


func _add_dog_station() -> void:
	var station: StaticBody3D = StaticBody3D.new()
	station.name = "DogBed"
	station.position = Vector3(5.5, 0.0, -4.75)
	station.add_to_group("nav_source")
	var bed: MeshInstance3D = MeshInstance3D.new()
	bed.name = "RoundBed"
	bed.position.y = 0.14
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 1.05
	mesh.bottom_radius = 1.18
	mesh.height = 0.28
	mesh.radial_segments = 32
	bed.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = prop_color.lightened(0.08)
	material.roughness = 1.0
	bed.material_override = material
	station.add_child(bed)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.position.y = 0.14
	var shape: CylinderShape3D = CylinderShape3D.new()
	shape.radius = 1.18
	shape.height = 0.28
	collision.shape = shape
	station.add_child(collision)
	add_child(station)


func _add_fridge_block() -> void:
	var fridge_body: StaticBody3D = StaticBody3D.new()
	fridge_body.name = "FridgeBlock"
	fridge_body.add_to_group("nav_source")
	# Retain the accepted nav footprint while pulling the visible shell a hair
	# north so the south-face door never intersects it during its sweep.
	_add_box_visual_part(
		fridge_body,
		"Body",
		Vector3(13.75, 1.1, -5.35),
		Vector3(2.4, 2.2, 2.15),
		Color("#9aa5b0")
	)
	_add_visual_bounds_box_collision(fridge_body)
	add_child(fridge_body)


func _add_dining_table() -> void:
	var chair_rows: Array[Dictionary] = [
		{"position": Vector3(-1.35, 0.0, -1.0), "yaw": PI},
		{"position": Vector3(1.35, 0.0, -1.0), "yaw": PI},
		{"position": Vector3(-1.35, 0.0, 1.0), "yaw": 0.0},
		{"position": Vector3(1.35, 0.0, 1.0), "yaw": 0.0},
	]
	_add_table_group(
		"DiningTable",
		Vector3(0.95, 0.0, 0.9),
		Vector3(4.25, 0.16, 1.5),
		chair_rows
	)


func _add_kitchen_table() -> void:
	var chair_rows: Array[Dictionary] = [
		{"position": Vector3(0.0, 0.0, -1.1), "yaw": PI},
		{"position": Vector3(1.15, 0.0, 0.0), "yaw": PI * 0.5},
		{"position": Vector3(0.0, 0.0, 1.1), "yaw": 0.0},
	]
	_add_table_group(
		"KitchenTable",
		Vector3(10.55, 0.0, -1.2),
		Vector3(2.0, 0.16, 1.8),
		chair_rows
	)


func _add_table_group(
	node_name: String,
	center: Vector3,
	top_size: Vector3,
	chair_rows: Array[Dictionary]
) -> void:
	var table: StaticBody3D = StaticBody3D.new()
	table.name = node_name
	table.position = center
	table.add_to_group("nav_source")
	_add_box_visual_part(
		table,
		"Top",
		Vector3(0.0, 0.78, 0.0),
		top_size,
		prop_color
	)
	var leg_x: float = top_size.x * 0.5 - 0.18
	var leg_z: float = top_size.z * 0.5 - 0.18
	for x_position: float in [-leg_x, leg_x]:
		for z_position: float in [-leg_z, leg_z]:
			_add_box_visual_part(
				table,
				"Leg",
				Vector3(x_position, 0.37, z_position),
				Vector3(0.14, 0.74, 0.14),
				prop_color
			)
	for chair_row: Dictionary in chair_rows:
		_add_chair_visual(
			table,
			chair_row["position"] as Vector3,
			float(chair_row["yaw"])
		)
	_add_visual_bounds_box_collision(table)
	add_child(table)


func _add_chair_visual(
	table: Node3D,
	local_position: Vector3,
	yaw: float
) -> void:
	var chair: Node3D = Node3D.new()
	chair.name = "Chair"
	chair.position = local_position
	chair.rotation.y = yaw
	_add_box_visual_part(
		chair,
		"Seat",
		Vector3(0.0, 0.42, 0.0),
		Vector3(0.72, 0.14, 0.62),
		prop_color.lightened(0.06)
	)
	_add_box_visual_part(
		chair,
		"Back",
		Vector3(0.0, 0.72, 0.29),
		Vector3(0.72, 0.68, 0.12),
		prop_color.lightened(0.06)
	)
	table.add_child(chair)


func _add_front_door_side_table() -> void:
	var table: StaticBody3D = StaticBody3D.new()
	table.name = "FrontDoorSideTable"
	table.position = Vector3(9.7, 0.0, 5.85)
	table.add_to_group("nav_source")
	_add_box_visual_part(
		table,
		"Top",
		Vector3(0.0, 0.62, 0.0),
		Vector3(1.0, 0.12, 0.55),
		prop_color
	)
	for x_position: float in [-0.4, 0.4]:
		for z_position: float in [-0.19, 0.19]:
			_add_box_visual_part(
				table,
				"Leg",
				Vector3(x_position, 0.3, z_position),
				Vector3(0.1, 0.6, 0.1),
				prop_color
			)
	_add_visual_bounds_box_collision(table)
	add_child(table)


func _add_toilet() -> void:
	var toilet: StaticBody3D = StaticBody3D.new()
	toilet.name = "BathroomToilet"
	toilet.position = Vector3(-6.45, 0.0, -5.55)
	toilet.add_to_group("nav_source")
	_add_box_visual_part(
		toilet,
		"Tank",
		Vector3(0.0, 0.47, -0.37),
		Vector3(0.78, 0.72, 0.38),
		Color("#aeb8c4")
	)
	var bowl: MeshInstance3D = MeshInstance3D.new()
	bowl.name = "Bowl"
	bowl.position = Vector3(0.0, 0.19, 0.22)
	var bowl_mesh: CylinderMesh = CylinderMesh.new()
	bowl_mesh.top_radius = 0.38
	bowl_mesh.bottom_radius = 0.32
	bowl_mesh.height = 0.38
	bowl.mesh = bowl_mesh
	bowl.material_override = _make_material(Color("#c3ccd6"))
	toilet.add_child(bowl)
	_add_visual_bounds_box_collision(toilet)
	add_child(toilet)


func _add_omni(
	node_name: String,
	zone: String,
	position_value: Vector3,
	energy_scale: float,
	fixture_base_height: float,
	range_override: float = -1.0,
	light_world_position: Vector3 = Vector3.ZERO,
	analytic_floor_position: Vector3 = Vector3.ZERO,
	starts_enabled: bool = true,
	fixture_style: StringName = &"lamp"
) -> void:
	var fixture: Node3D = Node3D.new()
	fixture.name = node_name
	fixture.position = Vector3(position_value.x, 0.0, position_value.z)
	# Ceiling practicals build no fixture visual: playtesters read the glowing
	# discs as floor pickups (2026-07-24 playtest). The light pool is the tell.
	if fixture_style != &"ceiling_disc":
		_add_fixture_visual(fixture, position_value.y, fixture_base_height)

	var light: OmniLight3D = OmniLight3D.new()
	light.name = "Light"
	var resolved_light_position: Vector3 = light_world_position
	if resolved_light_position.is_zero_approx():
		resolved_light_position = Vector3(
			position_value.x,
			omni_source_height,
			position_value.z
		)
	light.position = resolved_light_position - fixture.position
	light.light_color = Color("#d6e1f2")
	light.light_energy = lamp_energy * energy_scale
	var visual_range: float = lamp_range
	var analytic_range: float = (
		range_override if range_override > 0.0 else analytic_light_range
	)
	light.omni_range = visual_range
	light.omni_attenuation = omni_visual_attenuation
	light.shadow_enabled = true
	light.shadow_blur = omni_shadow_blur
	light.shadow_opacity = shadow_opacity
	fixture.add_child(light)
	add_child(fixture)
	fixture.visible = starts_enabled
	var resolved_analytic_position: Vector3 = analytic_floor_position
	if resolved_analytic_position.is_zero_approx():
		resolved_analytic_position = Vector3(
			position_value.x,
			0.0,
			position_value.z
		)
	LightSystem.register_light(
		node_name,
		zone,
		resolved_analytic_position,
		analytic_range,
		starts_enabled
	)


func _add_world_switch(
	node_name: String,
	switch_id: StringName,
	position_value: Vector3,
	target_fixture_name: String,
	starts_on: bool,
	surface_normal: Vector3,
	additional_target_fixture_names: PackedStringArray = PackedStringArray()
) -> void:
	var wall_switch: Node3D = WORLD_SWITCH_SCRIPT.new() as Node3D
	wall_switch.name = node_name
	wall_switch.position = position_value
	wall_switch.set("switch_id", switch_id)
	wall_switch.set("target_light_id", target_fixture_name)
	wall_switch.set(
		"target_fixture_path",
		NodePath("../%s" % target_fixture_name)
	)
	wall_switch.set(
		"additional_target_light_ids",
		additional_target_fixture_names
	)
	var additional_paths: Array[NodePath] = []
	for additional_name: String in additional_target_fixture_names:
		additional_paths.append(NodePath("../%s" % additional_name))
	wall_switch.set("additional_target_fixture_paths", additional_paths)
	wall_switch.set("starts_on", starts_on)
	var mounted_on_x: bool = absf(surface_normal.x) > 0.5
	var plate_size: Vector3 = (
		Vector3(0.12, 0.34, 0.24)
		if mounted_on_x
		else Vector3(0.24, 0.34, 0.12)
	)
	_add_box_visual(wall_switch, plate_size, Color("#8d96a2"))
	var toggle: MeshInstance3D = MeshInstance3D.new()
	toggle.name = "Toggle"
	toggle.position = surface_normal * 0.08
	var tilt: float = -18.0 if starts_on else 18.0
	if mounted_on_x:
		toggle.rotation_degrees.z = tilt * signf(surface_normal.x)
	else:
		toggle.rotation_degrees.x = -tilt * signf(surface_normal.z)
	var toggle_mesh: BoxMesh = BoxMesh.new()
	toggle_mesh.size = (
		Vector3(0.06, 0.17, 0.08)
		if mounted_on_x
		else Vector3(0.08, 0.17, 0.06)
	)
	toggle.mesh = toggle_mesh
	toggle.material_override = _make_material(Color("#dbe3ee"))
	wall_switch.add_child(toggle)
	add_child(wall_switch)


func _add_fixture_visual(
	fixture: Node3D,
	source_height: float,
	base_height: float
) -> void:
	var base_center_y: float = base_height + fixture_base_size.y * 0.5
	_add_fixture_part(
		fixture,
		"Base",
		Vector3(0.0, base_center_y, 0.0),
		fixture_base_size,
		fixture_stand_color,
		false
	)
	var pole_bottom: float = base_height + fixture_base_size.y
	var pole_height: float = maxf(
		source_height - fixture_shade_size.y * 0.5 - pole_bottom,
		0.08
	)
	_add_fixture_part(
		fixture,
		"Pole",
		Vector3(0.0, pole_bottom + pole_height * 0.5, 0.0),
		Vector3(fixture_pole_width, pole_height, fixture_pole_width),
		fixture_stand_color,
		false
	)
	_add_fixture_part(
		fixture,
		"Shade",
		Vector3(0.0, source_height, 0.0),
		fixture_shade_size,
		fixture_glow_color,
		true
	)


func _add_fixture_part(
	parent: Node3D,
	part_name: String,
	local_position: Vector3,
	dimensions: Vector3,
	color: Color,
	emissive: bool
) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = part_name
	mesh_instance.position = local_position
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.75
	if emissive:
		material.emission_enabled = true
		material.emission = fixture_glow_color
		material.emission_energy_multiplier = fixture_emission_energy
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _add_area_glow(
	node_name: String,
	position_value: Vector3,
	rotation_degrees_value: Vector3,
	color: Color,
	energy_scale: float = 0.45
) -> void:
	var glow: AreaLight3D = AreaLight3D.new()
	glow.name = node_name
	glow.position = position_value
	glow.rotation_degrees = rotation_degrees_value
	glow.light_color = color
	glow.light_energy = area_light_energy * energy_scale
	glow.shadow_enabled = false
	add_child(glow)


func _add_box_visual_part(
	parent: Node3D,
	part_name: String,
	local_position: Vector3,
	dimensions: Vector3,
	color: Color
) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = part_name
	mesh_instance.position = local_position
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


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


func _add_box_visual_with_material(
	parent: Node3D,
	dimensions: Vector3,
	material: Material
) -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _make_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	return material


func _add_box_collision(
	parent: Node3D,
	dimensions: Vector3,
	local_position: Vector3 = Vector3.ZERO
) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	collision.position = local_position
	parent.add_child(collision)


func _add_visual_bounds_box_collision(parent: Node3D) -> void:
	var visual_bounds: Array[AABB] = []
	_collect_visual_bounds(parent, Transform3D.IDENTITY, visual_bounds)
	assert(not visual_bounds.is_empty())
	var combined: AABB = visual_bounds[0]
	for bounds_index: int in range(1, visual_bounds.size()):
		combined = combined.merge(visual_bounds[bounds_index])
	_add_box_collision(parent, combined.size, combined.get_center())


func _collect_visual_bounds(
	node: Node3D,
	transform_from_parent: Transform3D,
	result: Array[AABB]
) -> void:
	for child_node: Node in node.get_children():
		if not child_node is Node3D:
			continue
		var child: Node3D = child_node as Node3D
		var child_transform: Transform3D = transform_from_parent * child.transform
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child as MeshInstance3D
			if mesh_instance.mesh != null:
				result.append(child_transform * mesh_instance.get_aabb())
		_collect_visual_bounds(child, child_transform, result)


func _bake_navigation_once() -> void:
	var navigation_region: NavigationRegion3D = $NavigationRegion3D
	navigation_region.bake_navigation_mesh(false)
	var polygon_count: int = navigation_region.navigation_mesh.get_polygon_count()
	assert(polygon_count > 0, "Static navigation bake produced no polygons.")
	print("A0.2 static navmesh baked once: %d polygons." % polygon_count)
