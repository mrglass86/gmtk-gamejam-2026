extends StaticBody3D
class_name NoiseSurface

## Reusable teaching/challenge hazard. Player.gd reads its one surface group;
## loudness_multiplier remains explicit on the prefab for placement review.

@export var loudness_multiplier: float = 3.0
@export var radius: float = 0.7
@export var surface_height: float = 0.12
@export var surface_group: StringName = &"surface_creaky"
@export var surface_color: Color = Color("#9BA0A5")


func _ready() -> void:
	add_to_group(surface_group)
	add_to_group("nav_source")
	_build_surface()


func _build_surface() -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = surface_height
	mesh.radial_segments = 20
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = surface_color
	material.roughness = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	add_child(mesh_instance)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: CylinderShape3D = CylinderShape3D.new()
	shape.radius = radius
	shape.height = surface_height
	collision.shape = shape
	add_child(collision)
