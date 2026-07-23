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


func _ready() -> void:
	surface_height = clampf(surface_height, 0.005, 0.03)
	add_to_group(surface_group)
	add_to_group("nav_source")
	_build_surface()


func _build_surface() -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: PrimitiveMesh
	var shape: Shape3D
	if surface_size.x > 0.0 and surface_size.y > 0.0:
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = Vector3(surface_size.x, surface_height, surface_size.y)
		mesh = box_mesh
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = Vector3(surface_size.x, surface_height, surface_size.y)
		shape = box_shape
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
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = surface_color
	material.roughness = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position.y = surface_height * 0.5
	add_child(mesh_instance)

	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = surface_height * 0.5
	add_child(collision)
