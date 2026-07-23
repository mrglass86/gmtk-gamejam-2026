extends Node
class_name DinnerAudioDirector

## Scene-side audio only. Actor scripts remain authoritative for gameplay;
## this node observes their signals and public motion/state to add CC0 sound.
## All playback uses plain AudioStreamPlayer/AudioStreamPlayer3D nodes and
## direct volume_db changes so the Web build never depends on bus effects.

const TV_CLICK_OFF_STREAM: AudioStream = preload("res://audio/sfx/tv_click_off.ogg")
const LIGHT_SWITCH_STREAM: AudioStream = preload("res://audio/sfx/light_switch.ogg")
const PLAYER_STEP_CARPET_STREAM: AudioStream = preload(
	"res://audio/sfx/player_step_carpet.ogg"
)
const PLAYER_STEP_HARDWOOD_STREAM: AudioStream = preload(
	"res://audio/sfx/player_step_hardwood.ogg"
)
const PLAYER_STEP_CREAK_STREAM: AudioStream = preload(
	"res://audio/sfx/player_step_creak.ogg"
)
const TOY_SQUEAK_STREAM: AudioStream = preload("res://audio/sfx/toy_squeak.ogg")
const PARENT_STEP_STREAM: AudioStream = preload("res://audio/sfx/parent_step.ogg")
const DOOR_CREAK_STREAM: AudioStream = preload("res://audio/sfx/door_creak.ogg")
const WIN_STING_STREAM: AudioStream = preload("res://audio/sfx/win_sting.ogg")
const CAUGHT_STING_STREAM: AudioStream = preload("res://audio/sfx/caught_sting.ogg")
const PET_CHIRP_STREAM: AudioStream = preload("res://audio/sfx/pet_chirp.ogg")
const PET_BARK_STREAM: AudioStream = preload("res://audio/sfx/pet_bark.ogg")
const TV_MURMUR_STREAM: AudioStream = preload("res://audio/ambience/tv_murmur.ogg")
const SPEAKER_MUSIC_STREAM: AudioStream = preload(
	"res://audio/ambience/speaker_music.ogg"
)
const FRIDGE_HUM_STREAM: AudioStream = preload("res://audio/ambience/fridge_hum.ogg")
const CLOCK_TICK_STREAM: AudioStream = preload("res://audio/ambience/clock_tick.ogg")
const SNACK_PICKUP_STREAM: AudioStream = preload("res://audio/sfx/snack_pickup.ogg")
const SNACK_DROP_STREAM: AudioStream = preload("res://audio/sfx/snack_drop.ogg")

@export_group("Scene References")
@export_node_path("DinnerPlayer") var player_path: NodePath = NodePath("../Player")
@export_node_path("DinnerParent") var parent_path: NodePath = NodePath("../Parent")
@export_node_path("DinnerPet") var pet_path: NodePath = NodePath("../Pet")
@export_node_path("DinnerSnack") var snack_path: NodePath = NodePath("../Snack")
@export_node_path("DinnerGameFlow") var game_flow_path: NodePath = NodePath("../GameFlow")
@export_node_path("AudioListener3D") var listener_path: NodePath = NodePath(
	"../Player/AudioListener3D"
)
@export_node_path("DinnerDoor") var bedroom_door_path: NodePath = NodePath(
	"../BedroomDoor"
)
@export_node_path("DinnerDoor") var pantry_door_path: NodePath = NodePath("../Pantry")
@export_node_path("DinnerDoor") var bathroom_door_path: NodePath = NodePath(
	"../Level/BathroomDoor"
)

@export_group("Countdown Tells")
@export var tv_click_position: Vector3 = Vector3(-2.75, 1.0, -4.1)
@export var living_switch_position: Vector3 = Vector3(0.0, 1.1, -4.2)
@export var kitchen_switch_position: Vector3 = Vector3(10.5, 1.1, -3.0)
@export var hall_switch_position: Vector3 = Vector3(-0.5, 1.1, 0.5)
@export var tell_volume_db: float = -3.0
@export var tell_max_distance: float = 18.0

@export_group("Footsteps")
@export var carpet_step_volume_db: float = -25.0
@export var hardwood_step_volume_db: float = -10.0
@export var creak_step_volume_db: float = -5.0
@export var toy_squeak_volume_db: float = -3.0
@export var parent_step_volume_db: float = -7.0
@export var parent_step_distance: float = 0.85
@export var parent_step_max_distance: float = 12.0

@export_group("Pet and Results")
@export var pet_chirp_volume_db: float = -7.0
@export var pet_bark_volume_db: float = -3.0
@export var pet_max_distance: float = 12.0
@export var sting_volume_db: float = -4.0

@export_group("Snack")
@export var snack_pickup_volume_db: float = -2.0
@export var snack_drop_volume_db: float = -10.0
@export var snack_drop_max_distance: float = 8.0

@export_group("Ambient Beds")
@export var tv_bed_volume_db: float = -15.0
@export var speaker_bed_volume_db: float = -18.0
@export var fridge_hum_volume_db: float = -22.0
@export var clock_tick_volume_db: float = -18.0
@export var tv_bed_max_distance: float = 3.2
@export var speaker_bed_max_distance: float = 2.4
@export var fridge_hum_max_distance: float = 5.0
@export var clock_tick_max_distance: float = 4.0

@export_group("Door Holds")
@export var door_creak_quiet_volume_db: float = -18.0
@export var door_creak_rush_volume_db: float = -7.0
@export var door_creak_max_distance: float = 8.0

@onready var _player: DinnerPlayer = get_node_or_null(player_path) as DinnerPlayer
@onready var _parent: DinnerParent = get_node_or_null(parent_path) as DinnerParent
@onready var _pet: DinnerPet = get_node_or_null(pet_path) as DinnerPet
@onready var _snack: DinnerSnack = get_node_or_null(snack_path) as DinnerSnack
@onready var _game_flow: DinnerGameFlow = (
	get_node_or_null(game_flow_path) as DinnerGameFlow
)
@onready var _listener: AudioListener3D = (
	get_node_or_null(listener_path) as AudioListener3D
)

@onready var _tv_click: AudioStreamPlayer3D = $TVClickOff
@onready var _light_switch: AudioStreamPlayer3D = $LightSwitch
@onready var _player_footsteps: AudioStreamPlayer = $PlayerFootsteps
@onready var _parent_footsteps: AudioStreamPlayer3D = $ParentFootsteps
@onready var _win_sting: AudioStreamPlayer = $WinSting
@onready var _caught_sting: AudioStreamPlayer = $CaughtSting
@onready var _pet_chirp: AudioStreamPlayer3D = $PetChirp
@onready var _pet_bark: AudioStreamPlayer3D = $PetBark
@onready var _tv_bed: AudioStreamPlayer3D = $TVBed
@onready var _speaker_bed: AudioStreamPlayer3D = $SpeakerBed
@onready var _fridge_hum: AudioStreamPlayer3D = $FridgeHum
@onready var _clock_tick: AudioStreamPlayer3D = $ClockTick
@onready var _door_creak: AudioStreamPlayer3D = $DoorCreak
@onready var _snack_pickup: AudioStreamPlayer = $SnackPickup
@onready var _snack_drop: AudioStreamPlayer3D = $SnackDrop

var _doors: Array[DinnerDoor] = []
var _door_previous_openness: Dictionary = {}
var _game_active: bool = false
var _current_phase: int = 0
var _last_parent_position: Vector3
var _parent_step_distance_accumulated: float = 0.0
var _parent_step_alternate: bool = false
var _muted_for_a6_verification: bool = false


func _ready() -> void:
	_muted_for_a6_verification = OS.get_cmdline_user_args().has("--verify-a6")
	_wire_streams_and_tuning()
	_collect_doors()
	_connect_gameplay_signals()
	if _listener != null:
		_listener.make_current()
	if _parent != null:
		_last_parent_position = _parent.global_position


func _physics_process(delta: float) -> void:
	if not _game_active:
		_stop_door_creak()
		return
	_update_parent_footsteps()
	_update_door_creak(delta)


func verify_configuration() -> void:
	var audio_players: Array[Node] = []
	audio_players.append_array(
		find_children("*", "AudioStreamPlayer", true, false)
	)
	audio_players.append_array(
		find_children("*", "AudioStreamPlayer3D", true, false)
	)
	assert(audio_players.size() == 15)
	for audio_player: Node in audio_players:
		assert(audio_player.get("stream") != null)
	assert(_listener != null and _listener.is_current())
	assert(is_equal_approx(_tv_bed.max_distance, tv_bed_max_distance))
	assert(is_equal_approx(_speaker_bed.max_distance, speaker_bed_max_distance))
	for bus_index: int in range(AudioServer.bus_count):
		assert(
			AudioServer.get_bus_effect_count(bus_index) == 0,
			"Audio pass must not add bus effects."
		)


func begin_audio_verification() -> void:
	_on_game_started()
	assert(_game_active)
	assert(_tv_bed.playing and _speaker_bed.playing)
	assert(_fridge_hum.playing and _clock_tick.playing)
	_on_phase_changed(1)
	assert(_light_switch.playing)
	_on_phase_changed(2)
	assert(_tv_click.playing and not _tv_bed.playing)
	_on_phase_changed(3)
	assert(not _speaker_bed.playing)
	_on_pet_alert_started()
	assert(_pet_chirp.playing)
	_on_pet_bark_started()
	assert(_pet_bark.playing)
	_on_player_caught(Vector3.ZERO)
	assert(_caught_sting.playing)
	_play_player_footstep(_player.carpet_surface_multiplier)
	assert(_player_footsteps.stream == PLAYER_STEP_CARPET_STREAM)
	_play_player_footstep(_player.hardwood_surface_multiplier)
	assert(_player_footsteps.stream == PLAYER_STEP_HARDWOOD_STREAM)
	_play_player_footstep(_player.creaky_surface_multiplier)
	assert(_player_footsteps.stream == PLAYER_STEP_CREAK_STREAM)
	_last_parent_position = _parent.global_position - Vector3(0.45, 0.0, 0.0)
	_update_parent_footsteps()
	_last_parent_position = _parent.global_position - Vector3(0.45, 0.0, 0.0)
	_update_parent_footsteps()
	assert(_parent_footsteps.playing)
	var verification_door: DinnerDoor = _doors[0]
	verification_door.openness += 0.01
	_update_door_creak(1.0 / 60.0)
	assert(_door_creak.playing)
	_on_snack_picked_up(_player)
	assert(_snack_pickup.playing)
	_on_snack_dropped(_snack.global_position)
	assert(_snack_drop.playing)


func end_audio_verification() -> void:
	_game_active = false
	for audio_player: Node in find_children("*", "AudioStreamPlayer", true, false):
		audio_player.call("stop")
	for audio_player: Node in find_children("*", "AudioStreamPlayer3D", true, false):
		audio_player.call("stop")


func _wire_streams_and_tuning() -> void:
	_tv_click.stream = TV_CLICK_OFF_STREAM
	_tv_click.volume_db = tell_volume_db
	_tv_click.max_distance = tell_max_distance
	_tv_click.position = tv_click_position

	_light_switch.stream = LIGHT_SWITCH_STREAM
	_light_switch.volume_db = tell_volume_db
	_light_switch.max_distance = tell_max_distance

	_player_footsteps.stream = PLAYER_STEP_HARDWOOD_STREAM
	_player_footsteps.volume_db = hardwood_step_volume_db

	_parent_footsteps.stream = PARENT_STEP_STREAM
	_parent_footsteps.volume_db = parent_step_volume_db
	_parent_footsteps.max_distance = parent_step_max_distance

	_win_sting.stream = WIN_STING_STREAM
	_win_sting.volume_db = sting_volume_db
	_caught_sting.stream = CAUGHT_STING_STREAM
	_caught_sting.volume_db = sting_volume_db

	_pet_chirp.stream = PET_CHIRP_STREAM
	_pet_chirp.volume_db = pet_chirp_volume_db
	_pet_chirp.max_distance = pet_max_distance
	_pet_bark.stream = PET_BARK_STREAM
	_pet_bark.volume_db = pet_bark_volume_db
	_pet_bark.max_distance = pet_max_distance

	_tv_bed.stream = TV_MURMUR_STREAM
	_tv_bed.volume_db = tv_bed_volume_db
	_tv_bed.max_distance = tv_bed_max_distance
	_speaker_bed.stream = SPEAKER_MUSIC_STREAM
	_speaker_bed.volume_db = speaker_bed_volume_db
	_speaker_bed.max_distance = speaker_bed_max_distance
	_fridge_hum.stream = FRIDGE_HUM_STREAM
	_fridge_hum.volume_db = fridge_hum_volume_db
	_fridge_hum.max_distance = fridge_hum_max_distance
	_clock_tick.stream = CLOCK_TICK_STREAM
	_clock_tick.volume_db = clock_tick_volume_db
	_clock_tick.max_distance = clock_tick_max_distance

	_door_creak.stream = DOOR_CREAK_STREAM
	_door_creak.max_distance = door_creak_max_distance

	_snack_pickup.stream = SNACK_PICKUP_STREAM
	_snack_pickup.volume_db = snack_pickup_volume_db
	_snack_drop.stream = SNACK_DROP_STREAM
	_snack_drop.volume_db = snack_drop_volume_db
	_snack_drop.max_distance = snack_drop_max_distance


func _collect_doors() -> void:
	for door_path: NodePath in [
		bedroom_door_path,
		pantry_door_path,
		bathroom_door_path,
	]:
		var door: DinnerDoor = get_node_or_null(door_path) as DinnerDoor
		if door == null:
			continue
		_doors.append(door)
		_door_previous_openness[door] = door.openness


func _connect_gameplay_signals() -> void:
	assert(
		_player != null
		and _parent != null
		and _pet != null
		and _snack != null
		and _game_flow != null,
		"AudioDirector is missing an actor or GameFlow reference."
	)
	if not _game_flow.game_started.is_connected(_on_game_started):
		_game_flow.game_started.connect(_on_game_started)
	if not _game_flow.game_ended.is_connected(_on_game_ended):
		_game_flow.game_ended.connect(_on_game_ended)
	if not GameClock.phase_changed.is_connected(_on_phase_changed):
		GameClock.phase_changed.connect(_on_phase_changed)
	if not NoiseSystem.noise_emitted.is_connected(_on_noise_emitted):
		NoiseSystem.noise_emitted.connect(_on_noise_emitted)
	if not _parent.player_caught.is_connected(_on_player_caught):
		_parent.player_caught.connect(_on_player_caught)
	if not _pet.alert_started.is_connected(_on_pet_alert_started):
		_pet.alert_started.connect(_on_pet_alert_started)
	if not _pet.bark_started.is_connected(_on_pet_bark_started):
		_pet.bark_started.connect(_on_pet_bark_started)
	if not _snack.picked_up.is_connected(_on_snack_picked_up):
		_snack.picked_up.connect(_on_snack_picked_up)
	if not _snack.dropped.is_connected(_on_snack_dropped):
		_snack.dropped.connect(_on_snack_dropped)
	if not _tv_bed.finished.is_connected(_on_tv_bed_finished):
		_tv_bed.finished.connect(_on_tv_bed_finished)
	if not _speaker_bed.finished.is_connected(_on_speaker_bed_finished):
		_speaker_bed.finished.connect(_on_speaker_bed_finished)
	if not _fridge_hum.finished.is_connected(_on_fridge_hum_finished):
		_fridge_hum.finished.connect(_on_fridge_hum_finished)
	if not _clock_tick.finished.is_connected(_on_clock_tick_finished):
		_clock_tick.finished.connect(_on_clock_tick_finished)


func _on_game_started() -> void:
	if _muted_for_a6_verification:
		return
	_game_active = true
	_current_phase = GameClock.phase
	_parent_step_distance_accumulated = 0.0
	if _parent != null:
		_last_parent_position = _parent.global_position
	_apply_ambient_phase()
	_restart_if_stopped(_fridge_hum)
	_restart_if_stopped(_clock_tick)


func _on_game_ended(did_win: bool) -> void:
	if _muted_for_a6_verification:
		return
	_game_active = false
	_stop_ambient_beds()
	_stop_door_creak()
	if did_win:
		_win_sting.play()
	else:
		_caught_sting.play()


func _on_phase_changed(next_phase: int) -> void:
	var previous_phase: int = _current_phase
	_current_phase = clampi(next_phase, 0, 4)
	if not _game_active:
		return
	if _current_phase > previous_phase:
		match _current_phase:
			1:
				_play_light_switch_at(living_switch_position)
			2:
				_tv_click.play()
			3:
				_play_light_switch_at(kitchen_switch_position)
			4:
				_play_light_switch_at(hall_switch_position)
	_apply_ambient_phase()


func _apply_ambient_phase() -> void:
	if not _game_active:
		return
	if _current_phase < 2:
		_restart_if_stopped(_tv_bed)
	else:
		_tv_bed.stop()
	if _current_phase < 3:
		_restart_if_stopped(_speaker_bed)
	else:
		_speaker_bed.stop()


func _play_light_switch_at(world_position: Vector3) -> void:
	_light_switch.global_position = world_position
	_light_switch.play()


func _on_noise_emitted(pos: Vector3, loudness: float, source: Node) -> void:
	if not _game_active or source != _player or _player == null:
		return
	var mask: float = clampf(NoiseSystem.get_mask_at(pos), 0.0, 1.0)
	var audible_fraction: float = 1.0 - mask
	if audible_fraction <= 0.001:
		return
	var surface_multiplier: float = _player._current_surface_multiplier
	var expected_step_loudness: float = (
		_player._get_noise_multiplier() * surface_multiplier
	)
	var recovered_raw_loudness: float = loudness / audible_fraction
	var comparison_tolerance: float = maxf(0.06, expected_step_loudness * 0.12)
	if absf(recovered_raw_loudness - expected_step_loudness) > comparison_tolerance:
		return
	_play_player_footstep(surface_multiplier)


func _play_player_footstep(surface_multiplier: float) -> void:
	if surface_multiplier >= _player.toys_surface_multiplier - 0.01:
		_player_footsteps.stream = TOY_SQUEAK_STREAM
		_player_footsteps.volume_db = toy_squeak_volume_db
	elif surface_multiplier >= _player.creaky_surface_multiplier - 0.01:
		_player_footsteps.stream = PLAYER_STEP_CREAK_STREAM
		_player_footsteps.volume_db = creak_step_volume_db
	elif surface_multiplier <= _player.carpet_surface_multiplier + 0.01:
		_player_footsteps.stream = PLAYER_STEP_CARPET_STREAM
		_player_footsteps.volume_db = carpet_step_volume_db
	else:
		_player_footsteps.stream = PLAYER_STEP_HARDWOOD_STREAM
		_player_footsteps.volume_db = hardwood_step_volume_db
	_player_footsteps.pitch_scale = randf_range(0.96, 1.04)
	_player_footsteps.play()


func _update_parent_footsteps() -> void:
	if _parent == null:
		return
	var current_position: Vector3 = _parent.global_position
	var movement: Vector3 = current_position - _last_parent_position
	movement.y = 0.0
	_last_parent_position = current_position
	var movement_distance: float = movement.length()
	if movement_distance <= 0.0001:
		return
	if movement_distance > 0.5:
		_parent_step_distance_accumulated = 0.0
		return
	_parent_step_distance_accumulated += movement_distance
	if _parent_step_distance_accumulated < parent_step_distance:
		return
	_parent_step_distance_accumulated = fmod(
		_parent_step_distance_accumulated,
		maxf(parent_step_distance, 0.01)
	)
	_parent_footsteps.global_position = current_position
	_parent_step_alternate = not _parent_step_alternate
	_parent_footsteps.pitch_scale = 1.03 if _parent_step_alternate else 0.97
	_parent_footsteps.play()


func _update_door_creak(delta: float) -> void:
	var moving_door: DinnerDoor
	var fastest_rate: float = 0.0
	for door: DinnerDoor in _doors:
		var previous_openness: float = float(
			_door_previous_openness.get(door, door.openness)
		)
		var openness_change: float = maxf(door.openness - previous_openness, 0.0)
		_door_previous_openness[door] = door.openness
		var openness_rate: float = openness_change / maxf(delta, 0.001)
		if openness_rate > fastest_rate:
			fastest_rate = openness_rate
			moving_door = door
	if moving_door == null:
		_stop_door_creak()
		return
	_door_creak.global_position = moving_door.global_position
	var rush_weight: float = clampf(
		inverse_lerp(0.2, 1.0, fastest_rate),
		0.0,
		1.0
	)
	_door_creak.volume_db = lerpf(
		door_creak_quiet_volume_db,
		door_creak_rush_volume_db,
		rush_weight
	)
	if not _door_creak.playing:
		_door_creak.play()


func _stop_door_creak() -> void:
	if _door_creak.playing:
		_door_creak.stop()


func _on_player_caught(_catch_position: Vector3) -> void:
	if _game_active:
		_caught_sting.play()


func _on_pet_alert_started() -> void:
	if not _game_active:
		return
	_pet_chirp.global_position = _pet.global_position
	_pet_chirp.play()


func _on_pet_bark_started() -> void:
	if not _game_active:
		return
	_pet_bark.global_position = _pet.global_position
	_pet_bark.play()


func _on_snack_picked_up(_carrier: DinnerPlayer) -> void:
	if _game_active:
		_snack_pickup.play()


func _on_snack_dropped(drop_position: Vector3) -> void:
	if not _game_active:
		return
	_snack_drop.global_position = drop_position
	_snack_drop.play()


func _on_tv_bed_finished() -> void:
	if _game_active and _current_phase < 2:
		_tv_bed.play()


func _on_speaker_bed_finished() -> void:
	if _game_active and _current_phase < 3:
		_speaker_bed.play()


func _on_fridge_hum_finished() -> void:
	if _game_active:
		_fridge_hum.play()


func _on_clock_tick_finished() -> void:
	if _game_active:
		_clock_tick.play()


func _restart_if_stopped(audio_player: Node) -> void:
	if not bool(audio_player.get("playing")):
		audio_player.call("play")


func _stop_ambient_beds() -> void:
	_tv_bed.stop()
	_speaker_bed.stop()
	_fridge_hum.stop()
	_clock_tick.stop()
