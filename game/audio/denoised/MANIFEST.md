# A18 conservative spectral-denoise pass

Original files remain unchanged under `game/audio/original/`; matching
A/B copies are under `game/audio/denoised/`.

Each clip is scanned in 45.9 ms windows. Its quietest window is accepted as a clip-local noise profile only at or below -35 dBFS.
Accepted clips use FFmpeg `afftdn` with 6 dB reduction, fixed profile sampling, 0.7 adaptivity, and 6-band gain smoothing.
Rejected clips are not processed; runtime pools must omit them and retain their CC0 fallback.

- Cleaned: 69
- Rejected / CC0 fallback: 19
- Total: 88

| Original | A/B copy | Profile (s) | RMS (dBFS) | Duration (s) | Status |
|---|---|---:|---:|---:|---|
| `game/audio/original/foley/door_creak_fast_01.ogg` | — | 0.7809 | -26.97 | 0.796 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_02.ogg` | — | 0.8269 | -20.33 | 0.857 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_03.ogg` | `game/audio/denoised/foley/door_creak_fast_03.ogg` | 0.6431 | -37.54 | 0.657 | cleaned |
| `game/audio/original/foley/door_creak_fast_04.ogg` | — | 0.2756 | -26.43 | 1.240 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_05.ogg` | — | 0.5972 | -25.01 | 0.622 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_06.ogg` | — | 1.3781 | -19.25 | 1.413 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_07.ogg` | — | 0.4594 | -27.59 | 0.479 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_08.ogg` | — | 1.2862 | -26.74 | 1.464 | CC0 fallback |
| `game/audio/original/foley/door_creak_fast_09.ogg` | — | 1.0566 | -21.91 | 1.091 | CC0 fallback |
| `game/audio/original/foley/door_creak_slow_01.ogg` | — | 2.2509 | -22.73 | 2.265 | CC0 fallback |
| `game/audio/original/foley/door_creak_slow_02.ogg` | — | 1.3781 | -25.69 | 2.420 | CC0 fallback |
| `game/audio/original/foley/door_creak_slow_03.ogg` | — | 4.7775 | -24.34 | 4.802 | CC0 fallback |
| `game/audio/original/foley/door_creak_slow_04.ogg` | `game/audio/denoised/foley/door_creak_slow_04.ogg` | 4.3641 | -46.42 | 4.386 | cleaned |
| `game/audio/original/foley/footstep_carpet_sprint_01.ogg` | `game/audio/denoised/foley/footstep_carpet_sprint_01.ogg` | 2.6644 | -46.01 | 3.154 | cleaned |
| `game/audio/original/foley/footstep_carpet_sprint_02.ogg` | `game/audio/denoised/foley/footstep_carpet_sprint_02.ogg` | 1.3322 | -41.13 | 2.831 | cleaned |
| `game/audio/original/foley/footstep_carpet_sprint_03.ogg` | `game/audio/denoised/foley/footstep_carpet_sprint_03.ogg` | 2.0672 | -66.36 | 2.068 | cleaned |
| `game/audio/original/foley/footstep_carpet_walk_01.ogg` | `game/audio/denoised/foley/footstep_carpet_walk_01.ogg` | 0.0000 | -43.06 | 2.106 | cleaned |
| `game/audio/original/foley/footstep_carpet_walk_02.ogg` | — | 0.4594 | -23.33 | 0.485 | CC0 fallback |
| `game/audio/original/foley/footstep_wood_01.ogg` | `game/audio/denoised/foley/footstep_wood_01.ogg` | 2.4347 | -64.02 | 2.435 | cleaned |
| `game/audio/original/foley/footstep_wood_02.ogg` | `game/audio/denoised/foley/footstep_wood_02.ogg` | 0.8269 | -50.85 | 0.949 | cleaned |
| `game/audio/original/foley/footstep_wood_03.ogg` | `game/audio/denoised/foley/footstep_wood_03.ogg` | 0.2324 | -40.79 | 0.350 | cleaned |
| `game/audio/original/foley/fridge_hum_01.ogg` | — | 0.2297 | -22.61 | 13.401 | CC0 fallback |
| `game/audio/original/foley/fridge_open_pop_01.ogg` | — | 5.9259 | -29.22 | 5.931 | CC0 fallback |
| `game/audio/original/foley/sink_running_01.ogg` | `game/audio/denoised/foley/sink_running_01.ogg` | 3.4453 | -43.94 | 3.448 | cleaned |
| `game/audio/original/foley/toilet_flush_01.ogg` | `game/audio/denoised/foley/toilet_flush_01.ogg` | 32.9372 | -36.93 | 32.969 | cleaned |
| `game/audio/original/foley/wrapper_crinkle_01.ogg` | `game/audio/denoised/foley/wrapper_crinkle_01.ogg` | 1.6538 | -50.40 | 1.654 | cleaned |
| `game/audio/original/foley/wrapper_crinkle_02.ogg` | `game/audio/denoised/foley/wrapper_crinkle_02.ogg` | 0.6891 | -37.14 | 0.698 | cleaned |
| `game/audio/original/voice/carry_empty_handed_01.ogg` | `game/audio/denoised/voice/carry_empty_handed_01.ogg` | 0.0000 | -59.36 | 3.156 | cleaned |
| `game/audio/original/voice/carry_empty_handed_02.ogg` | `game/audio/denoised/voice/carry_empty_handed_02.ogg` | 1.3322 | -42.26 | 1.348 | cleaned |
| `game/audio/original/voice/carry_empty_handed_03.ogg` | `game/audio/denoised/voice/carry_empty_handed_03.ogg` | 2.7563 | -44.88 | 2.770 | cleaned |
| `game/audio/original/voice/carry_empty_handed_04.ogg` | `game/audio/denoised/voice/carry_empty_handed_04.ogg` | 8.0850 | -69.70 | 18.364 | cleaned |
| `game/audio/original/voice/carry_empty_handed_05.ogg` | `game/audio/denoised/voice/carry_empty_handed_05.ogg` | 6.2475 | -59.89 | 6.284 | cleaned |
| `game/audio/original/voice/carry_empty_handed_06.ogg` | `game/audio/denoised/voice/carry_empty_handed_06.ogg` | 5.8800 | -64.94 | 10.772 | cleaned |
| `game/audio/original/voice/carry_empty_handed_07.ogg` | `game/audio/denoised/voice/carry_empty_handed_07.ogg` | 5.9719 | -51.67 | 5.998 | cleaned |
| `game/audio/original/voice/carry_red_handed_01.ogg` | `game/audio/denoised/voice/carry_red_handed_01.ogg` | 0.9187 | -41.96 | 1.133 | cleaned |
| `game/audio/original/voice/carry_red_handed_02.ogg` | `game/audio/denoised/voice/carry_red_handed_02.ogg` | 0.2297 | -59.12 | 13.259 | cleaned |
| `game/audio/original/voice/carry_red_handed_03.ogg` | `game/audio/denoised/voice/carry_red_handed_03.ogg` | 2.6184 | -49.88 | 2.623 | cleaned |
| `game/audio/original/voice/carry_red_handed_04.ogg` | `game/audio/denoised/voice/carry_red_handed_04.ogg` | 1.6078 | -52.87 | 1.610 | cleaned |
| `game/audio/original/voice/carry_red_handed_05.ogg` | `game/audio/denoised/voice/carry_red_handed_05.ogg` | 1.3781 | -39.80 | 1.409 | cleaned |
| `game/audio/original/voice/carry_red_handed_06.ogg` | `game/audio/denoised/voice/carry_red_handed_06.ogg` | 0.5513 | -37.18 | 0.573 | cleaned |
| `game/audio/original/voice/carry_red_handed_07.ogg` | — | 0.3702 | -33.56 | 0.381 | CC0 fallback |
| `game/audio/original/voice/carry_red_handed_08.ogg` | `game/audio/denoised/voice/carry_red_handed_08.ogg` | 0.5972 | -43.60 | 0.598 | cleaned |
| `game/audio/original/voice/caught_grunt_01.ogg` | `game/audio/denoised/voice/caught_grunt_01.ogg` | 0.4134 | -39.10 | 0.449 | cleaned |
| `game/audio/original/voice/caught_grunt_02.ogg` | — | 0.3702 | -29.94 | 0.383 | CC0 fallback |
| `game/audio/original/voice/caught_grunt_03.ogg` | `game/audio/denoised/voice/caught_grunt_03.ogg` | 0.3702 | -39.99 | 0.386 | cleaned |
| `game/audio/original/voice/chase_giggle_01.ogg` | `game/audio/denoised/voice/chase_giggle_01.ogg` | 1.7916 | -57.69 | 2.193 | cleaned |
| `game/audio/original/voice/chase_giggle_02.ogg` | `game/audio/denoised/voice/chase_giggle_02.ogg` | 0.6431 | -51.89 | 1.828 | cleaned |
| `game/audio/original/voice/chase_giggle_03.ogg` | `game/audio/denoised/voice/chase_giggle_03.ogg` | 1.8375 | -62.43 | 2.595 | cleaned |
| `game/audio/original/voice/deposit_reconcile_01.ogg` | `game/audio/denoised/voice/deposit_reconcile_01.ogg` | 1.1025 | -52.43 | 1.104 | cleaned |
| `game/audio/original/voice/deposit_reconcile_02.ogg` | `game/audio/denoised/voice/deposit_reconcile_02.ogg` | 1.0106 | -40.92 | 1.468 | cleaned |
| `game/audio/original/voice/deposit_sniffle_01.ogg` | `game/audio/denoised/voice/deposit_sniffle_01.ogg` | 1.5619 | -38.92 | 1.602 | cleaned |
| `game/audio/original/voice/parent_bed_check_01.ogg` | — | 0.9647 | -30.39 | 1.005 | CC0 fallback |
| `game/audio/original/voice/parent_bed_check_02.ogg` | `game/audio/denoised/voice/parent_bed_check_02.ogg` | 1.3781 | -37.98 | 1.698 | cleaned |
| `game/audio/original/voice/parent_couch_mutter_01.ogg` | `game/audio/denoised/voice/parent_couch_mutter_01.ogg` | 1.5619 | -37.85 | 1.579 | cleaned |
| `game/audio/original/voice/parent_couch_mutter_02.ogg` | `game/audio/denoised/voice/parent_couch_mutter_02.ogg` | 0.4134 | -46.77 | 1.438 | cleaned |
| `game/audio/original/voice/parent_couch_mutter_03.ogg` | `game/audio/denoised/voice/parent_couch_mutter_03.ogg` | 0.8269 | -42.59 | 1.085 | cleaned |
| `game/audio/original/voice/parent_dog_attention_01.ogg` | `game/audio/denoised/voice/parent_dog_attention_01.ogg` | 0.0919 | -42.80 | 0.910 | cleaned |
| `game/audio/original/voice/parent_found_call_01.ogg` | `game/audio/denoised/voice/parent_found_call_01.ogg` | 0.6431 | -49.20 | 0.657 | cleaned |
| `game/audio/original/voice/parent_found_call_02.ogg` | `game/audio/denoised/voice/parent_found_call_02.ogg` | 1.1484 | -50.42 | 1.156 | cleaned |
| `game/audio/original/voice/parent_found_call_03.ogg` | `game/audio/denoised/voice/parent_found_call_03.ogg` | 1.0106 | -52.08 | 1.014 | cleaned |
| `game/audio/original/voice/parent_found_call_04.ogg` | `game/audio/denoised/voice/parent_found_call_04.ogg` | 0.4134 | -35.80 | 1.185 | cleaned |
| `game/audio/original/voice/parent_found_call_05.ogg` | `game/audio/denoised/voice/parent_found_call_05.ogg` | 0.8728 | -43.11 | 1.233 | cleaned |
| `game/audio/original/voice/parent_found_call_06.ogg` | `game/audio/denoised/voice/parent_found_call_06.ogg` | 1.2403 | -41.39 | 1.265 | cleaned |
| `game/audio/original/voice/parent_grunt_01.ogg` | `game/audio/denoised/voice/parent_grunt_01.ogg` | 0.7350 | -48.76 | 0.736 | cleaned |
| `game/audio/original/voice/parent_grunt_02.ogg` | `game/audio/denoised/voice/parent_grunt_02.ogg` | 1.7916 | -46.50 | 2.081 | cleaned |
| `game/audio/original/voice/parent_grunt_03.ogg` | `game/audio/denoised/voice/parent_grunt_03.ogg` | 0.6891 | -39.50 | 2.000 | cleaned |
| `game/audio/original/voice/parent_grunt_04.ogg` | `game/audio/denoised/voice/parent_grunt_04.ogg` | 1.3781 | -53.79 | 1.380 | cleaned |
| `game/audio/original/voice/parent_grunt_05.ogg` | `game/audio/denoised/voice/parent_grunt_05.ogg` | 1.2403 | -40.24 | 1.269 | cleaned |
| `game/audio/original/voice/parent_grunt_06.ogg` | `game/audio/denoised/voice/parent_grunt_06.ogg` | 0.0000 | -35.96 | 0.728 | cleaned |
| `game/audio/original/voice/parent_grunt_07.ogg` | `game/audio/denoised/voice/parent_grunt_07.ogg` | 1.5619 | -46.46 | 1.964 | cleaned |
| `game/audio/original/voice/parent_grunt_08.ogg` | — | 0.8728 | -32.11 | 0.900 | CC0 fallback |
| `game/audio/original/voice/parent_investigate_01.ogg` | `game/audio/denoised/voice/parent_investigate_01.ogg` | 0.5053 | -54.22 | 0.514 | cleaned |
| `game/audio/original/voice/parent_investigate_02.ogg` | `game/audio/denoised/voice/parent_investigate_02.ogg` | 0.7350 | -45.01 | 0.755 | cleaned |
| `game/audio/original/voice/parent_investigate_03.ogg` | `game/audio/denoised/voice/parent_investigate_03.ogg` | 0.7350 | -39.86 | 0.749 | cleaned |
| `game/audio/original/voice/parent_kitchen_intent_01.ogg` | `game/audio/denoised/voice/parent_kitchen_intent_01.ogg` | 1.2403 | -48.65 | 1.246 | cleaned |
| `game/audio/original/voice/parent_kitchen_intent_02.ogg` | `game/audio/denoised/voice/parent_kitchen_intent_02.ogg` | 0.1837 | -48.56 | 1.233 | cleaned |
| `game/audio/original/voice/snack_drop_voice_01.ogg` | `game/audio/denoised/voice/snack_drop_voice_01.ogg` | 0.5972 | -35.81 | 0.625 | cleaned |
| `game/audio/original/voice/win_giggle_01.ogg` | `game/audio/denoised/voice/win_giggle_01.ogg` | 1.1944 | -44.67 | 3.240 | cleaned |
| `game/audio/original/voice/win_giggle_02.ogg` | `game/audio/denoised/voice/win_giggle_02.ogg` | 0.7350 | -46.97 | 0.771 | cleaned |
| `game/audio/original/voice/win_giggle_03.ogg` | `game/audio/denoised/voice/win_giggle_03.ogg` | 1.1025 | -59.83 | 1.108 | cleaned |
| `game/audio/original/voice/win_giggle_04.ogg` | `game/audio/denoised/voice/win_giggle_04.ogg` | 1.0106 | -47.77 | 1.028 | cleaned |
| `game/audio/original/voice/win_giggle_05.ogg` | `game/audio/denoised/voice/win_giggle_05.ogg` | 0.4594 | -40.18 | 1.365 | cleaned |
| `game/audio/original/voice/win_giggle_06.ogg` | `game/audio/denoised/voice/win_giggle_06.ogg` | 1.1484 | -42.07 | 1.164 | cleaned |
| `game/audio/original/voice/win_giggle_07.ogg` | `game/audio/denoised/voice/win_giggle_07.ogg` | 0.0919 | -48.08 | 2.563 | cleaned |
| `game/audio/original/voice/win_giggle_08.ogg` | `game/audio/denoised/voice/win_giggle_08.ogg` | 2.8481 | -57.19 | 3.700 | cleaned |
| `game/audio/original/voice/win_mmm_01.ogg` | `game/audio/denoised/voice/win_mmm_01.ogg` | 0.9187 | -38.46 | 0.936 | cleaned |
| `game/audio/original/voice/wrapper_shush_01.ogg` | `game/audio/denoised/voice/wrapper_shush_01.ogg` | 0.2297 | -37.15 | 0.550 | cleaned |
| `game/audio/original/voice/wrapper_shush_02.ogg` | — | 0.4594 | -28.89 | 0.475 | CC0 fallback |
