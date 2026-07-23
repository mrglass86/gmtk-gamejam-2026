extends CharacterBody3D
class_name DinnerPlayer

## Player movement, audible footsteps, and the capsule brightness readout.
## LightSystem and NoiseSystem are locked autoload interfaces (brief section 3).

signal snack_carrying_changed(carrying: bool)

@export_group("Movement")
@export var sneak_speed: float = 1.7
@export var run_speed: float = 3.6
@export var sneak_noise_multiplier: float = 0.4
@export var run_noise_multiplier: float = 1.0
@export var gravity: float = 18.0

@export_group("Footsteps")
@export var sneak_footstep_interval: float = 0.35
@export var run_footstep_interval: float = 0.25
@export var carpet_surface_multiplier: float = 0.2
@export var hardwood_surface_multiplier: float = 1.0
@export var creaky_surface_multiplier: float = 3.0
@export var toys_surface_multiplier: float = 4.0
@export_range(0.0, 1.0) var floor_normal_min_y: float = 0.5

@export_group("Snack")
@export var snack_noise_loudness: float = 0.3
@export var snack_noise_interval: float = 0.6

@export_group("Capsule Readout")
@export_node_path("MeshInstance3D") var capsule_mesh_path: NodePath = NodePath("Capsule")
@export var shadow_albedo: Color = Color("29323d")
@export var lit_albedo: Color = Color("2497ff")
@export var shadow_emission: Color = Color("000000")
@export var lit_emission: Color = Color("168cff")
@export var shadow_emission_energy: float = 0.0
@export var lit_emission_energy: float = 2.0

var carrying_snack: bool = false
var input_locked: bool = false

var _footstep_elapsed: float = 0.0
var _snack_noise_elapsed: float = 0.0
var _current_surface_multiplier: float = 1.0
var _capsule_mesh: MeshInstance3D
var _capsule_material: StandardMaterial3D
var _carrier: Node3D
var _carry_offset: Vector3


func _ready() -> void:
	_capsule_mesh = get_node_or_null(capsule_mesh_path) as MeshInstance3D
	_setup_capsule_material()
	_update_capsule_readout()


func _physics_process(delta: float) -> void:
	if _carrier != null:
		velocity = Vector3.ZERO
		global_position = _carrier.to_global(_carry_offset)
		_emit_snack_noise(delta)
		_update_capsule_readout()
		return
	_apply_movement(delta)
	move_and_slide()
	_update_surface_multiplier()
	_emit_footsteps(delta)
	_emit_snack_noise(delta)
	_update_capsule_readout()


func set_input_locked(locked: bool) -> void:
	input_locked = locked
	if locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_footstep_elapsed = 0.0


func attach_to_carrier(carrier: Node3D, carry_offset: Vector3) -> void:
	_carrier = carrier
	_carry_offset = carry_offset
	set_input_locked(true)
	velocity = Vector3.ZERO
	global_position = _carrier.to_global(_carry_offset)


func detach_from_carrier(drop_position: Vector3) -> void:
	_carrier = null
	global_position = drop_position
	velocity = Vector3.ZERO
	set_input_locked(false)


func set_carrying_snack(carrying: bool) -> void:
	if carrying_snack == carrying:
		return
	carrying_snack = carrying
	_snack_noise_elapsed = 0.0
	snack_carrying_changed.emit(carrying_snack)


func _apply_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if input_locked:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var input_direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var movement_direction: Vector3 = Vector3(input_direction.x, 0.0, input_direction.y)
	var speed: float = _get_move_speed()
	velocity.x = movement_direction.x * speed
	velocity.z = movement_direction.z * speed
	if movement_direction.length_squared() > 0.0:
		look_at(global_position + movement_direction, Vector3.UP, true)


func _get_move_speed() -> float:
	if input_locked:
		return 0.0
	var has_movement_input: bool = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	).length_squared() > 0.0
	if not has_movement_input:
		return 0.0
	return run_speed if Input.is_action_pressed("run") else sneak_speed


func _get_noise_multiplier() -> float:
	if _get_move_speed() <= 0.0:
		return 0.0
	return run_noise_multiplier if Input.is_action_pressed("run") else sneak_noise_multiplier


func _emit_footsteps(delta: float) -> void:
	var noise_multiplier: float = _get_noise_multiplier()
	var real_velocity: Vector3 = get_real_velocity()
	var horizontal_speed: float = Vector2(real_velocity.x, real_velocity.z).length()
	if noise_multiplier <= 0.0 or horizontal_speed <= 0.0:
		_footstep_elapsed = 0.0
		return

	_footstep_elapsed += delta
	var interval: float = run_footstep_interval if Input.is_action_pressed("run") else sneak_footstep_interval
	if _footstep_elapsed < interval:
		return

	_footstep_elapsed = fmod(_footstep_elapsed, interval)
	var raw_loudness: float = noise_multiplier * _current_surface_multiplier
	_emit_masked_noise(raw_loudness)


func _emit_snack_noise(delta: float) -> void:
	if not carrying_snack:
		_snack_noise_elapsed = 0.0
		return

	_snack_noise_elapsed += delta
	if _snack_noise_elapsed < snack_noise_interval:
		return

	_snack_noise_elapsed = fmod(_snack_noise_elapsed, snack_noise_interval)
	_emit_masked_noise(snack_noise_loudness)


func _emit_masked_noise(raw_loudness: float) -> void:
	var mask: float = clampf(NoiseSystem.get_mask_at(global_position), 0.0, 1.0)
	var loudness: float = raw_loudness * (1.0 - mask)
	if loudness > 0.0:
		NoiseSystem.emit_noise(global_position, loudness, self)


func _update_surface_multiplier() -> void:
	_current_surface_multiplier = hardwood_surface_multiplier
	var collision_count: int = get_slide_collision_count()
	for collision_index in range(collision_count):
		var collision: KinematicCollision3D = get_slide_collision(collision_index)
		if collision.get_normal().dot(Vector3.UP) < floor_normal_min_y:
			continue
		var collider: Object = collision.get_collider()
		var collider_node: Node = collider as Node
		if collider_node != null:
			_current_surface_multiplier = _get_surface_multiplier(collider_node)
			return


func _get_surface_multiplier(collider: Node) -> float:
	if collider.is_in_group("surface_toys"):
		return toys_surface_multiplier
	if collider.is_in_group("surface_creaky"):
		return creaky_surface_multiplier
	if collider.is_in_group("surface_carpet"):
		return carpet_surface_multiplier
	if collider.is_in_group("surface_hardwood"):
		return hardwood_surface_multiplier
	return hardwood_surface_multiplier


func _setup_capsule_material() -> void:
	if _capsule_mesh == null:
		return

	var source_material: Material = _capsule_mesh.material_override
	if source_material == null and _capsule_mesh.mesh != null and _capsule_mesh.mesh.get_surface_count() > 0:
		source_material = _capsule_mesh.mesh.surface_get_material(0)
	if source_material is StandardMaterial3D:
		_capsule_material = source_material.duplicate() as StandardMaterial3D
	else:
		_capsule_material = StandardMaterial3D.new()
	_capsule_material.emission_enabled = true
	_capsule_mesh.material_override = _capsule_material


func _update_capsule_readout() -> void:
	if _capsule_material == null:
		return
	var brightness: float = clampf(LightSystem.get_brightness_at(global_position), 0.0, 1.0)
	_capsule_material.albedo_color = shadow_albedo.lerp(lit_albedo, brightness)
	_capsule_material.emission = shadow_emission.lerp(lit_emission, brightness)
	_capsule_material.emission_energy_multiplier = lerpf(
		shadow_emission_energy, lit_emission_energy, brightness
	)
