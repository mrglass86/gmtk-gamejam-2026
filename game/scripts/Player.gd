extends CharacterBody3D
class_name DinnerPlayer

## Player movement, audible footsteps, and the capsule brightness readout.
## LightSystem and NoiseSystem are locked autoload interfaces (brief section 3).

signal snack_carrying_changed(carrying: bool)
signal idle_giggled(giggle_position: Vector3)

const INTERACTION_TIE_EPSILON: float = 0.001

@export_group("Movement")
@export var sneak_speed: float = 1.7
@export var run_speed: float = 3.6
@export var sneak_noise_multiplier: float = 0.2
@export var run_noise_multiplier: float = 1.2
@export var gravity: float = 18.0

@export_group("Footsteps")
@export var sneak_footstep_interval: float = 0.35
@export var run_footstep_interval: float = 0.25
@export var carpet_surface_multiplier: float = 0.2
@export var hardwood_surface_multiplier: float = 1.0
@export var creaky_surface_multiplier: float = 3.0
@export var toys_surface_multiplier: float = 4.0
## Trap surfaces fire at full volume no matter how carefully they are stepped
## on (2026-07-24 ruling). Both floors sit above Parent's 3.0 stomp-summon
## threshold; carpet and hardwood keep their gait scaling.
@export var creaky_trap_floor: float = 3.2
@export var toys_trap_floor: float = 4.0
@export_range(0.0, 1.0) var floor_normal_min_y: float = 0.5
## NoiseSurface overlays moved to their own physics layer so vision rays
## ignore them; the player must still ride and slide-detect them, so this
## is OR-ed into the body's scene collision mask at ready.
@export_flags_3d_physics var floor_detail_collision_mask: int = 2

@export_group("Movement Texture")
@export var sneak_hop_height: float = 0.06
@export var run_hop_height: float = 0.10
@export_range(0.0, 1.0) var landing_squash_amount: float = 0.08
@export_range(0.0, 1.0) var landing_spread_amount: float = 0.04
@export_range(0.0, 1.0) var landing_spring_overshoot: float = 0.035
@export_range(0.01, 1.0) var landing_recovery_fraction: float = 0.35
@export var run_forward_lean_degrees: float = 8.0

@export_group("Snack")
@export var snack_noise_loudness: float = 0.3
@export var snack_noise_interval: float = 0.6

@export_group("Idle Giggle")
@export_node_path("DinnerGameFlow") var game_flow_path: NodePath = NodePath(
	"../GameFlow"
)
@export var idle_giggle_min_interval: float = 20.0
@export var idle_giggle_max_interval: float = 45.0
@export var idle_giggle_loudness: float = 0.5
@export var idle_giggle_random_seed: int = 0

@export_group("B16 Runtime Verification")
@export var verify_b16_time_scale: float = 20.0
@export var verify_b16_physics_ticks_per_second: int = 1200
@export var verify_b16_warmup_frames: int = 12
@export var verify_b16_max_physics_frames: int = 6000
@export var verify_b16_short_interval: float = 0.5
@export var verify_b16_suppression_duration: float = 1.0
@export var verify_b16_clock_tolerance: float = 0.75
@export var verify_b16_ring_tolerance: float = 0.01

@export_group("B19 Runtime Verification")
@export var verify_b19_hardwood_position: Vector3 = Vector3(-11.1, 0.6, 3.95)
@export var verify_b19_creaky_position: Vector3 = Vector3(6.2, 0.6, 0.0)
@export var verify_b19_toys_position: Vector3 = Vector3(-2.6, 0.6, 2.4)
@export var verify_b19_loudness_tolerance: float = 0.03
@export var verify_b19_sample_timeout: float = 1.0

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
var _idle_giggle_elapsed: float = 0.0
var _idle_giggle_interval: float = 0.0
var _idle_giggle_emitting: bool = false
var _idle_giggle_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _game_flow: DinnerGameFlow
var _current_surface_multiplier: float = 1.0
var _current_surface_kind: StringName = &"hardwood"
var _capsule_mesh: MeshInstance3D
var _capsule_material: StandardMaterial3D
var _capsule_base_position: Vector3
var _capsule_base_scale: Vector3 = Vector3.ONE
var _capsule_base_rotation: Vector3
var _step_cycle_has_landed: bool = false
var _carrier: Node3D
var _carry_offset: Vector3
var _verify_b16_noise_count: int = 0
var _verify_b16_signal_count: int = 0
var _verify_b16_last_loudness: float = 0.0
var _verify_b16_last_position: Vector3
var _verify_b19_noise_count: int = 0
var _verify_b19_last_loudness: float = -1.0
var _verify_b19_last_surface_multiplier: float = -1.0


func _ready() -> void:
	collision_mask = collision_mask | floor_detail_collision_mask
	_game_flow = get_node_or_null(game_flow_path) as DinnerGameFlow
	if idle_giggle_random_seed == 0:
		_idle_giggle_rng.randomize()
	else:
		_idle_giggle_rng.seed = idle_giggle_random_seed
	_schedule_next_idle_giggle()
	_capsule_mesh = get_node_or_null(capsule_mesh_path) as MeshInstance3D
	if _capsule_mesh != null:
		_capsule_base_position = _capsule_mesh.position
		_capsule_base_scale = _capsule_mesh.scale
		_capsule_base_rotation = _capsule_mesh.rotation
	_setup_capsule_material()
	_update_capsule_readout()
	if OS.get_cmdline_user_args().has("--verify-b16"):
		_run_b16_live_verification.call_deferred()
	if OS.get_cmdline_user_args().has("--verify-b19"):
		_run_b19_live_verification.call_deferred()


func _physics_process(delta: float) -> void:
	_update_idle_giggle(delta)
	if _carrier != null:
		velocity = Vector3.ZERO
		global_position = _carrier.to_global(_carry_offset)
		_reset_movement_texture()
		_emit_snack_noise(delta)
		_update_capsule_readout()
		return
	_apply_movement(delta)
	move_and_slide()
	_update_surface_multiplier()
	_emit_footsteps(delta)
	_update_movement_texture()
	_emit_snack_noise(delta)
	_update_capsule_readout()


func set_input_locked(locked: bool) -> void:
	input_locked = locked
	if locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_footstep_elapsed = 0.0
		_reset_movement_texture()


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


func is_attached_to_carrier() -> bool:
	return _carrier != null


func set_carrying_snack(carrying: bool) -> void:
	if carrying_snack == carrying:
		return
	carrying_snack = carrying
	_snack_noise_elapsed = 0.0
	snack_carrying_changed.emit(carrying_snack)


func get_nearest_interactable() -> Node3D:
	if input_locked:
		return null
	var best: Node3D
	var best_distance: float = INF
	var best_priority: int = -1
	for candidate: Node in get_tree().get_nodes_in_group("interactable"):
		var interactable: Node3D = candidate as Node3D
		if interactable == null:
			continue
		var radius: float = float(interactable.get("interaction_radius"))
		var distance: float = global_position.distance_to(
			interactable.global_position
		)
		if distance > radius:
			continue
		var priority: int = 1 if interactable is DinnerDoor else 0
		if (
			distance < best_distance - INTERACTION_TIE_EPSILON
			or (
				absf(distance - best_distance) <= INTERACTION_TIE_EPSILON
				and priority > best_priority
			)
		):
			best = interactable
			best_distance = distance
			best_priority = priority
	return best


func is_interaction_target(candidate: Node3D) -> bool:
	return candidate != null and get_nearest_interactable() == candidate


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
		_step_cycle_has_landed = false
		return

	var interval: float = run_footstep_interval if Input.is_action_pressed("run") else sneak_footstep_interval
	if interval <= 0.0:
		_footstep_elapsed = 0.0
		_step_cycle_has_landed = false
		return

	_footstep_elapsed += delta
	if _footstep_elapsed < interval:
		return

	_footstep_elapsed = fmod(_footstep_elapsed, interval)
	_step_cycle_has_landed = true
	var raw_loudness: float = maxf(
		noise_multiplier * _current_surface_multiplier,
		_get_trap_loudness_floor()
	)
	_emit_masked_noise(raw_loudness)


func _update_movement_texture() -> void:
	if _capsule_mesh == null:
		return
	var real_velocity: Vector3 = get_real_velocity()
	var horizontal_speed_squared: float = Vector2(real_velocity.x, real_velocity.z).length_squared()
	if input_locked or is_zero_approx(horizontal_speed_squared):
		_reset_movement_texture()
		return

	var is_running: bool = Input.is_action_pressed("run")
	var interval: float = run_footstep_interval if is_running else sneak_footstep_interval
	if interval <= 0.0:
		_reset_movement_texture()
		return

	var step_phase: float = clampf(_footstep_elapsed / interval, 0.0, 1.0)
	var hop_height: float = run_hop_height if is_running else sneak_hop_height
	_capsule_mesh.position = _capsule_base_position + Vector3.UP * sin(step_phase * PI) * hop_height

	var vertical_scale: float = 1.0
	var horizontal_scale: float = 1.0
	if _step_cycle_has_landed and step_phase < landing_recovery_fraction:
		var recovery_phase: float = clampf(
			step_phase / maxf(landing_recovery_fraction, 0.01),
			0.0,
			1.0
		)
		var compression_weight: float = 1.0 - recovery_phase
		var spring_weight: float = sin(recovery_phase * PI)
		vertical_scale = (
			1.0
			- landing_squash_amount * compression_weight
			+ landing_spring_overshoot * spring_weight
		)
		horizontal_scale = (
			1.0
			+ landing_spread_amount * compression_weight
			- landing_spring_overshoot * spring_weight
		)

	_capsule_mesh.scale = Vector3(
		_capsule_base_scale.x * horizontal_scale,
		_capsule_base_scale.y * vertical_scale,
		_capsule_base_scale.z * horizontal_scale
	)
	_capsule_mesh.rotation = _capsule_base_rotation
	if is_running:
		_capsule_mesh.rotation.x += deg_to_rad(run_forward_lean_degrees)


func _reset_movement_texture() -> void:
	_step_cycle_has_landed = false
	if _capsule_mesh == null:
		return
	_capsule_mesh.position = _capsule_base_position
	_capsule_mesh.scale = _capsule_base_scale
	_capsule_mesh.rotation = _capsule_base_rotation


func _emit_snack_noise(delta: float) -> void:
	if not carrying_snack:
		_snack_noise_elapsed = 0.0
		return

	_snack_noise_elapsed += delta
	if _snack_noise_elapsed < snack_noise_interval:
		return

	_snack_noise_elapsed = fmod(_snack_noise_elapsed, snack_noise_interval)
	_emit_masked_noise(snack_noise_loudness)


func _update_idle_giggle(delta: float) -> void:
	if not _can_idle_giggle():
		return
	_idle_giggle_elapsed += delta
	if _idle_giggle_elapsed < _idle_giggle_interval:
		return
	_emit_idle_giggle()
	_schedule_next_idle_giggle()


func _can_idle_giggle() -> bool:
	return (
		_carrier == null
		and not input_locked
		and GameClock.running
		and (
			_game_flow == null
			or _game_flow.state == DinnerGameFlow.State.PLAYING
		)
	)


func _schedule_next_idle_giggle() -> void:
	_idle_giggle_elapsed = 0.0
	var minimum_interval: float = maxf(
		minf(idle_giggle_min_interval, idle_giggle_max_interval),
		0.0
	)
	var maximum_interval: float = maxf(
		maxf(idle_giggle_min_interval, idle_giggle_max_interval),
		minimum_interval
	)
	_idle_giggle_interval = _idle_giggle_rng.randf_range(
		minimum_interval,
		maximum_interval
	)


func _emit_idle_giggle() -> void:
	if not _can_idle_giggle():
		return
	_idle_giggle_emitting = true
	idle_giggled.emit(global_position)
	# B16 is a fixed tell: its analytical ring remains an honest ~4 m even
	# inside an ambient mask.
	NoiseSystem.emit_noise(global_position, idle_giggle_loudness, self)
	_idle_giggle_emitting = false


func is_emitting_idle_giggle() -> bool:
	return _idle_giggle_emitting


func _emit_masked_noise(raw_loudness: float) -> void:
	var mask: float = clampf(NoiseSystem.get_mask_at(global_position), 0.0, 1.0)
	var loudness: float = raw_loudness * (1.0 - mask)
	if loudness > 0.0:
		NoiseSystem.emit_noise(global_position, loudness, self)


func _update_surface_multiplier() -> void:
	_current_surface_multiplier = hardwood_surface_multiplier
	_current_surface_kind = &"hardwood"
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
		_current_surface_kind = &"toys"
		return toys_surface_multiplier
	if collider.is_in_group("surface_creaky"):
		_current_surface_kind = &"creaky"
		return creaky_surface_multiplier
	if collider.is_in_group("surface_carpet"):
		_current_surface_kind = &"carpet"
		return carpet_surface_multiplier
	_current_surface_kind = &"hardwood"
	if collider.is_in_group("surface_hardwood"):
		return hardwood_surface_multiplier
	return hardwood_surface_multiplier


func _get_trap_loudness_floor() -> float:
	match _current_surface_kind:
		&"toys":
			return toys_trap_floor
		&"creaky":
			return creaky_trap_floor
	return 0.0


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


func _run_b16_live_verification() -> void:
	var parent_actor: DinnerParent = (
		get_parent().get_node_or_null("Parent") as DinnerParent
	)
	var pet_actor: DinnerPet = get_parent().get_node_or_null("Pet") as DinnerPet
	var indicator_manager: Node3D = (
		get_parent().get_node_or_null("NoiseIndicatorManager") as Node3D
	)
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var original_min_interval: float = idle_giggle_min_interval
	var original_max_interval: float = idle_giggle_max_interval
	var original_game_state: DinnerGameFlow.State = (
		_game_flow.state
		if _game_flow != null
		else DinnerGameFlow.State.PLAYING
	)
	var original_clock_running: bool = GameClock.running
	var original_clock_remaining: float = GameClock.time_remaining
	var original_clock_phase: int = GameClock.phase
	var original_input_locked: bool = input_locked
	var original_carrying_snack: bool = carrying_snack
	var original_position: Vector3 = global_position
	var parent_was_processing: bool = (
		parent_actor != null and parent_actor.is_physics_processing()
	)
	var pet_was_processing: bool = (
		pet_actor != null and pet_actor.is_physics_processing()
	)
	var scheduled_default_interval: float = _idle_giggle_interval
	var temporary_carrier: Node3D = Node3D.new()
	temporary_carrier.name = "B16VerifyCarrier"
	get_parent().add_child(temporary_carrier)
	temporary_carrier.global_position = global_position

	Engine.time_scale = maxf(verify_b16_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(
		verify_b16_physics_ticks_per_second,
		60
	)
	if parent_actor != null:
		parent_actor.set_physics_process(false)
	if pet_actor != null:
		pet_actor.set_physics_process(false)
	set_carrying_snack(false)
	if is_attached_to_carrier():
		detach_from_carrier(original_position)
	set_input_locked(false)
	if _game_flow != null:
		_game_flow.state = DinnerGameFlow.State.PLAYING
	_verify_b16_noise_count = 0
	_verify_b16_signal_count = 0
	_verify_b16_last_loudness = 0.0
	_verify_b16_last_position = Vector3.ZERO
	if not NoiseSystem.noise_emitted.is_connected(_capture_b16_noise):
		NoiseSystem.noise_emitted.connect(_capture_b16_noise)
	if not idle_giggled.is_connected(_capture_b16_signal):
		idle_giggled.connect(_capture_b16_signal)
	for _frame_index in range(verify_b16_warmup_frames):
		await get_tree().physics_frame

	var baseline_indicator_count: int = (
		indicator_manager.get_child_count()
		if indicator_manager != null
		else 0
	)
	GameClock.start()
	_idle_giggle_elapsed = 0.0
	var first_giggle_elapsed: float = 0.0
	for _frame_index in range(verify_b16_max_physics_frames):
		await get_tree().physics_frame
		first_giggle_elapsed = _get_b16_clock_elapsed()
		if _verify_b16_signal_count >= 1 and _verify_b16_noise_count >= 1:
			break

	var free_roam_emitted: bool = (
		_verify_b16_signal_count == 1
		and _verify_b16_noise_count == 1
		and is_equal_approx(
			_verify_b16_last_loudness,
			idle_giggle_loudness
		)
		and _verify_b16_last_position.is_equal_approx(global_position)
	)
	var default_interval_live: bool = (
		scheduled_default_interval >= minf(
			original_min_interval,
			original_max_interval
		)
		and scheduled_default_interval <= maxf(
			original_min_interval,
			original_max_interval
		)
		and absf(first_giggle_elapsed - scheduled_default_interval)
		<= verify_b16_clock_tolerance
	)
	var ring_radius: float = -1.0
	var ring_magenta: bool = false
	if (
		indicator_manager != null
		and indicator_manager.get_child_count() > baseline_indicator_count
	):
		var indicator: NoiseIndicator = indicator_manager.get_child(
			indicator_manager.get_child_count() - 1
		) as NoiseIndicator
		if indicator != null:
			ring_radius = indicator.max_radius
			var icon: Sprite3D = indicator.get("_icon") as Sprite3D
			if icon != null:
				var expected_magenta: Color = Color("#FF2D95")
				ring_magenta = (
					is_equal_approx(icon.modulate.r, expected_magenta.r)
					and is_equal_approx(icon.modulate.g, expected_magenta.g)
					and is_equal_approx(icon.modulate.b, expected_magenta.b)
				)
	var ring_honest: bool = (
		absf(ring_radius - idle_giggle_loudness * 8.0)
		<= verify_b16_ring_tolerance
		and ring_magenta
	)

	idle_giggle_min_interval = verify_b16_short_interval
	idle_giggle_max_interval = verify_b16_short_interval
	var count_before_carried: int = _verify_b16_signal_count
	attach_to_carrier(temporary_carrier, Vector3.ZERO)
	set_input_locked(false)
	_schedule_next_idle_giggle()
	GameClock.start()
	await _wait_b16_clock_duration(verify_b16_suppression_duration)
	var carried_suppressed: bool = (
		_verify_b16_signal_count == count_before_carried
		and _verify_b16_noise_count == count_before_carried
	)

	detach_from_carrier(original_position)
	set_input_locked(false)
	var count_before_won: int = _verify_b16_signal_count
	if _game_flow != null:
		_game_flow.state = DinnerGameFlow.State.WON
	_schedule_next_idle_giggle()
	GameClock.start()
	await _wait_b16_clock_duration(verify_b16_suppression_duration)
	var won_suppressed: bool = (
		_verify_b16_signal_count == count_before_won
		and _verify_b16_noise_count == count_before_won
	)

	var count_before_lost: int = _verify_b16_signal_count
	if _game_flow != null:
		_game_flow.state = DinnerGameFlow.State.LOST
	_schedule_next_idle_giggle()
	GameClock.start()
	await _wait_b16_clock_duration(verify_b16_suppression_duration)
	var lost_suppressed: bool = (
		_verify_b16_signal_count == count_before_lost
		and _verify_b16_noise_count == count_before_lost
	)

	var count_before_resume: int = _verify_b16_signal_count
	if _game_flow != null:
		_game_flow.state = DinnerGameFlow.State.PLAYING
	set_input_locked(false)
	_schedule_next_idle_giggle()
	GameClock.start()
	await _wait_b16_clock_duration(
		verify_b16_short_interval + 0.2
	)
	var resumed_in_play: bool = (
		_verify_b16_signal_count == count_before_resume + 1
		and _verify_b16_noise_count == count_before_resume + 1
	)

	var verification_passed: bool = (
		free_roam_emitted
		and default_interval_live
		and ring_honest
		and carried_suppressed
		and won_suppressed
		and lost_suppressed
		and resumed_in_play
	)

	if NoiseSystem.noise_emitted.is_connected(_capture_b16_noise):
		NoiseSystem.noise_emitted.disconnect(_capture_b16_noise)
	if idle_giggled.is_connected(_capture_b16_signal):
		idle_giggled.disconnect(_capture_b16_signal)
	idle_giggle_min_interval = original_min_interval
	idle_giggle_max_interval = original_max_interval
	if is_attached_to_carrier():
		detach_from_carrier(original_position)
	global_position = original_position
	set_carrying_snack(original_carrying_snack)
	set_input_locked(original_input_locked)
	if _game_flow != null:
		_game_flow.state = original_game_state
	GameClock.running = original_clock_running
	GameClock.time_remaining = original_clock_remaining
	GameClock.phase = original_clock_phase
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if parent_actor != null:
		parent_actor.set_physics_process(parent_was_processing)
	if pet_actor != null:
		pet_actor.set_physics_process(pet_was_processing)
	temporary_carrier.queue_free()

	print(
		(
			"B16 live metrics: scheduled=%.2f s, emitted=%.2f s, "
			+ "loudness=%.2f, ring=%.2f m, magenta=%s; "
			+ "carried/won/lost suppressed=%s/%s/%s, resumed=%s."
		)
		% [
			scheduled_default_interval,
			first_giggle_elapsed,
			_verify_b16_last_loudness,
			ring_radius,
			ring_magenta,
			carried_suppressed,
			won_suppressed,
			lost_suppressed,
			resumed_in_play,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(
		free_roam_emitted and default_interval_live,
		"B16 free-roam giggle missed its live randomized interval."
	)
	assert(ring_honest, "B16 giggle did not render an honest 4 m magenta tell.")
	assert(carried_suppressed, "B16 giggled while the player was carried.")
	assert(
		won_suppressed and lost_suppressed,
		"B16 giggled during a result screen."
	)
	assert(resumed_in_play, "B16 giggle did not resume during free play.")
	print("B16 live SceneTree verification passed.")


func _run_b19_live_verification() -> void:
	var parent_actor: DinnerParent = (
		get_parent().get_node_or_null("Parent") as DinnerParent
	)
	var pet_actor: DinnerPet = (
		get_parent().get_node_or_null("Pet") as DinnerPet
	)
	var indicator_manager: Node3D = (
		get_parent().get_node_or_null("NoiseIndicatorManager") as Node3D
	)
	var original_time_scale: float = Engine.time_scale
	var original_physics_ticks: int = Engine.physics_ticks_per_second
	var original_game_state: DinnerGameFlow.State = (
		_game_flow.state
		if _game_flow != null
		else DinnerGameFlow.State.PLAYING
	)
	var original_clock_running: bool = GameClock.running
	var original_clock_remaining: float = GameClock.time_remaining
	var original_clock_phase: int = GameClock.phase
	var original_input_locked: bool = input_locked
	var original_carrying_snack: bool = carrying_snack
	var original_position: Vector3 = global_position
	var parent_was_processing: bool = (
		parent_actor != null and parent_actor.is_physics_processing()
	)
	var pet_was_processing: bool = (
		pet_actor != null and pet_actor.is_physics_processing()
	)

	Engine.time_scale = maxf(verify_b16_time_scale, 1.0)
	Engine.physics_ticks_per_second = maxi(
		verify_b16_physics_ticks_per_second,
		60
	)
	if parent_actor != null:
		parent_actor.set_physics_process(false)
	if pet_actor != null:
		pet_actor.set_physics_process(false)
	if is_attached_to_carrier():
		detach_from_carrier(original_position)
	set_carrying_snack(false)
	set_input_locked(false)
	if _game_flow != null:
		_game_flow.state = DinnerGameFlow.State.PLAYING
	if not NoiseSystem.noise_emitted.is_connected(_capture_b19_noise):
		NoiseSystem.noise_emitted.connect(_capture_b19_noise)
	GameClock.start()
	NoiseSystem.set_ambient_source_enabled("tv", false)
	NoiseSystem.set_ambient_source_enabled("kitchen_speaker", false)
	for _frame_index in range(verify_b16_warmup_frames):
		await get_tree().physics_frame

	var hardwood_indicator_start: int = (
		indicator_manager.get_child_count()
		if indicator_manager != null
		else 0
	)
	var hardwood_sample: Dictionary = await _sample_b19_footstep(
		verify_b19_hardwood_position,
		false
	)
	var hardwood_indicator_end: int = (
		indicator_manager.get_child_count()
		if indicator_manager != null
		else hardwood_indicator_start
	)
	var creaky_indicator_start: int = hardwood_indicator_end
	var creaky_sample: Dictionary = await _sample_b19_footstep(
		verify_b19_creaky_position,
		false
	)
	var creaky_indicator_end: int = (
		indicator_manager.get_child_count()
		if indicator_manager != null
		else creaky_indicator_start
	)
	var toys_indicator_start: int = creaky_indicator_end
	var toys_sample: Dictionary = await _sample_b19_footstep(
		verify_b19_toys_position,
		false
	)
	var toys_indicator_end: int = (
		indicator_manager.get_child_count()
		if indicator_manager != null
		else toys_indicator_start
	)
	var run_indicator_start: int = toys_indicator_end
	var run_sample: Dictionary = await _sample_b19_footstep(
		verify_b19_hardwood_position,
		true
	)
	var run_indicator_end: int = (
		indicator_manager.get_child_count()
		if indicator_manager != null
		else run_indicator_start
	)

	var hardwood_loudness: float = float(
		hardwood_sample.get("loudness", -1.0)
	)
	var creaky_loudness: float = float(
		creaky_sample.get("loudness", -1.0)
	)
	var toys_loudness: float = float(
		toys_sample.get("loudness", -1.0)
	)
	var run_loudness: float = float(run_sample.get("loudness", -1.0))
	var values_correct: bool = (
		absf(hardwood_loudness - 0.2) <= verify_b19_loudness_tolerance
		and absf(creaky_loudness - creaky_trap_floor) <= verify_b19_loudness_tolerance
		and absf(toys_loudness - toys_trap_floor) <= verify_b19_loudness_tolerance
		and absf(run_loudness - 1.2) <= verify_b19_loudness_tolerance
	)
	var surfaces_correct: bool = (
		is_equal_approx(
			float(hardwood_sample.get("surface", -1.0)),
			hardwood_surface_multiplier
		)
		and is_equal_approx(
			float(creaky_sample.get("surface", -1.0)),
			creaky_surface_multiplier
		)
		and is_equal_approx(
			float(toys_sample.get("surface", -1.0)),
			toys_surface_multiplier
		)
		and is_equal_approx(
			float(run_sample.get("surface", -1.0)),
			hardwood_surface_multiplier
		)
	)
	var indicator_gate_correct: bool = (
		hardwood_indicator_end <= hardwood_indicator_start
		and creaky_indicator_end > creaky_indicator_start
		and toys_indicator_end > toys_indicator_start
		and run_indicator_end > run_indicator_start
	)
	var verification_passed: bool = (
		values_correct
		and surfaces_correct
		and indicator_gate_correct
	)

	Input.action_release("move_right")
	Input.action_release("run")
	if NoiseSystem.noise_emitted.is_connected(_capture_b19_noise):
		NoiseSystem.noise_emitted.disconnect(_capture_b19_noise)
	NoiseSystem.set_ambient_source_enabled("tv", GameClock.phase < 2)
	NoiseSystem.set_ambient_source_enabled(
		"kitchen_speaker",
		GameClock.phase < 3
	)
	global_position = original_position
	velocity = Vector3.ZERO
	set_carrying_snack(original_carrying_snack)
	set_input_locked(original_input_locked)
	if _game_flow != null:
		_game_flow.state = original_game_state
	GameClock.running = original_clock_running
	GameClock.time_remaining = original_clock_remaining
	GameClock.phase = original_clock_phase
	Engine.time_scale = original_time_scale
	Engine.physics_ticks_per_second = original_physics_ticks
	if parent_actor != null:
		parent_actor.set_physics_process(parent_was_processing)
	if pet_actor != null:
		pet_actor.set_physics_process(pet_was_processing)

	print(
		(
			"B19 live metrics: sneak hardwood/creaky/toys="
			+ "%.2f/%.2f/%.2f, run hardwood=%.2f; "
			+ "indicator deltas=%d/%d/%d/%d."
		)
		% [
			hardwood_loudness,
			creaky_loudness,
			toys_loudness,
			run_loudness,
			hardwood_indicator_end - hardwood_indicator_start,
			creaky_indicator_end - creaky_indicator_start,
			toys_indicator_end - toys_indicator_start,
			run_indicator_end - run_indicator_start,
		]
	)
	get_tree().quit(0 if verification_passed else 1)
	assert(
		values_correct and surfaces_correct,
		"B19 live footsteps did not preserve the 0.2/3.2/4.0/1.2 profile."
	)
	assert(
		indicator_gate_correct,
		"B19 0.25 indicator gate did not hide only sneak-hardwood."
	)
	print("B19 live SceneTree verification passed.")


func _sample_b19_footstep(
	sample_position: Vector3,
	is_running: bool
) -> Dictionary:
	Input.action_release("move_right")
	Input.action_release("run")
	global_position = sample_position
	velocity = Vector3.ZERO
	_footstep_elapsed = 0.0
	_verify_b19_noise_count = 0
	_verify_b19_last_loudness = -1.0
	_verify_b19_last_surface_multiplier = -1.0
	for _frame_index in range(4):
		await get_tree().physics_frame
	Input.action_press("move_right")
	if is_running:
		Input.action_press("run")
	var sample_start: float = _get_b16_clock_elapsed()
	for _frame_index in range(verify_b16_max_physics_frames):
		await get_tree().physics_frame
		if _verify_b19_noise_count > 0:
			break
		if (
			_get_b16_clock_elapsed() - sample_start
			>= verify_b19_sample_timeout
		):
			break
	Input.action_release("move_right")
	Input.action_release("run")
	return {
		"loudness": _verify_b19_last_loudness,
		"surface": _verify_b19_last_surface_multiplier,
	}


func _capture_b19_noise(
	_pos: Vector3,
	loudness: float,
	source: Node
) -> void:
	if source != self or _idle_giggle_emitting or carrying_snack:
		return
	_verify_b19_noise_count += 1
	_verify_b19_last_loudness = loudness
	_verify_b19_last_surface_multiplier = _current_surface_multiplier


func _wait_b16_clock_duration(duration: float) -> void:
	var start_elapsed: float = _get_b16_clock_elapsed()
	for _frame_index in range(verify_b16_max_physics_frames):
		await get_tree().physics_frame
		if _get_b16_clock_elapsed() - start_elapsed >= duration:
			return


func _get_b16_clock_elapsed() -> float:
	return GameClock.run_length - GameClock.time_remaining


func _capture_b16_noise(
	pos: Vector3,
	loudness: float,
	source: Node
) -> void:
	if source != self or not _idle_giggle_emitting:
		return
	_verify_b16_noise_count += 1
	_verify_b16_last_loudness = loudness
	_verify_b16_last_position = pos


func _capture_b16_signal(_giggle_position: Vector3) -> void:
	_verify_b16_signal_count += 1
