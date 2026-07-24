extends StaticBody3D
class_name NoiseSurface

## Reusable teaching/challenge hazard. Player.gd reads its one surface group;
## loudness_multiplier remains explicit on the prefab for placement review.

@export var loudness_multiplier: float = 3.0
@export var radius: float = 0.7
@export var surface_size: Vector2 = Vector2.ZERO
@export_range(0.005, 0.03, 0.005) var surface_height: float = 0.02
@export var surface_group: StringName = &"surface_creaky"
@export var surface_color: Color = Color("#9BA0A5")

@export_group("Creaky Planks")
@export_range(2, 3, 1) var creaky_plank_count: int = 3
@export var creaky_plank_color_a: Color = Color("#858b92")
@export var creaky_plank_color_b: Color = Color("#7c8289")
@export_range(0.01, 0.08, 0.005) var creaky_plank_seam: float = 0.025


func _ready() -> void:
	surface_height = clampf(surface_height, 0.005, 0.03)
	add_to_group(surface_group)
	add_to_group("nav_source")
	_build_surface()


func _build_surface() -> void:
	var mesh: PrimitiveMesh
	var shape: Shape3D
	if surface_size.x > 0.0 and surface_size.y > 0.0:
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = Vector3(surface_size.x, surface_height, surface_size.y)
		shape = box_shape
		if surface_group == &"surface_creaky":
			_build_creaky_planks()
		elif surface_group == &"surface_toys":
			_build_toy_shapes()
		else:
			var box_mesh: BoxMesh = BoxMesh.new()
			box_mesh.size = Vector3(
				surface_size.x,
				surface_height,
				surface_size.y
			)
			mesh = box_mesh
	else:
		var cylinder_mesh: CylinderMesh = CylinderMesh.new()
		cylinder_mesh.top_radius = radius
		cylinder_mesh.bottom_radius = radius
		cylinder_mesh.height = surface_height
		cylinder_mesh.radial_segments = 20
		mesh = cylinder_mesh
		var cylinder_shape: CylinderShape3D = CylinderShape3D.new()
		cylinder_shape.radius = radius
		cylinder_shape.height = surface_height
		shape = cylinder_shape
	if mesh != null:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _make_surface_material(surface_color)
		mesh_instance.position.y = surface_height * 0.5
		add_child(mesh_instance)

	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = surface_height * 0.5
	add_child(collision)


func _build_toy_shapes() -> void:
	var material: StandardMaterial3D = _make_surface_material(surface_color)
	if name.contains("Dining"):
		_add_toy_box(
			"TrainBody",
			Vector3(-0.18, 0.11, 0.0),
			Vector3(0.72, 0.18, 0.28),
			material
		)
		_add_toy_box(
			"TrainCab",
			Vector3(0.27, 0.18, 0.0),
			Vector3(0.28, 0.32, 0.3),
			material
		)
		_add_toy_box(
			"TrainNose",
			Vector3(-0.55, 0.13, 0.0),
			Vector3(0.22, 0.22, 0.24),
			material
		)
		return
	var pill: MeshInstance3D = MeshInstance3D.new()
	pill.name = "ToyPill"
	pill.position = Vector3(0.0, 0.12, 0.0)
	pill.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	var pill_mesh: CapsuleMesh = CapsuleMesh.new()
	pill_mesh.radius = 0.18
	pill_mesh.height = 0.78
	pill.mesh = pill_mesh
	pill.material_override = material
	add_child(pill)


func _add_toy_box(
	node_name: String,
	local_position: Vector3,
	size: Vector3,
	material: Material
) -> void:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = node_name
	part.position = local_position
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.material_override = material
	add_child(part)


func _build_creaky_planks() -> void:
	var plank_count: int = clampi(creaky_plank_count, 2, 3)
	var total_seam: float = creaky_plank_seam * float(plank_count - 1)
	var plank_depth: float = maxf(
		(surface_size.y - total_seam) / float(plank_count),
		0.05
	)
	var first_center_z: float = (
		-surface_size.y * 0.5 + plank_depth * 0.5
	)
	for plank_index: int in range(plank_count):
		var plank: MeshInstance3D = MeshInstance3D.new()
		plank.name = "Plank%02d" % (plank_index + 1)
		plank.position = Vector3(
			0.0,
			surface_height * 0.5,
			first_center_z
			+ float(plank_index) * (plank_depth + creaky_plank_seam)
		)
		var plank_mesh: BoxMesh = BoxMesh.new()
		plank_mesh.size = Vector3(
			surface_size.x,
			surface_height,
			plank_depth
		)
		plank.mesh = plank_mesh
		var plank_color: Color = (
			creaky_plank_color_a
			if plank_index % 2 == 0
			else creaky_plank_color_b
		)
		plank.material_override = _make_surface_material(plank_color)
		add_child(plank)


func _make_surface_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	return material
