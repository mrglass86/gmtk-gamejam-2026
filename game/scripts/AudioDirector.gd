extends Node
class_name DinnerAudioDirector

## Scene-side audio only. Actor scripts remain authoritative for gameplay;
## this node observes their signals and public motion/state to add sound.
## All playback uses plain AudioStreamPlayer/AudioStreamPlayer3D nodes and
## direct volume_db changes so the Web build never depends on bus effects.

const CASTING = preload("res://scripts/AudioCasting.gd")
const TV_CLICK_OFF_STREAM: AudioStream = preload("res://audio/sfx/tv_click_off.ogg")
const LIGHT_SWITCH_STREAM: AudioStream = preload("res://audio/sfx/light_switch.ogg")
const PLAYER_STEP_CREAK_STREAM: AudioStream = preload(
	"res://audio/sfx/player_step_creak.ogg"
)
const TOY_SQUEAK_STREAM: AudioStream = preload("res://audio/sfx/toy_squeak.ogg")
const PET_CHIRP_STREAM: AudioStream = preload("res://audio/sfx/pet_chirp.ogg")
const PET_BARK_STREAM: AudioStream = preload("res://audio/sfx/pet_bark.ogg")
const TV_MURMUR_STREAM: AudioStream = preload("res://audio/ambience/tv_murmur.ogg")
const SPEAKER_MUSIC_STREAM: AudioStream = preload(
	"res://audio/ambience/speaker_music.ogg"
)
const CLOCK_TICK_STREAM: AudioStream = preload("res://audio/ambience/clock_tick.ogg")
const SNACK_DROP_STREAM: AudioStream = preload("res://audio/sfx/snack_drop.ogg")

@export_group("Scene References")
@export_node_path("DinnerPlayer") var player_path: NodePath = NodePath("../Player")
@export_node_path("DinnerParent") var parent_path: NodePath = NodePath("../Parent")
@export_node_path("DinnerPet") var pet_path: NodePath = NodePath("../Pet")
@export_node_path("DinnerSnack") var snack_path: NodePath = NodePath("../Snack")
@export_node_path("DinnerGameFlow") var game_flow_path: NodePath = NodePath("../GameFlow")
@export_node_path("Node3D") var crib_path: NodePath = NodePath("../Crib")
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
@export_node_path("DinnerDoor") var fridge_path: NodePath = NodePath("../Fridge")
@export_node_path("PhaseDirector") var phase_director_path: NodePath = NodePath(
	"../PhaseDirector"
)

@export_group("Countdown Tells")
@export var tv_click_position: Vector3 = Vector3(-2.75, 1.0, -4.1)
@export var living_switch_position: Vector3 = Vector3(0.0, 1.1, -4.2)
# Retained for scene compatibility; the kitchen/dining/foyer shutdowns now
# click through their real WorldSwitch nodes, not faked positions here.
@export var kitchen_switch_position: Vector3 = Vector3(10.5, 1.1, -3.0)
@export var hall_switch_position: Vector3 = Vector3(-0.5, 1.1, 0.5)
@export var tell_volume_db: float = -3.0
@export var tell_max_distance: float = 18.0

@export_group("Footsteps")
@export var carpet_step_volume_db: float = -42.0
@export var hardwood_step_volume_db: float = -28.0
@export var run_carpet_step_volume_db: float = -20.0
@export var run_hardwood_step_volume_db: float = -7.0
## Creaky boards are the loudest player tell (2026-07-25: louder per the
## director; the longer groan takes ride the next audio pass).
@export var creak_step_volume_db: float = 1.0
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

@export_group("Original Voice")
@export var voice_volume_db: float = -5.0
@export var chained_voice_gap_min: float = 0.14
@export var chained_voice_gap_max: float = 0.30
@export var carry_parent_grunt_interval_min: float = 3.0
@export var carry_parent_grunt_interval_max: float = 4.8
@export_range(0.0, 1.0) var organic_reaction_chance: float = 0.25
@export var organic_reaction_cooldown: float = 2.5

@export_group("Original Foley")
@export var wrapper_volume_db: float = -20.0
@export var wrapper_audio_interval: float = 2.5
@export var fridge_pop_volume_db: float = -8.0
@export var fridge_pop_max_distance: float = 7.0
# The flush/sink set-piece is a house-wide tell like the phase switch
# clicks (tell_max_distance 18.0), not local foley: at -13 dB / 8 m the
# playtest listener across the house heard nothing.
@export var bathroom_foley_volume_db: float = -8.0
@export var bathroom_foley_max_distance: float = 18.0

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
@export var door_creak_max_distance: float = 8.0

@onready var _player: DinnerPlayer = get_node_or_null(player_path) as DinnerPlayer
@onready var _parent: DinnerParent = get_node_or_null(parent_path) as DinnerParent
@onready var _pet: DinnerPet = get_node_or_null(pet_path) as DinnerPet
@onready var _snack: DinnerSnack = get_node_or_null(snack_path) as DinnerSnack
@onready var _game_flow: DinnerGameFlow = (
	get_node_or_null(game_flow_path) as DinnerGameFlow
)
@onready var _crib: Node3D = get_node_or_null(crib_path) as Node3D
@onready var _listener: AudioListener3D = (
	get_node_or_null(listener_path) as AudioListener3D
)
@onready var _fridge: DinnerDoor = get_node_or_null(fridge_path) as DinnerDoor
@onready var _phase_director: PhaseDirector = (
	get_node_or_null(phase_director_path) as PhaseDirector
)

@onready var _tv_click: AudioStreamPlayer3D = $TVClickOff
@onready var _light_switch: AudioStreamPlayer3D = $LightSwitch
@onready var _player_footsteps: AudioStreamPlayer3D = $PlayerFootsteps
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
@onready var _snack_pickup: AudioStreamPlayer3D = $SnackPickup
@onready var _snack_drop: AudioStreamPlayer3D = $SnackDrop
@onready var _voice: AudioStreamPlayer = $Voice
@onready var _wrapper_foley: AudioStreamPlayer3D = $WrapperFoley
@onready var _fridge_pop: AudioStreamPlayer3D = $FridgePop
@onready var _bathroom_foley: AudioStreamPlayer3D = $BathroomFoley

var _doors: Array[DinnerDoor] = []
var _door_previous_openness: Dictionary = {}
var _game_active: bool = false
var _current_phase: int = 0
var _last_parent_position: Vector3
var _parent_step_distance_accumulated: float = 0.0
var _muted_for_a6_verification: bool = false
var _pool_last_indices: Dictionary = {}
var _sequence_group_generations: Dictionary = {}
var _routine_events_fired: Dictionary = {}
var _audio_epoch: int = 0
var _voice_priority: int = 0
var _active_voice_pool: StringName = &""
var _chase_chain_active: bool = false
var _chase_voice_gap_remaining: float = 0.0
var _carry_chain_active: bool = false
var _carry_had_snack: bool = false
var _carry_voice_gap_remaining: float = 0.0
var _carry_elapsed: float = 0.0
var _carry_start_distance: float = 0.0
var _carry_protest_count: int = 0
var _carry_parent_grunt_count: int = 0
var _carry_next_parent_grunt_at: float = 0.0
var _organic_reaction_elapsed: float = 999.0
var _organic_reaction_play_count: int = 0
var _game_start_line_play_count: int = 0
var _previous_routine_time: float = -0.001
var _fridge_previous_openness: float = 0.0
var _fridge_was_opening: bool = false
var _b14_verification: bool = false
var _verification_noise_count: int = 0
var _tv_bed_shutdown: bool = false
var _speaker_bed_shutdown: bool = false
var _wrapper_audio_elapsed: float = 0.0
var _snack_pickup_latched: bool = false
var _snack_pickup_play_count: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_muted_for_a6_verification = OS.get_cmdline_user_args().has("--verify-a6")
	_b14_verification = OS.get_cmdline_user_args().has("--verify-b14")
	_rng.randomize()
	_wire_streams_and_tuning()
	_collect_doors()
	_connect_gameplay_signals()
	if not _voice.finished.is_connected(_on_voice_finished):
		_voice.finished.connect(_on_voice_finished)
	if _listener != null:
		_listener.make_current()
	if _parent != null:
		_last_parent_position = _parent.global_position
	if _fridge != null:
		_fridge_previous_openness = _fridge.openness


func _physics_process(delta: float) -> void:
	if not _game_active:
		_stop_door_creak()
		return
	_update_parent_footsteps()
	_update_door_creak(delta)
	_update_fridge_pop(delta)
	_update_routine_events()
	_update_chase_voice(delta)
	_update_carry_voice(delta)
	_organic_reaction_elapsed += delta
	_update_wrapper_audio(delta)


func verify_configuration() -> void:
	var audio_players: Array[Node] = []
	audio_players.append_array(
		find_children("*", "AudioStreamPlayer", true, false)
	)
	audio_players.append_array(
		find_children("*", "AudioStreamPlayer3D", true, false)
	)
	assert(audio_players.size() == 19)
	for audio_player: Node in audio_players:
		assert(audio_player.get("stream") != null)
	assert(_listener != null and _listener.is_current())
	assert(_fridge != null)
	assert(_crib != null)
	assert(is_equal_approx(_tv_bed.max_distance, tv_bed_max_distance))
	assert(is_equal_approx(_speaker_bed.max_distance, speaker_bed_max_distance))
	assert(CASTING.POOLS.size() >= 30)
	for event_id: StringName in [
		&"game_start",
		&"curiosity",
		&"idle_giggle",
		&"catch",
		&"deposit",
		&"win",
		&"bathroom_visit",
		&"epilogue_room_check",
		&"epilogue_kid_protest",
	]:
		assert(CASTING.EVENTS.has(event_id))
	assert(
		CASTING.POOLS[&"parent_bed_check"].get("speaker", &"")
		== &"parent"
	)
	assert(
		CASTING.POOLS[&"kid_room_protest"].get("speaker", &"")
		== &"kid"
	)
	assert(
		is_equal_approx(
			float(CASTING.POOLS[&"idle_giggle"].get("volume_offset_db", 0.0)),
			-8.0
		)
	)
	for snack_pool: StringName in [
		&"snack_pickup_pantry",
		&"snack_pickup_fridge_scoop",
		&"snack_pickup_fridge_voice",
		&"wrapper_crinkle",
		&"ice_cream_carry",
	]:
		assert(CASTING.POOLS.has(snack_pool))
	assert(
		CASTING.POOLS[&"snack_pickup_fridge_voice"].get("speaker", &"")
		== &"kid"
	)
	for a23_pool: StringName in [
		&"game_start_motivation",
		&"carry_red_handed",
		&"carry_empty_handed",
		&"caught_reaction",
		&"kid_organic_reaction",
		&"fun_giggle",
		&"parent_carry_grunt_red_handed",
		&"parent_carry_grunt_empty_handed",
	]:
		assert(CASTING.POOLS.has(a23_pool))
	# Director ruling 2026-07-24: every recorded door-creak take is wired for
	# variety, so the un-denoised foley originals are sanctioned until the
	# denoise pipeline is re-run on them.
	for pool_id: StringName in CASTING.POOLS:
		var pool_streams: Array = CASTING.POOLS[pool_id].get("streams", [])
		for stream: AudioStream in pool_streams:
			assert(
				not stream.resource_path.begins_with(
					"res://audio/original/"
				)
				or stream.resource_path
				== "res://audio/original/voice/caught_grunt_02.ogg"
				or stream.resource_path.begins_with(
					"res://audio/original/foley/door_creak_"
				),
				"Uncleaned family take remains wired: %s."
				% stream.resource_path
			)
	var motivation_streams: Array = (
		CASTING.POOLS[&"game_start_motivation"]["streams"] as Array
	)
	var red_handed_streams: Array = (
		CASTING.POOLS[&"carry_red_handed"]["streams"] as Array
	)
	assert(motivation_streams.size() == 1)
	assert(
		motivation_streams[0].resource_path
		== "res://audio/denoised/voice/carry_red_handed_01.ogg"
	)
	assert(
		not red_handed_streams.has(motivation_streams[0]),
		"Start motivation line leaked back into the carry pool."
	)
	assert((CASTING.POOLS[&"fun_giggle"]["streams"] as Array).size() == 11)
	assert(
		(CASTING.POOLS[&"parent_carry_grunt_red_handed"]["streams"] as Array)
		.size() == 3
	)
	assert(
		(CASTING.POOLS[&"parent_carry_grunt_empty_handed"]["streams"] as Array)
		.size() == 1
	)
	var catch_steps: Array = CASTING.EVENTS[&"catch"].get("steps", [])
	assert(catch_steps.size() == 2)
	assert((catch_steps[1] as Dictionary).get("pool", &"") == &"caught_reaction")
	var win_steps: Array = CASTING.EVENTS[&"win"].get("steps", [])
	assert((win_steps.back() as Dictionary).get("pool", &"") == &"fun_giggle")
	assert(int((win_steps.back() as Dictionary).get("priority", -1)) == 4)
	for bus_index: int in range(AudioServer.bus_count):
		assert(
			AudioServer.get_bus_effect_count(bus_index) == 0,
			"Audio pass must not add bus effects."
		)


func begin_audio_verification() -> void:
	_rng.seed = 150026
	var start_line_count_before: int = _game_start_line_play_count
	_on_game_started()
	assert(_game_active)
	assert(is_voice_pool_playing(&"game_start_motivation"))
	assert(_game_start_line_play_count == start_line_count_before + 1)
	assert(_tv_bed.playing and _speaker_bed.playing)
	assert(_fridge_hum.playing and _clock_tick.playing)
	# Expectation edit (2026-07-24 parent-initiated shutdowns): boundaries
	# arm errands; the audible tell now rides the errand completion.
	_on_phase_changed(1)
	_on_shutdown_errand_completed(&"living", true)
	assert(_light_switch.playing)
	_on_phase_changed(2)
	_on_shutdown_errand_completed(&"tv", true)
	assert(_tv_click.playing and not _tv_bed.playing)
	_on_phase_changed(3)
	_on_shutdown_errand_completed(&"kitchen", true)
	assert(not _speaker_bed.playing)
	_on_pet_alert_started()
	assert(_pet_chirp.playing)
	_on_pet_bark_started()
	assert(_pet_bark.playing)
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	var parent_voice_indicator: MeshInstance3D = (
		_parent.get_node("ParentVoiceIndicator") as MeshInstance3D
	)
	parent_voice_indicator.visible = false
	_verification_noise_count = 0
	NoiseSystem.noise_emitted.connect(_capture_verification_noise)
	_parent.curiosity_started.emit(Vector3.ZERO)
	NoiseSystem.noise_emitted.disconnect(_capture_verification_noise)
	assert(_voice.playing)
	assert(_pool_contains_stream(&"parent_investigate", _voice.stream))
	assert(parent_voice_indicator.visible)
	assert(_verification_noise_count == 0)
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_player.idle_giggled.emit(_player.global_position)
	assert(is_voice_pool_playing(&"idle_giggle"))
	assert(is_equal_approx(_voice.volume_db, voice_volume_db - 8.0))
	_on_player_caught(Vector3.ZERO, true)
	assert(_caught_sting.playing)
	assert(_carry_chain_active and _carry_had_snack)
	assert(_carry_start_distance > 0.0)
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_carry_voice_gap_remaining = 0.0
	assert(_play_next_carry_voice())
	assert(is_voice_pool_playing(&"carry_red_handed"))
	assert(_carry_protest_count == 1)
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_carry_elapsed = _carry_next_parent_grunt_at
	assert(_play_next_carry_voice())
	assert(is_voice_pool_playing(&"parent_carry_grunt_red_handed"))
	assert(_carry_parent_grunt_count == 1)
	_stop_carry_chain()
	_start_carry_chain(Vector3.ZERO, false)
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	assert(_play_next_carry_voice())
	assert(is_voice_pool_playing(&"carry_empty_handed"))
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_carry_elapsed = _carry_next_parent_grunt_at
	assert(_play_next_carry_voice())
	assert(is_voice_pool_playing(&"parent_carry_grunt_empty_handed"))
	_stop_carry_chain()
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	var original_reaction_chance: float = organic_reaction_chance
	organic_reaction_chance = 1.0
	_organic_reaction_elapsed = organic_reaction_cooldown
	var reaction_count_before: int = _organic_reaction_play_count
	_on_player_organic_reaction(&"toy", _player.global_position)
	assert(is_voice_pool_playing(&"kid_organic_reaction"))
	assert(_organic_reaction_play_count == reaction_count_before + 1)
	organic_reaction_chance = original_reaction_chance
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_start_chase_chain()
	assert(_play_next_chase_giggle())
	assert(is_voice_pool_playing(&"fun_giggle"))
	var first_chase_pick: AudioStream = _voice.stream
	_voice.stop()
	_on_voice_finished()
	_chase_voice_gap_remaining = 0.0
	assert(_play_next_chase_giggle())
	assert(is_voice_pool_playing(&"fun_giggle"))
	assert(_voice.stream != first_chase_pick)
	_stop_chase_chain()
	_play_player_footstep(_player.carpet_surface_multiplier)
	assert(_pool_contains_stream(&"footstep_carpet_walk", _player_footsteps.stream))
	assert(is_equal_approx(_player_footsteps.volume_db, carpet_step_volume_db))
	_play_player_footstep(_player.hardwood_surface_multiplier)
	assert(_pool_contains_stream(&"footstep_wood", _player_footsteps.stream))
	assert(is_equal_approx(_player_footsteps.volume_db, hardwood_step_volume_db))
	Input.action_press("run")
	_play_player_footstep(_player.carpet_surface_multiplier)
	assert(
		is_equal_approx(
			_player_footsteps.volume_db,
			run_carpet_step_volume_db
		)
	)
	_play_player_footstep(_player.hardwood_surface_multiplier)
	assert(
		is_equal_approx(
			_player_footsteps.volume_db,
			run_hardwood_step_volume_db
		)
	)
	Input.action_release("run")
	_play_player_footstep(_player.creaky_surface_multiplier)
	# Expectation edit (2026-07-25): creaky steps now draw from the slow
	# door-creak takes pool instead of the placeholder tick stream.
	assert(
		_pool_contains_stream(&"floor_creak_step", _player_footsteps.stream)
	)
	assert(is_equal_approx(_player_footsteps.volume_db, creak_step_volume_db))
	_last_parent_position = _parent.global_position - Vector3(0.45, 0.0, 0.0)
	_update_parent_footsteps()
	_last_parent_position = _parent.global_position - Vector3(0.45, 0.0, 0.0)
	_update_parent_footsteps()
	assert(_parent_footsteps.playing)
	assert(_pool_contains_stream(&"parent_footstep", _parent_footsteps.stream))
	var verification_door: DinnerDoor = _doors[0]
	verification_door.openness_rate = verification_door.creak_slow_rate
	verification_door.openness += 0.01
	_update_door_creak(1.0 / 60.0)
	assert(_door_creak.playing)
	assert(_pool_contains_stream(&"door_creak_slow", _door_creak.stream))
	assert(
		is_equal_approx(
			_door_creak.pitch_scale,
			verification_door.get_creak_pitch_scale()
		)
	)
	assert(
		is_equal_approx(
			_door_creak.volume_db,
			verification_door.get_creak_volume_db()
		)
	)
	verification_door.openness_rate = verification_door.creak_fast_rate
	verification_door.openness += 0.02
	_update_door_creak(1.0 / 60.0)
	assert(
		is_equal_approx(
			_door_creak.pitch_scale,
			verification_door.get_creak_pitch_scale()
		)
	)
	assert(
		is_equal_approx(
			_door_creak.volume_db,
			verification_door.get_creak_volume_db()
		)
	)
	var pickup_count_before: int = _snack_pickup_play_count
	_snack.set_snack_type(DinnerSnack.TYPE_CHIPS)
	_on_snack_picked_up(_player)
	_on_snack_picked_up(_player)
	assert(_snack_pickup.playing)
	assert(_pool_contains_stream(&"snack_pickup_pantry", _snack_pickup.stream))
	assert(_snack_pickup_play_count == pickup_count_before + 1)
	_on_snack_dropped(_snack.global_position)
	assert(_snack_drop.playing)
	assert(_voice.playing)
	assert(_pool_contains_stream(&"snack_drop_voice", _voice.stream))
	_wrapper_foley.stop()
	_player.set_carrying_snack(true)
	_wrapper_audio_elapsed = 0.0
	_update_wrapper_audio(wrapper_audio_interval - 0.01)
	assert(not _wrapper_foley.playing)
	_update_wrapper_audio(0.02)
	assert(_wrapper_foley.playing)
	assert(is_equal_approx(_wrapper_foley.volume_db, wrapper_volume_db))
	assert(is_equal_approx(_player.snack_noise_interval, 0.6))
	assert(is_equal_approx(_player.snack_noise_loudness, 0.3))
	_player.set_carrying_snack(false)
	var drop_voice: AudioStream = _voice.stream
	assert(not _play_pool(&"fun_giggle"))
	assert(_voice.stream == drop_voice)
	assert(_play_pool(&"carry_red_handed"))
	assert(_pool_contains_stream(&"carry_red_handed", _voice.stream))
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_on_epilogue_room_check_started()
	assert(is_voice_pool_playing(&"parent_bed_check"))
	assert(
		(_parent.get_node("ParentVoiceIndicator") as MeshInstance3D).visible
	)
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_on_epilogue_kid_protest()
	assert(is_voice_pool_playing(&"kid_room_protest"))
	_play_pool(&"fridge_open_pop")
	assert(_fridge_pop.playing)
	_play_pool(&"wrapper_crinkle")
	assert(_wrapper_foley.playing)
	var first_pick: AudioStream = _select_pool_stream(&"fun_giggle")
	var second_pick: AudioStream = _select_pool_stream(&"fun_giggle")
	assert(first_pick != second_pick, "A15 pools must not repeat immediately.")
	print(
		"A23 casting verified: motivation=1, carry red/empty=6/7, "
		+ "organic=2, chase+win giggles=11, parent carry red/empty=3/1."
	)


func end_audio_verification() -> void:
	_game_active = false
	_audio_epoch += 1
	_stop_chase_chain()
	_stop_carry_chain()
	_voice_priority = 0
	_active_voice_pool = &""
	_sequence_group_generations.clear()
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

	_player_footsteps.stream = _select_pool_stream(&"footstep_wood")
	_player_footsteps.volume_db = hardwood_step_volume_db
	_player_footsteps.max_distance = 8.0

	_parent_footsteps.stream = _select_pool_stream(&"parent_footstep")
	_parent_footsteps.volume_db = parent_step_volume_db
	_parent_footsteps.max_distance = parent_step_max_distance

	_win_sting.stream = _select_pool_stream(&"win_sting")
	_win_sting.volume_db = sting_volume_db
	_caught_sting.stream = _select_pool_stream(&"caught_sting")
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
	_fridge_hum.stream = _select_pool_stream(&"fridge_hum")
	_fridge_hum.volume_db = fridge_hum_volume_db
	_fridge_hum.max_distance = fridge_hum_max_distance
	_clock_tick.stream = CLOCK_TICK_STREAM
	_clock_tick.volume_db = clock_tick_volume_db
	_clock_tick.max_distance = clock_tick_max_distance

	_door_creak.stream = _select_pool_stream(&"door_creak_slow")
	_door_creak.max_distance = door_creak_max_distance

	_snack_pickup.stream = _select_pool_stream(&"snack_pickup_pantry")
	_snack_pickup.volume_db = snack_pickup_volume_db
	_snack_pickup.max_distance = 8.0
	_snack_drop.stream = SNACK_DROP_STREAM
	_snack_drop.volume_db = snack_drop_volume_db
	_snack_drop.max_distance = snack_drop_max_distance

	_voice.stream = _select_pool_stream(&"win_mmm")
	_voice.volume_db = voice_volume_db
	_wrapper_foley.stream = _select_pool_stream(&"wrapper_crinkle")
	_wrapper_foley.volume_db = wrapper_volume_db
	_wrapper_foley.max_distance = 8.0
	_fridge_pop.stream = _select_pool_stream(&"fridge_open_pop")
	_fridge_pop.volume_db = fridge_pop_volume_db
	_fridge_pop.max_distance = fridge_pop_max_distance
	_bathroom_foley.stream = _select_pool_stream(&"toilet_flush")
	_bathroom_foley.volume_db = bathroom_foley_volume_db
	_bathroom_foley.max_distance = bathroom_foley_max_distance


func _collect_doors() -> void:
	for door_path: NodePath in [
		bedroom_door_path,
		pantry_door_path,
		bathroom_door_path,
		fridge_path,
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
	if not _player.idle_giggled.is_connected(_on_player_idle_giggled):
		_player.idle_giggled.connect(_on_player_idle_giggled)
	var organic_reaction_callback: Callable = _on_player_organic_reaction
	if (
		_player.has_signal(&"organic_reaction_triggered")
		and not _player.is_connected(
			&"organic_reaction_triggered",
			organic_reaction_callback
		)
	):
		_player.connect(
			&"organic_reaction_triggered",
			organic_reaction_callback
		)
	if not _parent.state_changed.is_connected(_on_parent_state_changed):
		_parent.state_changed.connect(_on_parent_state_changed)
	if not _parent.curiosity_started.is_connected(_on_parent_curiosity_started):
		_parent.curiosity_started.connect(_on_parent_curiosity_started)
	if not _parent.player_caught.is_connected(_on_player_caught):
		_parent.player_caught.connect(_on_player_caught)
	if not _parent.player_deposited.is_connected(_on_player_deposited):
		_parent.player_deposited.connect(_on_player_deposited)
	if not _parent.epilogue_room_check_started.is_connected(
		_on_epilogue_room_check_started
	):
		_parent.epilogue_room_check_started.connect(
			_on_epilogue_room_check_started
		)
	if not _parent.epilogue_kid_protest.is_connected(_on_epilogue_kid_protest):
		_parent.epilogue_kid_protest.connect(_on_epilogue_kid_protest)
	if not _parent.bathroom_visit_started.is_connected(
		_on_bathroom_visit_started
	):
		_parent.bathroom_visit_started.connect(_on_bathroom_visit_started)
	if (
		_phase_director != null
		and not _phase_director.shutdown_errand_completed.is_connected(
			_on_shutdown_errand_completed
		)
	):
		_phase_director.shutdown_errand_completed.connect(
			_on_shutdown_errand_completed
		)
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
	_audio_epoch += 1
	_game_active = true
	_current_phase = GameClock.phase
	_tv_bed_shutdown = (
		_phase_director != null
		and _phase_director.is_shutdown_effect_applied(&"tv")
	)
	_speaker_bed_shutdown = (
		_phase_director != null
		and _phase_director.is_shutdown_effect_applied(&"kitchen")
	)
	_parent_step_distance_accumulated = 0.0
	_stop_chase_chain()
	_stop_carry_chain()
	_previous_routine_time = -0.001
	_wrapper_audio_elapsed = 0.0
	_organic_reaction_elapsed = maxf(organic_reaction_cooldown, 0.0)
	_organic_reaction_play_count = 0
	_snack_pickup_latched = false
	_snack_pickup_play_count = 0
	_routine_events_fired.clear()
	_sequence_group_generations.clear()
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	if _parent != null:
		_last_parent_position = _parent.global_position
	if _fridge != null:
		_fridge_previous_openness = _fridge.openness
		_fridge_was_opening = false
	_apply_ambient_phase()
	_restart_if_stopped(_fridge_hum)
	_restart_if_stopped(_clock_tick)
	_play_event(&"game_start")
	_game_start_line_play_count += 1


func _on_game_ended(did_win: bool) -> void:
	if _muted_for_a6_verification:
		return
	_game_active = false
	_audio_epoch += 1
	_sequence_group_generations.clear()
	_stop_chase_chain()
	_stop_carry_chain()
	_stop_ambient_beds()
	_stop_door_creak()
	_voice.stop()
	_voice_priority = 0
	_active_voice_pool = &""
	_wrapper_foley.stop()
	_fridge_pop.stop()
	_bathroom_foley.stop()
	_play_event(&"win" if did_win else &"lose", {}, true)


## Phase boundaries no longer fake shutdown clicks here (2026-07-24
## parent-initiated ruling): the real WorldSwitch or errand completion is
## the click. A backward scrub clears the bed flags so the ambience
## returns with its restored phase.
func _on_phase_changed(next_phase: int) -> void:
	_current_phase = clampi(next_phase, 0, 4)
	if _current_phase < 2:
		_tv_bed_shutdown = false
	if _current_phase < 3:
		_speaker_bed_shutdown = false
	if not _game_active:
		return
	_apply_ambient_phase()


## Real shutdown moments replace the old faked phase-boundary clicks. The
## kitchen/dining/foyer stops click through their own WorldSwitch; only
## the switchless living lamp and the TV console need a sound here. Bed
## flags apply on force-completions too (performed=false), silently.
func _on_shutdown_errand_completed(
	errand_id: StringName,
	performed: bool
) -> void:
	match errand_id:
		&"living":
			if performed and _game_active:
				_play_light_switch_at(living_switch_position)
		&"tv":
			_tv_bed_shutdown = true
			_tv_bed.stop()
			if performed and _game_active:
				_tv_click.play()
		&"kitchen":
			_speaker_bed_shutdown = true
			_speaker_bed.stop()


func _apply_ambient_phase() -> void:
	if not _game_active:
		return
	if _tv_bed_shutdown:
		_tv_bed.stop()
	else:
		_restart_if_stopped(_tv_bed)
	if _speaker_bed_shutdown:
		_speaker_bed.stop()
	else:
		_restart_if_stopped(_speaker_bed)


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
	_player_footsteps.global_position = _player.global_position
	if surface_multiplier >= _player.toys_surface_multiplier - 0.01:
		_player_footsteps.stream = TOY_SQUEAK_STREAM
		_player_footsteps.volume_db = toy_squeak_volume_db
	elif surface_multiplier >= _player.creaky_surface_multiplier - 0.01:
		# Director 2026-07-25: board steps groan long and low instead of
		# the short placeholder tick; the pool carries the lowered pitch.
		_player_footsteps.volume_db = creak_step_volume_db
		_play_pool(&"floor_creak_step")
		return
	elif surface_multiplier <= _player.carpet_surface_multiplier + 0.01:
		_player_footsteps.volume_db = (
			run_carpet_step_volume_db
			if Input.is_action_pressed("run")
			else carpet_step_volume_db
		)
		_play_pool(
			&"footstep_carpet_sprint"
			if Input.is_action_pressed("run")
			else &"footstep_carpet_walk"
		)
		return
	else:
		_player_footsteps.volume_db = (
			run_hardwood_step_volume_db
			if Input.is_action_pressed("run")
			else hardwood_step_volume_db
		)
		_play_pool(&"footstep_wood")
		return
	_player_footsteps.pitch_scale = _rng.randf_range(0.92, 1.08)
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
	_play_pool(&"parent_footstep")


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
	_door_creak.global_position = _get_door_hinge_position(moving_door)
	var rush_weight: float = moving_door.get_creak_rate_weight()
	if not _door_creak.playing:
		_play_pool(
			&"door_creak_fast"
			if rush_weight >= 0.5
			else &"door_creak_slow"
		)
	_door_creak.pitch_scale = moving_door.get_creak_pitch_scale()
	_door_creak.volume_db = moving_door.get_creak_volume_db()


func _stop_door_creak() -> void:
	if _door_creak.playing:
		_door_creak.stop()


func _on_parent_state_changed(state_name: StringName) -> void:
	if not _game_active:
		return
	if state_name == &"FOUND":
		_stop_carry_chain()
		_play_event(&"found")
		_start_chase_chain()
		return
	_stop_chase_chain()
	if state_name != &"CARRY":
		_stop_carry_chain()
	if state_name == &"INVESTIGATE" or state_name == &"HUNT":
		_play_event(&"investigate")


func _on_parent_curiosity_started(_sound_position: Vector3) -> void:
	if _game_active:
		_play_event(&"curiosity")


func _on_player_idle_giggled(_giggle_position: Vector3) -> void:
	if _game_active:
		_play_event(&"idle_giggle")


func _on_player_organic_reaction(
	_trigger_kind: StringName,
	_world_position: Vector3
) -> void:
	if (
		not _game_active
		or _player == null
		or _player.input_locked
		or _organic_reaction_elapsed < maxf(organic_reaction_cooldown, 0.0)
		or _voice.playing
		or _rng.randf() > clampf(organic_reaction_chance, 0.0, 1.0)
	):
		return
	if _play_pool(&"kid_organic_reaction"):
		_organic_reaction_elapsed = 0.0
		_organic_reaction_play_count += 1


func _on_player_caught(catch_position: Vector3, had_snack: bool) -> void:
	if _game_active:
		_stop_chase_chain()
		_start_carry_chain(catch_position, had_snack)
		_play_event(&"catch", {&"had_snack": had_snack})


func _on_player_deposited() -> void:
	if _game_active:
		_stop_carry_chain()
		_play_event(&"deposit")


## Signal-driven so the toilet/sink sequence follows the parent's actual
## visit; the old wall-clock ROUTINE_EVENTS row expired silently whenever
## the 189.4-204.4 s window passed while the parent was off ROUTINE.
func _on_bathroom_visit_started() -> void:
	if _game_active:
		_play_event(&"bathroom_visit")


func _on_epilogue_room_check_started() -> void:
	if _game_active or _b14_verification:
		_play_event(&"epilogue_room_check", {}, _b14_verification)


func _on_epilogue_kid_protest() -> void:
	if _game_active or _b14_verification:
		_play_event(&"epilogue_kid_protest", {}, _b14_verification)


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
	_play_event(&"dog_attention")


func _on_snack_picked_up(_carrier: DinnerPlayer) -> void:
	if not _game_active or _snack_pickup_latched:
		return
	_snack_pickup_latched = true
	_snack_pickup_play_count += 1
	_wrapper_audio_elapsed = 0.0
	_snack_pickup.global_position = _carrier.global_position
	if (
		_snack != null
		and _snack.snack_type == DinnerSnack.TYPE_ICE_CREAM
	):
		_play_pool(&"snack_pickup_fridge_scoop")
		_play_pool(&"snack_pickup_fridge_voice")
	else:
		_play_pool(&"snack_pickup_pantry")


func _on_snack_dropped(drop_position: Vector3) -> void:
	_snack_pickup_latched = false
	_wrapper_audio_elapsed = 0.0
	_wrapper_foley.stop()
	if not _game_active:
		return
	_snack_drop.global_position = drop_position
	_snack_drop.play()
	_play_pool(&"snack_drop_voice")


func _on_tv_bed_finished() -> void:
	if _game_active and not _tv_bed_shutdown:
		_tv_bed.play()


func _on_speaker_bed_finished() -> void:
	if _game_active and not _speaker_bed_shutdown:
		_speaker_bed.play()


func _on_fridge_hum_finished() -> void:
	if _game_active:
		_play_pool(&"fridge_hum")


func _on_clock_tick_finished() -> void:
	if _game_active:
		_clock_tick.play()


func _play_event(
	event_id: StringName,
	context: Dictionary = {},
	allow_inactive: bool = false
) -> void:
	var event_config: Dictionary = CASTING.EVENTS.get(event_id, {})
	if event_config.is_empty():
		return
	var group: StringName = event_config.get("group", event_id)
	var generation: int = int(_sequence_group_generations.get(group, 0)) + 1
	_sequence_group_generations[group] = generation
	var epoch: int = _audio_epoch
	var steps: Array = event_config.get("steps", [])
	for step_variant: Variant in steps:
		var step: Dictionary = step_variant as Dictionary
		var delay_seconds: float = float(step.get("delay_ms", 0)) / 1000.0
		if delay_seconds <= 0.0:
			_play_event_step(
				step,
				context,
				group,
				generation,
				epoch,
				allow_inactive
			)
			continue
		var timer: SceneTreeTimer = get_tree().create_timer(delay_seconds)
		timer.timeout.connect(
			_play_event_step.bind(
				step.duplicate(),
				context.duplicate(),
				group,
				generation,
				epoch,
				allow_inactive
			),
			CONNECT_ONE_SHOT
		)


func _play_event_step(
	step: Dictionary,
	context: Dictionary,
	group: StringName,
	generation: int,
	epoch: int,
	allow_inactive: bool
) -> void:
	if epoch != _audio_epoch:
		return
	if int(_sequence_group_generations.get(group, 0)) != generation:
		return
	if not _game_active and not allow_inactive:
		return
	if _rng.randf() > float(step.get("chance", 1.0)):
		return
	var pool_id: StringName = _resolve_step_pool(step, context)
	if pool_id != &"":
		_play_pool(pool_id, int(step.get("priority", -1)))


func _resolve_step_pool(step: Dictionary, context: Dictionary) -> StringName:
	if not step.has("context_key"):
		return step.get("pool", &"")
	var context_key: StringName = step.get("context_key", &"")
	return (
		step.get("true_pool", &"")
		if bool(context.get(context_key, false))
		else step.get("false_pool", &"")
	)


func _play_pool(pool_id: StringName, priority_override: int = -1) -> bool:
	var config: Dictionary = CASTING.POOLS.get(pool_id, {})
	if config.is_empty():
		return false
	var stream: AudioStream = _select_pool_stream(pool_id)
	if stream == null:
		return false
	var jitter: float = maxf(float(config.get("pitch_jitter", 0.0)), 0.0)
	var base_pitch: float = maxf(float(config.get("base_pitch", 1.0)), 0.01)
	var pitch: float = base_pitch * _rng.randf_range(
		1.0 - jitter,
		1.0 + jitter
	)
	var volume_offset_db: float = float(config.get("volume_offset_db", 0.0))
	var channel: StringName = config.get("channel", &"")
	match channel:
		&"voice":
			var priority: int = (
				priority_override
				if priority_override >= 0
				else int(config.get("priority", 0))
			)
			if _voice.playing and priority < _voice_priority:
				return false
			_voice.stream = stream
			_voice.pitch_scale = pitch
			_voice.volume_db = voice_volume_db + volume_offset_db
			_voice_priority = priority
			_active_voice_pool = pool_id
			_voice.play()
			if (
				config.get("speaker", &"") == &"parent"
				and _parent != null
			):
				_parent.show_parent_voice_indicator()
		&"caught_sting":
			_caught_sting.stream = stream
			_caught_sting.pitch_scale = pitch
			_caught_sting.play()
		&"win_sting":
			_win_sting.stream = stream
			_win_sting.pitch_scale = pitch
			_win_sting.play()
		&"player_footsteps":
			_player_footsteps.stream = stream
			_player_footsteps.pitch_scale = pitch
			_player_footsteps.play()
		&"parent_footsteps":
			_parent_footsteps.stream = stream
			_parent_footsteps.pitch_scale = pitch
			_parent_footsteps.play()
		&"door_creak":
			_door_creak.stream = stream
			_door_creak.pitch_scale = pitch
			_door_creak.play()
		&"fridge_hum":
			_fridge_hum.stream = stream
			_fridge_hum.pitch_scale = pitch
			_fridge_hum.play()
		&"fridge_pop":
			_fridge_pop.stream = stream
			_fridge_pop.pitch_scale = pitch
			_fridge_pop.play()
		&"snack_pickup":
			_snack_pickup.stream = stream
			_snack_pickup.pitch_scale = pitch
			_snack_pickup.volume_db = (
				snack_pickup_volume_db + volume_offset_db
			)
			_snack_pickup.play()
		&"wrapper":
			if _wrapper_foley.playing:
				return false
			_wrapper_foley.stream = stream
			_wrapper_foley.pitch_scale = pitch
			_wrapper_foley.volume_db = wrapper_volume_db + volume_offset_db
			if _player != null:
				_wrapper_foley.global_position = _player.global_position
			_wrapper_foley.play()
		&"bathroom":
			_bathroom_foley.stream = stream
			_bathroom_foley.pitch_scale = pitch
			_bathroom_foley.play()
		_:
			return false
	return true


func is_voice_pool_playing(pool_id: StringName) -> bool:
	return _voice.playing and _pool_contains_stream(pool_id, _voice.stream)


func _get_door_hinge_position(door: DinnerDoor) -> Vector3:
	return door.get_hinge_global_position()


func _select_pool_stream(pool_id: StringName) -> AudioStream:
	var config: Dictionary = CASTING.POOLS.get(pool_id, {})
	if config.is_empty():
		return null
	var streams: Array = config.get("streams", [])
	if streams.is_empty():
		return config.get("fallback") as AudioStream
	var selected_index: int = 0
	var last_index: int = int(_pool_last_indices.get(pool_id, -1))
	if streams.size() == 1:
		selected_index = 0
	elif last_index < 0 or last_index >= streams.size():
		selected_index = _rng.randi_range(0, streams.size() - 1)
	else:
		selected_index = _rng.randi_range(0, streams.size() - 2)
		if selected_index >= last_index:
			selected_index += 1
	_pool_last_indices[pool_id] = selected_index
	return streams[selected_index] as AudioStream


func _pool_contains_stream(pool_id: StringName, stream: AudioStream) -> bool:
	var config: Dictionary = CASTING.POOLS.get(pool_id, {})
	var streams: Array = config.get("streams", [])
	if streams.has(stream):
		return true
	return config.get("fallback") == stream


func _update_fridge_pop(delta: float) -> void:
	if _fridge == null:
		return
	var current_openness: float = _fridge.openness
	var opening_rate: float = (
		current_openness - _fridge_previous_openness
	) / maxf(delta, 0.001)
	_fridge_previous_openness = current_openness
	var is_opening: bool = opening_rate > 0.01
	if is_opening and not _fridge_was_opening:
		_fridge_pop.global_position = _get_door_hinge_position(_fridge)
		_play_pool(&"fridge_open_pop")
	_fridge_was_opening = is_opening


func _update_routine_events() -> void:
	if _parent == null:
		return
	var routine_time: float = clampf(
		GameClock.run_length - GameClock.time_remaining,
		0.0,
		GameClock.run_length
	)
	if routine_time < _previous_routine_time:
		_routine_events_fired.clear()
	_previous_routine_time = routine_time
	if _parent.get_state_name() != &"ROUTINE":
		return
	for event_index: int in range(CASTING.ROUTINE_EVENTS.size()):
		if bool(_routine_events_fired.get(event_index, false)):
			continue
		var event_row: Dictionary = CASTING.ROUTINE_EVENTS[event_index]
		var event_time: float = float(event_row.get("time", 0.0))
		var event_window: float = float(event_row.get("window", 0.0))
		if routine_time > event_time + event_window:
			_routine_events_fired[event_index] = true
			continue
		if routine_time >= event_time:
			_routine_events_fired[event_index] = true
			_play_event(event_row.get("event", &""))


func _start_chase_chain() -> void:
	_chase_chain_active = true
	_chase_voice_gap_remaining = 0.0


func _stop_chase_chain() -> void:
	_chase_chain_active = false
	_chase_voice_gap_remaining = 0.0
	if _active_voice_pool == &"fun_giggle":
		_voice.stop()
		_voice_priority = 0
		_active_voice_pool = &""


func _update_chase_voice(delta: float) -> void:
	if not _chase_chain_active:
		return
	if _parent == null or _parent.get_state_name() != &"FOUND":
		_stop_chase_chain()
		return
	_chase_voice_gap_remaining = maxf(
		_chase_voice_gap_remaining - delta,
		0.0
	)
	if _voice.playing or _chase_voice_gap_remaining > 0.0:
		return
	_play_next_chase_giggle()


func _play_next_chase_giggle() -> bool:
	if not _chase_chain_active:
		return false
	return _play_pool(&"fun_giggle")


func _start_carry_chain(catch_position: Vector3, had_snack: bool) -> void:
	_carry_chain_active = true
	_carry_had_snack = had_snack
	_carry_voice_gap_remaining = 0.45
	_carry_elapsed = 0.0
	_carry_protest_count = 0
	_carry_parent_grunt_count = 0
	_carry_next_parent_grunt_at = _random_carry_grunt_interval()
	_carry_start_distance = 0.0
	if _crib != null:
		var catch_delta: Vector3 = _crib.global_position - catch_position
		catch_delta.y = 0.0
		_carry_start_distance = catch_delta.length()


func _stop_carry_chain() -> void:
	_carry_chain_active = false
	_carry_voice_gap_remaining = 0.0
	if _is_carry_voice_pool(_active_voice_pool):
		_voice.stop()
		_voice_priority = 0
		_active_voice_pool = &""


func _update_carry_voice(delta: float) -> void:
	if not _carry_chain_active:
		return
	if _parent == null or _parent.get_state_name() != &"CARRY":
		_stop_carry_chain()
		return
	_carry_elapsed += delta
	_carry_voice_gap_remaining = maxf(
		_carry_voice_gap_remaining - delta,
		0.0
	)
	if _voice.playing or _carry_voice_gap_remaining > 0.0:
		return
	_play_next_carry_voice()


func _play_next_carry_voice() -> bool:
	if not _carry_chain_active:
		return false
	var pool_id: StringName
	if (
		_carry_protest_count > 0
		and _carry_elapsed >= _carry_next_parent_grunt_at
	):
		pool_id = (
			&"parent_carry_grunt_red_handed"
			if _carry_had_snack
			else &"parent_carry_grunt_empty_handed"
		)
		_carry_parent_grunt_count += 1
		_carry_next_parent_grunt_at = (
			_carry_elapsed + _random_carry_grunt_interval()
		)
	else:
		pool_id = (
			&"carry_red_handed"
			if _carry_had_snack
			else &"carry_empty_handed"
		)
		_carry_protest_count += 1
	return _play_pool(pool_id)


func _random_carry_grunt_interval() -> float:
	return _rng.randf_range(
		minf(
			carry_parent_grunt_interval_min,
			carry_parent_grunt_interval_max
		),
		maxf(
			carry_parent_grunt_interval_min,
			carry_parent_grunt_interval_max
		)
	)


func _random_chained_voice_gap() -> float:
	return _rng.randf_range(
		minf(chained_voice_gap_min, chained_voice_gap_max),
		maxf(chained_voice_gap_min, chained_voice_gap_max)
	)


func _is_carry_voice_pool(pool_id: StringName) -> bool:
	return pool_id in [
		&"carry_red_handed",
		&"carry_empty_handed",
		&"parent_carry_grunt_red_handed",
		&"parent_carry_grunt_empty_handed",
	]


func _update_wrapper_audio(delta: float) -> void:
	if _player == null or not _player.carrying_snack:
		_wrapper_audio_elapsed = 0.0
		return
	_wrapper_audio_elapsed += delta
	var safe_interval: float = maxf(wrapper_audio_interval, 0.1)
	if _wrapper_audio_elapsed < safe_interval:
		return
	_wrapper_audio_elapsed = fmod(_wrapper_audio_elapsed, safe_interval)
	var carried_pool: StringName = &"wrapper_crinkle"
	if (
		_snack != null
		and _snack.snack_type == DinnerSnack.TYPE_ICE_CREAM
	):
		carried_pool = &"ice_cream_carry"
	_play_pool(carried_pool)


func verify_a20_snack_audio_skin() -> void:
	var original_type: StringName = _snack.snack_type
	var original_carrying: bool = _player.carrying_snack
	var original_game_active: bool = _game_active
	var noise_count_before: int = _verification_noise_count
	_verification_noise_count = 0
	NoiseSystem.noise_emitted.connect(_capture_verification_noise)
	_on_game_started()

	_snack.set_snack_type(DinnerSnack.TYPE_CHIPS)
	_snack_pickup_latched = false
	_voice.stop()
	_voice_priority = 0
	_on_snack_picked_up(_player)
	assert(_pool_contains_stream(&"snack_pickup_pantry", _snack_pickup.stream))
	assert(
		not _pool_contains_stream(
			&"snack_pickup_fridge_scoop",
			_snack_pickup.stream
		)
	)
	assert(not is_voice_pool_playing(&"snack_pickup_fridge_voice"))

	_snack.set_snack_type(DinnerSnack.TYPE_ICE_CREAM)
	_snack_pickup_latched = false
	_snack_pickup.stop()
	_voice.stop()
	_voice_priority = 0
	_on_snack_picked_up(_player)
	assert(
		_pool_contains_stream(
			&"snack_pickup_fridge_scoop",
			_snack_pickup.stream
		)
	)
	assert(is_voice_pool_playing(&"snack_pickup_fridge_voice"))
	assert(
		not _pool_contains_stream(&"wrapper_crinkle", _snack_pickup.stream),
		"Fridge pickup routed a crinkle."
	)

	_player.set_carrying_snack(true)
	_snack.set_snack_type(DinnerSnack.TYPE_CHIPS)
	_wrapper_foley.stop()
	_wrapper_audio_elapsed = wrapper_audio_interval
	_update_wrapper_audio(0.0)
	assert(_pool_contains_stream(&"wrapper_crinkle", _wrapper_foley.stream))
	assert(is_equal_approx(_wrapper_foley.volume_db, wrapper_volume_db))

	_snack.set_snack_type(DinnerSnack.TYPE_ICE_CREAM)
	_wrapper_foley.stop()
	_wrapper_audio_elapsed = wrapper_audio_interval
	_update_wrapper_audio(0.0)
	assert(_pool_contains_stream(&"ice_cream_carry", _wrapper_foley.stream))
	assert(_wrapper_foley.volume_db < wrapper_volume_db)
	assert(
		not _pool_contains_stream(&"wrapper_crinkle", _wrapper_foley.stream),
		"Ice-cream carry routed a crinkle."
	)
	assert(is_equal_approx(_player.snack_noise_loudness, 0.3))
	assert(is_equal_approx(_player.snack_noise_interval, 0.6))
	assert(
		_verification_noise_count == 0,
		"Audio skin emitted gameplay noise; Player must remain sole authority."
	)

	NoiseSystem.noise_emitted.disconnect(_capture_verification_noise)
	_verification_noise_count = noise_count_before
	_snack.set_snack_type(original_type)
	_player.set_carrying_snack(original_carrying)
	_game_active = original_game_active
	_snack_pickup_latched = false


func _on_voice_finished() -> void:
	_voice_priority = 0
	_active_voice_pool = &""
	if _carry_chain_active:
		_carry_voice_gap_remaining = _random_chained_voice_gap()
	elif _chase_chain_active:
		_chase_voice_gap_remaining = _random_chained_voice_gap()


func _capture_verification_noise(
	_position: Vector3,
	_loudness: float,
	_source: Node
) -> void:
	_verification_noise_count += 1


func _restart_if_stopped(audio_player: Node) -> void:
	if not bool(audio_player.get("playing")):
		audio_player.call("play")


func _stop_ambient_beds() -> void:
	_tv_bed.stop()
	_speaker_bed.stop()
	_fridge_hum.stop()
	_clock_tick.stop()
