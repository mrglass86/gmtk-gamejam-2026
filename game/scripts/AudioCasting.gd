extends RefCounted
class_name DinnerAudioCasting

## A15's casting and sequencing table. Runtime filenames are deliberately
## anonymous; the generic kid-* and parent-* files in assets/voice/picks remain
## the director's named source of truth.

const POOLS: Dictionary = {
	&"parent_investigate": {
		"streams": [
			preload("res://audio/original/voice/parent_investigate_01.ogg"),
			preload("res://audio/original/voice/parent_investigate_02.ogg"),
			preload("res://audio/original/voice/parent_investigate_03.ogg"),
		],
		"channel": &"voice",
		"priority": 2,
		"pitch_jitter": 0.05,
	},
	&"parent_found_call": {
		"streams": [
			preload("res://audio/original/voice/parent_found_call_01.ogg"),
			preload("res://audio/original/voice/parent_found_call_02.ogg"),
			preload("res://audio/original/voice/parent_found_call_03.ogg"),
			preload("res://audio/original/voice/parent_found_call_04.ogg"),
			preload("res://audio/original/voice/parent_found_call_05.ogg"),
			preload("res://audio/original/voice/parent_found_call_06.ogg"),
		],
		"channel": &"voice",
		"priority": 2,
		"pitch_jitter": 0.05,
	},
	&"parent_bed_check": {
		"streams": [
			preload("res://audio/original/voice/parent_bed_check_01.ogg"),
			preload("res://audio/original/voice/parent_bed_check_02.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_couch_mutter": {
		"streams": [
			preload("res://audio/original/voice/parent_couch_mutter_01.ogg"),
			preload("res://audio/original/voice/parent_couch_mutter_02.ogg"),
			preload("res://audio/original/voice/parent_couch_mutter_03.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_kitchen_intent": {
		"streams": [
			preload("res://audio/original/voice/parent_kitchen_intent_01.ogg"),
			preload("res://audio/original/voice/parent_kitchen_intent_02.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_dog_attention": {
		"streams": [
			preload("res://audio/original/voice/parent_dog_attention_01.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.05,
	},
	&"parent_grunt": {
		"streams": [
			preload("res://audio/original/voice/parent_grunt_01.ogg"),
			preload("res://audio/original/voice/parent_grunt_02.ogg"),
			preload("res://audio/original/voice/parent_grunt_03.ogg"),
			preload("res://audio/original/voice/parent_grunt_04.ogg"),
			preload("res://audio/original/voice/parent_grunt_05.ogg"),
			preload("res://audio/original/voice/parent_grunt_06.ogg"),
			preload("res://audio/original/voice/parent_grunt_07.ogg"),
			preload("res://audio/original/voice/parent_grunt_08.ogg"),
		],
		"channel": &"voice",
		"priority": 2,
		"pitch_jitter": 0.05,
	},
	&"carry_red_handed": {
		"streams": [
			preload("res://audio/original/voice/carry_red_handed_01.ogg"),
			preload("res://audio/original/voice/carry_red_handed_02.ogg"),
			preload("res://audio/original/voice/carry_red_handed_03.ogg"),
			preload("res://audio/original/voice/carry_red_handed_04.ogg"),
			preload("res://audio/original/voice/carry_red_handed_05.ogg"),
			preload("res://audio/original/voice/carry_red_handed_06.ogg"),
			preload("res://audio/original/voice/carry_red_handed_07.ogg"),
			preload("res://audio/original/voice/carry_red_handed_08.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.06,
	},
	&"carry_empty_handed": {
		"streams": [
			preload("res://audio/original/voice/carry_empty_handed_01.ogg"),
			preload("res://audio/original/voice/carry_empty_handed_02.ogg"),
			preload("res://audio/original/voice/carry_empty_handed_03.ogg"),
			preload("res://audio/original/voice/carry_empty_handed_04.ogg"),
			preload("res://audio/original/voice/carry_empty_handed_05.ogg"),
			preload("res://audio/original/voice/carry_empty_handed_06.ogg"),
			preload("res://audio/original/voice/carry_empty_handed_07.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.06,
	},
	&"caught_grunt": {
		"streams": [
			preload("res://audio/original/voice/caught_grunt_01.ogg"),
			preload("res://audio/original/voice/caught_grunt_02.ogg"),
			preload("res://audio/original/voice/caught_grunt_03.ogg"),
		],
		"channel": &"voice",
		"priority": 2,
		"pitch_jitter": 0.06,
	},
	&"chase_giggle": {
		"streams": [
			preload("res://audio/original/voice/chase_giggle_01.ogg"),
			preload("res://audio/original/voice/chase_giggle_02.ogg"),
			preload("res://audio/original/voice/chase_giggle_03.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.06,
	},
	&"win_mmm": {
		"streams": [
			preload("res://audio/original/voice/win_mmm_01.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"win_giggle": {
		"streams": [
			preload("res://audio/original/voice/win_giggle_01.ogg"),
			preload("res://audio/original/voice/win_giggle_02.ogg"),
			preload("res://audio/original/voice/win_giggle_03.ogg"),
			preload("res://audio/original/voice/win_giggle_04.ogg"),
			preload("res://audio/original/voice/win_giggle_05.ogg"),
			preload("res://audio/original/voice/win_giggle_06.ogg"),
			preload("res://audio/original/voice/win_giggle_07.ogg"),
			preload("res://audio/original/voice/win_giggle_08.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.06,
	},
	&"deposit_sniffle": {
		"streams": [
			preload("res://audio/original/voice/deposit_sniffle_01.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"deposit_reconcile": {
		"streams": [
			preload("res://audio/original/voice/deposit_reconcile_01.ogg"),
			preload("res://audio/original/voice/deposit_reconcile_02.ogg"),
		],
		"channel": &"voice",
		"priority": 4,
		"pitch_jitter": 0.05,
	},
	&"wrapper_shush": {
		"streams": [
			preload("res://audio/original/voice/wrapper_shush_01.ogg"),
			preload("res://audio/original/voice/wrapper_shush_02.ogg"),
		],
		"channel": &"voice",
		"priority": 1,
		"pitch_jitter": 0.06,
	},
	&"snack_drop_voice": {
		"streams": [
			preload("res://audio/original/voice/snack_drop_voice_01.ogg"),
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
			preload("res://audio/original/foley/door_creak_fast_03.ogg"),
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
			preload("res://audio/original/foley/door_creak_slow_04.ogg"),
		],
		"fallback": preload("res://audio/sfx/door_creak.ogg"),
		"channel": &"door_creak",
		"pitch_jitter": 0.08,
	},
	&"footstep_carpet_walk": {
		"streams": [
			preload("res://audio/original/foley/footstep_carpet_walk_01.ogg"),
			preload("res://audio/original/foley/footstep_carpet_walk_02.ogg"),
		],
		"fallback": preload("res://audio/sfx/player_step_carpet.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.08,
	},
	&"footstep_carpet_sprint": {
		"streams": [
			preload("res://audio/original/foley/footstep_carpet_sprint_01.ogg"),
			preload("res://audio/original/foley/footstep_carpet_sprint_02.ogg"),
			preload("res://audio/original/foley/footstep_carpet_sprint_03.ogg"),
		],
		"fallback": preload("res://audio/sfx/player_step_carpet.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.08,
	},
	&"footstep_wood": {
		"streams": [
			preload("res://audio/original/foley/footstep_wood_01.ogg"),
			preload("res://audio/original/foley/footstep_wood_02.ogg"),
			preload("res://audio/original/foley/footstep_wood_03.ogg"),
		],
		"fallback": preload("res://audio/sfx/player_step_hardwood.ogg"),
		"channel": &"player_footsteps",
		"pitch_jitter": 0.08,
	},
	&"parent_footstep": {
		"streams": [
			preload("res://audio/original/foley/footstep_wood_01.ogg"),
			preload("res://audio/original/foley/footstep_wood_02.ogg"),
			preload("res://audio/original/foley/footstep_wood_03.ogg"),
		],
		"fallback": preload("res://audio/sfx/parent_step.ogg"),
		"channel": &"parent_footsteps",
		"pitch_jitter": 0.08,
	},
	&"fridge_hum": {
		"streams": [
			preload("res://audio/original/foley/fridge_hum_01.ogg"),
		],
		"fallback": preload("res://audio/ambience/fridge_hum.ogg"),
		"channel": &"fridge_hum",
		"pitch_jitter": 0.05,
	},
	&"fridge_open_pop": {
		"streams": [
			preload("res://audio/original/foley/fridge_open_pop_01.ogg"),
		],
		"channel": &"fridge_pop",
		"pitch_jitter": 0.06,
	},
	&"wrapper_crinkle": {
		"streams": [
			preload("res://audio/original/foley/wrapper_crinkle_01.ogg"),
			preload("res://audio/original/foley/wrapper_crinkle_02.ogg"),
		],
		"channel": &"wrapper",
		"pitch_jitter": 0.08,
	},
	&"sink_running": {
		"streams": [
			preload("res://audio/original/foley/sink_running_01.ogg"),
		],
		"channel": &"bathroom",
		"pitch_jitter": 0.05,
	},
	&"toilet_flush": {
		"streams": [
			preload("res://audio/original/foley/toilet_flush_01.ogg"),
		],
		"channel": &"bathroom",
		"pitch_jitter": 0.05,
	},
}

const EVENTS: Dictionary = {
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
			{"pool": &"caught_grunt", "delay_ms": 120},
			{"pool": &"parent_grunt", "delay_ms": 650},
			{
				"context_key": &"had_snack",
				"true_pool": &"carry_red_handed",
				"false_pool": &"carry_empty_handed",
				"delay_ms": 2850,
			},
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
			{"pool": &"win_sting", "delay_ms": 0},
			{"pool": &"win_mmm", "delay_ms": 0},
			{"pool": &"win_giggle", "delay_ms": 1050},
		],
	},
	&"lose": {
		"group": &"result",
		"steps": [{"pool": &"caught_sting", "delay_ms": 0}],
	},
	&"wrapper_noise": {
		"group": &"wrapper",
		"steps": [
			{"pool": &"wrapper_crinkle", "delay_ms": 0},
			{"pool": &"wrapper_shush", "delay_ms": 350, "chance": 0.22},
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
	&"dog_attention": {
		"group": &"parent_state",
		"steps": [{"pool": &"parent_dog_attention", "delay_ms": 250}],
	},
}

const ROUTINE_EVENTS: Array[Dictionary] = [
	{"time": 0.0, "window": 8.0, "event": &"routine_couch"},
	{"time": 60.0, "window": 8.0, "event": &"routine_kitchen"},
	{"time": 82.0, "window": 8.0, "event": &"routine_couch"},
	{"time": 189.4, "window": 15.0, "event": &"bathroom_visit"},
	{"time": 288.5, "window": 11.5, "event": &"routine_bed_check"},
]
