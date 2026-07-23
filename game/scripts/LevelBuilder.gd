extends Node3D

## A0 procedural greybox. It uses only primitive meshes and builds static
## collision for the authored floor and walls; NavigationRegion3D owns the
## matching pre-authored static navmesh in Main.tscn.

@export var wall_height: float = 1.2
@export var wall_thickness: float = 0.25
@export var floor_thickness: float = 0.2
@export var prop_height: float = 0.8
@export var lamp_energy: float = 2.0
@export var lamp_range: float = 7.0

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
	if _is_layout_capture():
		_add_review_labels()


func _build_floors() -> void:
	_add_floor("BedroomCarpet", Vector3(-10.5, 0.0, 0.0), Vector2(7.0, 8.0), carpet_color, "surface_carpet")
	_add_floor("HallCarpet", Vector3(0.5, 0.0, 6.0), Vector2(15.0, 5.5), carpet_color, "surface_carpet")
	_add_floor("KitchenCarpet", Vector3(11.0, 0.0, 0.0), Vector2(6.0, 8.0), carpet_color, "surface_carpet")
	_add_floor("DiningHardwood", Vector3(1.0, 0.0, -1.5), Vector2(14.0, 9.0), hardwood_color, "surface_hardwood")
	_add_floor("LivingHardwood", Vector3(0.0, 0.0, -7.5), Vector2(8.0, 3.0), hardwood_color, "surface_hardwood")
	_add_floor("CreakyTeacher", Vector3(-7.0, 0.02, 4.7), Vector2(1.4, 1.0), creaky_color, "surface_creaky")
	_add_floor("DiningCreak", Vector3(-2.0, 0.02, -2.0), Vector2(1.4, 1.0), creaky_color, "surface_creaky")
	_add_floor("ToyPatch", Vector3(2.0, 0.02, -2.5), Vector2(1.8, 1.8), toy_color, "surface_toys")


func _build_walls() -> void:
	_add_wall("NorthWall", Vector3(0.0, wall_height * 0.5, 9.0), Vector3(30.0, wall_height, wall_thickness))
	_add_wall("SouthWall", Vector3(0.0, wall_height * 0.5, -9.0), Vector3(30.0, wall_height, wall_thickness))
	_add_wall("WestWall", Vector3(-15.0, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, 18.0))
	_add_wall("EastWall", Vector3(15.0, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, 18.0))
	_add_wall("BedroomNorth", Vector3(-10.8, wall_height * 0.5, 4.0), Vector3(6.2, wall_height, wall_thickness))
	_add_wall("BedroomDiningWest", Vector3(-7.0, wall_height * 0.5, -2.2), Vector3(wall_thickness, wall_height, 3.6))
	_add_wall("BedroomDiningEast", Vector3(-7.0, wall_height * 0.5, 1.2), Vector3(wall_thickness, wall_height, 3.6))
	_add_wall("LivingWest", Vector3(-5.0, wall_height * 0.5, -6.0), Vector3(2.0, wall_height, wall_thickness))
	_add_wall("LivingEast", Vector3(6.0, wall_height * 0.5, -6.0), Vector3(4.0, wall_height, wall_thickness))
	_add_wall("KitchenCounterWall", Vector3(8.7, wall_height * 0.5, 0.0), Vector3(0.7, wall_height, 4.5))


func _build_props() -> void:
	_add_prop("Bed", Vector3(-11.5, prop_height * 0.5, -1.5), Vector3(2.4, prop_height, 3.2), prop_color)
	_add_prop("Nightstand", Vector3(-9.0, prop_height * 0.4, -2.0), Vector3(0.8, prop_height * 0.8, 0.8), prop_color)
	_add_prop("Sofa", Vector3(0.5, prop_height * 0.5, -7.3), Vector3(3.4, prop_height, 1.3), prop_color)
	_add_prop("DiningTable", Vector3(-1.8, prop_height * 0.5, -2.5), Vector3(2.0, prop_height, 1.3), prop_color)
	_add_prop("KitchenCounter", Vector3(11.2, prop_height * 0.5, 2.1), Vector3(3.8, prop_height, 0.9), prop_color)
	_add_prop("TVScreen", Vector3(2.7, 1.25, -8.1), Vector3(1.8, 1.2, 0.2), Color("#627b92"))
	_add_prop("FridgeBlock", Vector3(13.2, 1.1, -2.3), Vector3(1.2, 2.2, 1.2), Color("#9aa5b0"))
	_add_prop("PantryBlock", Vector3(9.2, 1.0, 2.8), Vector3(1.1, 2.0, 1.1), Color("#7d838a"))


func _build_lights() -> void:
	_add_omni("BedroomLampVisual", "bedroom", Vector3(-10.0, 4.0, 0.5), 0.85)
	_add_omni("HallLampVisual", "hall", Vector3(0.5, 4.0, 6.0), 1.0)
	_add_omni("LivingLampVisual", "living", Vector3(1.5, 4.0, -7.0), 0.9)
	_add_omni("KitchenLampVisual", "kitchen", Vector3(11.0, 4.0, 0.0), 1.0)
	_add_area_glow("TVGlow", Vector3(2.5, 1.3, -7.7), Vector3(-90.0, 0.0, 0.0), Color("#7ea5d8"))
	_add_area_glow("WindowGlow", Vector3(-13.8, 2.4, 1.5), Vector3(0.0, 90.0, 0.0), Color("#c7d5e7"))
	_add_area_glow("DoorStripGlow", Vector3(-7.1, 0.55, 3.75), Vector3(-90.0, 0.0, 0.0), Color("#d5dce8"))


func _is_layout_capture() -> bool:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-layout="):
			return true
	return false


func _add_review_labels() -> void:
	_add_review_label("BEDROOM", Vector3(-10.5, 0.3, 2.6))
	_add_review_label("HALL — CARPET", Vector3(0.5, 0.3, 6.4))
	_add_review_label("DINING — CREAK + TOYS", Vector3(1.0, 0.3, -4.2))
	_add_review_label("LIVING", Vector3(0.0, 0.3, -7.8))
	_add_review_label("KITCHEN", Vector3(11.0, 0.3, 1.1))


func _add_review_label(label_text: String, position_value: Vector3) -> void:
	var label: Label3D = Label3D.new()
	label.text = label_text
	label.position = position_value
	label.font_size = 52
	label.outline_size = 8
	label.pixel_size = 0.016
	label.modulate = Color("#e5e9ee")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	add_child(label)


func _add_floor(node_name: String, center: Vector3, dimensions: Vector2, color: Color, surface_group: String) -> void:
	var floor: StaticBody3D = StaticBody3D.new()
	floor.name = node_name
	floor.position = center + Vector3(0.0, -floor_thickness * 0.5, 0.0)
	floor.add_to_group(surface_group)
	_add_box_visual(floor, Vector3(dimensions.x, floor_thickness, dimensions.y), color)
	_add_box_collision(floor, Vector3(dimensions.x, floor_thickness, dimensions.y))
	add_child(floor)


func _add_wall(node_name: String, center: Vector3, dimensions: Vector3) -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	wall.name = node_name
	wall.position = center
	_add_box_visual(wall, dimensions, wall_color)
	_add_box_collision(wall, dimensions)
	add_child(wall)


func _add_prop(node_name: String, center: Vector3, dimensions: Vector3, color: Color) -> void:
	var prop: StaticBody3D = StaticBody3D.new()
	prop.name = node_name
	prop.position = center
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
