extends RefCounted
class_name DinnerAudioCasting

## A15's casting and sequencing table. Runtime filenames are deliberately
## anonymous; the generic kid-* and parent-* files in assets/voice/picks remain
## the director's named source of truth.

const POOLS: Dictionary = {
	&"parent_investigate": {
		"streams": [
			preload("res://audio/denoised/voice/parent_investigate_01.ogg"),
			preload("res://audio/denoised/voice/parent_investigate_02.ogg"),
			preload("res://audio/denoised/voice/parent_investigate_03.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 2,
		"pitch_jitter": 0.05,
	},
	&"parent_found_call": {
		"streams": [
			preload("res://audio/denoised/voice/parent_found_call_01.ogg"),
			preload("res://audio/denoised/voice/parent_found_call_02.ogg"),
			preload("res://audio/denoised/voice/parent_found_call_03.ogg"),
			preload("res://audio/denoised/voice/parent_found_call_04.ogg"),
			preload("res://audio/denoised/voice/parent_found_call_05.ogg"),
			preload("res://audio/denoised/voice/parent_found_call_06.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 2,
		"pitch_jitter": 0.05,
	},
	&"parent_bed_check": {
		"streams": [
			preload("res://audio/denoised/voice/parent_bed_check_02.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_couch_mutter": {
		"streams": [
			preload("res://audio/denoised/voice/parent_couch_mutter_01.ogg"),
			preload("res://audio/denoised/voice/parent_couch_mutter_02.ogg"),
			preload("res://audio/denoised/voice/parent_couch_mutter_03.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_kitchen_intent": {
		"streams": [
			preload("res://audio/denoised/voice/parent_kitchen_intent_01.ogg"),
			preload("res://audio/denoised/voice/parent_kitchen_intent_02.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_dog_attention": {
		"streams": [
			preload("res://audio/denoised/voice/parent_dog_attention_01.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_carry_grunt_red_handed": {
		"streams": [
			preload("res://audio/denoised/voice/parent_grunt_02.ogg"),
			preload("res://audio/denoised/voice/parent_grunt_03.ogg"),
			preload("res://audio/denoised/voice/parent_grunt_04.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"parent_carry_grunt_empty_handed": {
		"streams": [
			preload("res://audio/denoised/voice/parent_grunt_07.ogg"),
		],
		"channel": &"voice",
		"speaker": &"parent",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"game_start_motivation": {
		"streams": [
			preload("res://audio/denoised/voice/carry_red_handed_01.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 3,
		"pitch_jitter": 0.05,
	},
	&"carry_red_handed": {
		"streams": [
			preload("res://audio/denoised/voice/carry_red_handed_02.ogg"),
			preload("res://audio/denoised/voice/carry_red_handed_03.ogg"),
			preload("res://audio/denoised/voice/carry_red_handed_04.ogg"),
			preload("res://audio/denoised/voice/carry_red_handed_05.ogg"),
			preload("res://audio/denoised/voice/carry_red_handed_06.ogg"),
			preload("res://audio/denoised/voice/carry_red_handed_08.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 4,
		"pitch_jitter": 0.06,
	},
	&"carry_empty_handed": {
		"streams": [
			preload("res://audio/denoised/voice/carry_empty_handed_01.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_02.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_03.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_04.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_05.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_06.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_07.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 4,
		"pitch_jitter": 0.06,
	},
	&"kid_room_protest": {
		"streams": [
			preload("res://audio/denoised/voice/carry_empty_handed_01.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_02.ogg"),
			preload("res://audio/denoised/voice/carry_empty_handed_03.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 4,
		"pitch_jitter": 0.06,
	},
	&"caught_reaction": {
		"streams": [
			preload("res://audio/denoised/voice/caught_grunt_03.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 3,
		"pitch_jitter": 0.06,
	},
	&"kid_organic_reaction": {
		"streams": [
			preload("res://audio/denoised/voice/caught_grunt_01.ogg"),
			# Director override: this 0.38 s reaction has no clean profile
			# window, so A18 kept its untouched generic runtime copy.
			preload("res://audio/original/voice/caught_grunt_02.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 2,
		"pitch_jitter": 0.06,
	},
	&"fun_giggle": {
		"streams": [
			preload("res://audio/denoised/voice/chase_giggle_01.ogg"),
			preload("res://audio/denoised/voice/chase_giggle_02.ogg"),
			preload("res://audio/denoised/voice/chase_giggle_03.ogg"),
			preload("res://audio/denoised/voice/win_giggle_01.ogg"),
			preload("res://audio/denoised/voice/win_giggle_02.ogg"),
			preload("res://audio/denoised/voice/win_giggle_03.ogg"),
			preload("res://audio/denoised/voice/win_giggle_04.ogg"),
			preload("res://audio/denoised/voice/win_giggle_05.ogg"),
			preload("res://audio/denoised/voice/win_giggle_06.ogg"),
			preload("res://audio/denoised/voice/win_giggle_07.ogg"),
			preload("res://audio/denoised/voice/win_giggle_08.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 1,
		"pitch_jitter": 0.06,
	},
	&"idle_giggle": {
		"streams": [
			preload("res://audio/denoised/voice/chase_giggle_01.ogg"),
			preload("res://audio/denoised/voice/chase_giggle_02.ogg"),
			preload("res://audio/denoised/voice/chase_giggle_03.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.06,
		"volume_offset_db": -8.0,
	},
	&"win_mmm": {
		"streams": [
			preload("res://audio/denoised/voice/win_mmm_01.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"snack_pickup_fridge_voice": {
		"streams": [
			preload("res://audio/denoised/voice/win_mmm_01.ogg"),
		],
		"channel": &"voice",
		"speaker": &"kid",
		"priority": 3,
		"pitch_jitter": 0.05,
		"volume_offset_db": -2.0,
	},
	&"deposit_sniffle": {
		"streams": [
			preload("res://audio/denoised/voice/deposit_sniffle_01.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"deposit_reconcile": {
		"streams": [
			preload("res://audio/denoised/voice/deposit_reconcile_01.ogg"),
			preload("res://audio/denoised/voice/deposit_reconcile_02.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	# Director 2026-07-25: wrapper_shush_01.ogg is CUT. It had no live trigger
	# either — the only step that referenced it lived on the wrapper_noise
	# event, which nothing plays (AudioDirector drives wrapper audio straight
	# from _update_wrapper_audio). Removed so the audition page and the code
	# agree.
	&"snack_drop_voice": {
		"streams": [
			preload("res://audio/denoised/voice/snack_drop_voice_01.ogg"),
		],
		"channel": &"voice",
		"priority": 3,
		"pitch_jitter": 0.05,
	},
	&"caught_sting": {
		"streams": [],
		"fallback": preload("res://audio/sfx/caught_sting.ogg"),
		"channel": &"caught_sting",
		"pitch_jitter": 0.0,
	},
	&"win_sting": {
		"streams": [],
		"fallback": preload("res://audio/sfx/win_sting.ogg"),
		"channel": &"win_sting",
		"pitch_jitter": 0.0,
	},
	&"door_creak_fast": {
		"streams": [
			preload("res://audio/original/foley/door_creak_fast_01.ogg"),
			preload("res://audio/original/foley/door_creak_fast_02.ogg"),
			preload("res://audio/denoised/foley/door_creak_fast_03.ogg"),
			preload("res://audio/original/foley/door_creak_fast_04.ogg"),
			preload("res://audio/original/foley/door_creak_fast_05.ogg"),
			preload("res://audio/original/foley/door_creak_fast_06.ogg"),
			preload("res://audio/original/foley/door_creak_fast_07.ogg"),
			preload("res://audio/original/foley/door_creak_fast_08.ogg"),
			preload("res://audio/original/foley/door_creak_fast_09.ogg"),
		],
		"fallback": preload("res://audio/sfx/door_creak.ogg"),
		"channel": &"door_creak",
		"pitch_jitter": 0.08,
	},
	&"door_creak_slow": {
		"streams": [
			preload("res://audio/original/foley/door_creak_slow_01.ogg"),
			preload("res://audio/original/foley/door_creak_slow_02.ogg"),
			preload("res://audio/original/foley/door_creak_slow_03.ogg"),
			preload("res://audio/denoised/foley/door_creak_slow_04.ogg"),
		],
		"fallback": preload("res://audio/sfx/door_creak.ogg"),
		"channel": &"door_creak",
		"pitch_jitter": 0.08,
		## Director 2026-07-25: eased-open doors should groan lower and longer.
		"base_pitch": 0.85,
	},
	&"footstep_carpet_walk": {
		"streams": [
			# Director cut 05-08 on 2026-07-25: too loud and rough for a sneak.
			preload("res://audio/cc0/footsteps/carpet_01.wav"),
			preload("res://audio/cc0/footsteps/carpet_02.wav"),
			preload("res://audio/cc0/footsteps/carpet_03.wav"),
			preload("res://audio/cc0/footsteps/carpet_04.wav"),
		],
		"fallback": preload("res://audio/sfx/player_step_carpet.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.08,
	},
	&"footstep_carpet_sprint": {
		"streams": [
			# Director cut 05-08 on 2026-07-25: too loud and rough for a sneak.
			preload("res://audio/cc0/footsteps/carpet_01.wav"),
			preload("res://audio/cc0/footsteps/carpet_02.wav"),
			preload("res://audio/cc0/footsteps/carpet_03.wav"),
			preload("res://audio/cc0/footsteps/carpet_04.wav"),
		],
		"fallback": preload("res://audio/sfx/player_step_carpet.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.08,
	},
	&"footstep_wood": {
		"streams": [
			preload("res://audio/cc0/footsteps/wood_01.wav"),
			preload("res://audio/cc0/footsteps/wood_02.wav"),
			preload("res://audio/cc0/footsteps/wood_03.wav"),
			preload("res://audio/cc0/footsteps/wood_04.wav"),
			preload("res://audio/cc0/footsteps/wood_05.wav"),
			preload("res://audio/cc0/footsteps/wood_06.wav"),
			preload("res://audio/cc0/footsteps/wood_07.wav"),
			preload("res://audio/cc0/footsteps/wood_08.wav"),
		],
		"fallback": preload("res://audio/sfx/player_step_hardwood.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.08,
	},
	# Director 2026-07-25: a creaky-board step is a drawn-out wooden groan,
	# not a tick — the recorded slow door-creak takes at a lowered pitch,
	# kept distinct from the door context by pitch and position. The
	# original foley takes are sanctioned by the door_creak_ allowlist.
	&"floor_creak_step": {
		"streams": [
			preload("res://audio/original/foley/door_creak_slow_01.ogg"),
			preload("res://audio/original/foley/door_creak_slow_02.ogg"),
			preload("res://audio/original/foley/door_creak_slow_03.ogg"),
			preload("res://audio/denoised/foley/door_creak_slow_04.ogg"),
		],
		"fallback": preload("res://audio/sfx/player_step_creak.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.07,
		## Director 2026-07-25: "needs to play even slower" — 0.8 -> 0.65.
		"base_pitch": 0.65,
	},
	# Director 2026-07-25: the extracted family toy-squeak takes replace the
	# placeholder squeak tick on the same footstep voice at the same
	# exported volume. Their clips/ directory is sanctioned by the family
	# allowlists in AudioDirector.verify_configuration and the a18 sweep.
	# The listening pass kept 30 of the 66 re-extracted takes.
	&"toy_squeak": {
		## 66 family toy takes, re-extracted 2026-07-25 from the raw home
		## recordings and verified as OGG Vorbis against a real directory
		## listing. Prune by ear: delete any preload line below — no pool
		## size is asserted by any gate.
		## Director's listening pass 2026-07-25 cut 36 of the 66 takes; these
		## 30 are the keepers.
		"streams": [
			preload("res://audio/family/toys/clips/toy_squeak_02.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_04.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_11.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_12.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_15.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_17.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_18.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_19.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_20.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_21.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_22.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_23.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_25.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_32.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_33.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_34.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_35.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_36.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_37.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_39.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_40.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_41.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_42.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_43.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_44.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_45.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_53.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_57.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_62.ogg"),
			preload("res://audio/family/toys/clips/toy_squeak_63.ogg"),
		],
		"fallback": preload("res://audio/sfx/toy_squeak.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.05,
	},
	# Director's listening pass 2026-07-25 reversed the dog routing: dog_02.ogg
	# moves to the Pet's notice cue ("the only dog noise except for the bark"),
	# and the bark that pulls the parent in is the CC0 pet_bark take again
	# ("this should be the sound when the dog is alerted"). Empty streams fall
	# through to the fallback — the same idiom the sting and hum pools use.
	&"pet_bark": {
		"streams": [],
		"fallback": preload("res://audio/sfx/pet_bark.ogg"),
		"channel": &"pet_bark",
		"pitch_jitter": 0.07,
	},
	&"parent_footstep": {
		## Director 2026-07-25: the parent walks on the same recordings the kid
		## does — one house, one floor.
		"streams": [
			preload("res://audio/cc0/footsteps/wood_01.wav"),
			preload("res://audio/cc0/footsteps/wood_02.wav"),
			preload("res://audio/cc0/footsteps/wood_03.wav"),
			preload("res://audio/cc0/footsteps/wood_04.wav"),
			preload("res://audio/cc0/footsteps/wood_05.wav"),
			preload("res://audio/cc0/footsteps/wood_06.wav"),
			preload("res://audio/cc0/footsteps/wood_07.wav"),
			preload("res://audio/cc0/footsteps/wood_08.wav"),
		],
		"fallback": preload("res://audio/sfx/parent_step.ogg"),
		"channel": &"parent_footsteps",
		"pitch_jitter": 0.08,
	},
	&"fridge_hum": {
		"streams": [],
		"fallback": preload("res://audio/ambience/fridge_hum.ogg"),
		"channel": &"fridge_hum",
		"pitch_jitter": 0.05,
	},
	&"fridge_open_pop": {
		"streams": [],
		"fallback": preload("res://audio/sfx/snack_pickup.ogg"),
		"channel": &"fridge_pop",
		"pitch_jitter": 0.06,
	},
	&"snack_pickup_pantry": {
		"streams": [],
		"fallback": preload("res://audio/sfx/snack_pickup.ogg"),
		"channel": &"snack_pickup",
		"pitch_jitter": 0.06,
	},
	&"snack_pickup_fridge_scoop": {
		"streams": [],
		"fallback": preload("res://audio/sfx/snack_drop.ogg"),
		"channel": &"snack_pickup",
		"pitch_jitter": 0.06,
		"base_pitch": 1.3,
		"volume_offset_db": -12.0,
	},
	&"wrapper_crinkle": {
		"streams": [
			preload("res://audio/denoised/foley/wrapper_crinkle_01.ogg"),
			preload("res://audio/denoised/foley/wrapper_crinkle_02.ogg"),
		],
		"channel": &"wrapper",
		"pitch_jitter": 0.08,
	},
	&"ice_cream_carry": {
		"streams": [],
		"fallback": preload("res://audio/sfx/snack_drop.ogg"),
		"channel": &"wrapper",
		"pitch_jitter": 0.08,
		"base_pitch": 1.55,
		"volume_offset_db": -8.0,
	},
	&"sink_running": {
		"streams": [
			preload("res://audio/denoised/foley/sink_running_01.ogg"),
		],
		"channel": &"bathroom",
		"pitch_jitter": 0.05,
	},
	&"toilet_flush": {
		"streams": [
			preload("res://audio/denoised/foley/toilet_flush_01.ogg"),
		],
		"channel": &"bathroom",
		"pitch_jitter": 0.05,
	},
}

const EVENTS: Dictionary = {
	&"game_start": {
		"group": &"game_start",
		"steps": [{"pool": &"game_start_motivation", "delay_ms": 0}],
	},
	&"curiosity": {
		"group": &"parent_state",
		"steps": [{"pool": &"parent_investigate", "delay_ms": 0}],
	},
	&"idle_giggle": {
		"group": &"kid_idle",
		"steps": [{"pool": &"idle_giggle", "delay_ms": 0}],
	},
	&"investigate": {
		"group": &"parent_state",
		"steps": [{"pool": &"parent_investigate", "delay_ms": 0}],
	},
	&"found": {
		"group": &"parent_state",
		"steps": [{"pool": &"parent_found_call", "delay_ms": 0}],
	},
	&"catch": {
		"group": &"carry_flow",
		"steps": [
			{"pool": &"caught_sting", "delay_ms": 0},
			{"pool": &"caught_reaction", "delay_ms": 120},
		],
	},
	&"deposit": {
		"group": &"carry_flow",
		"steps": [
			{"pool": &"deposit_sniffle", "delay_ms": 0},
			{"pool": &"deposit_reconcile", "delay_ms": 1700},
		],
	},
	&"win": {
		"group": &"result",
		"steps": [
			{"pool": &"win_mmm", "delay_ms": 0},
			{"pool": &"fun_giggle", "delay_ms": 1050, "priority": 4},
		],
	},
	&"lose": {
		"group": &"result",
		"steps": [{"pool": &"deposit_sniffle", "delay_ms": 0}],
	},
	## Unplayed: AudioDirector drives carried-snack foley straight from
	## _update_wrapper_audio, not through this event. Kept as the declared
	## wrapper group; its cut shush step went with wrapper_shush.
	&"wrapper_noise": {
		"group": &"wrapper",
		"steps": [
			{"pool": &"wrapper_crinkle", "delay_ms": 0},
		],
	},
	&"bathroom_visit": {
		"group": &"bathroom",
		"steps": [
			{"pool": &"toilet_flush", "delay_ms": 0},
			{"pool": &"sink_running", "delay_ms": 9000},
		],
	},
	&"routine_couch": {
		"group": &"routine_voice",
		"steps": [{"pool": &"parent_couch_mutter", "delay_ms": 0}],
	},
	&"routine_kitchen": {
		"group": &"routine_voice",
		"steps": [{"pool": &"parent_kitchen_intent", "delay_ms": 0}],
	},
	&"routine_bed_check": {
		"group": &"routine_voice",
		"steps": [{"pool": &"parent_bed_check", "delay_ms": 0}],
	},
	&"epilogue_room_check": {
		"group": &"epilogue_room_voice",
		"steps": [{"pool": &"parent_bed_check", "delay_ms": 0}],
	},
	&"epilogue_kid_protest": {
		"group": &"epilogue_room_voice",
		"steps": [{"pool": &"kid_room_protest", "delay_ms": 0}],
	},
	&"dog_attention": {
		"group": &"parent_state",
		"steps": [{"pool": &"parent_dog_attention", "delay_ms": 250}],
	},
}

## bathroom_visit is deliberately absent here: a wall-clock row silently
## expired whenever an investigate held the parent off ROUTINE across its
## window. The parent now emits bathroom_visit_started at the real visit
## and AudioDirector plays the event from that signal.
const ROUTINE_EVENTS: Array[Dictionary] = [
	{"time": 0.0, "window": 8.0, "event": &"routine_couch"},
	{"time": 60.0, "window": 8.0, "event": &"routine_kitchen"},
	{"time": 82.0, "window": 8.0, "event": &"routine_couch"},
	{"time": 288.5, "window": 11.5, "event": &"routine_bed_check"},
]
