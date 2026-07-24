# A15 casting map

`assets/voice/picks/` is the director's named casting source of truth. Child
voice picks use the generic `kid-*` prefix. The committed runtime copies use
anonymous pool names under
`game/audio/original/`. `AudioCasting.gd` is authoritative for playback.

## Voice pools

| Pool | Takes |
| --- | ---: |
| parent_investigate | 3 |
| parent_found_call | 6 |
| parent_bed_check | 2 |
| parent_couch_mutter | 3 |
| parent_kitchen_intent | 2 |
| parent_dog_attention | 1 |
| parent_grunt | 8 |
| carry_red_handed | 8 |
| carry_empty_handed | 7 |
| caught_grunt | 3 |
| chase_giggle | 3 |
| win_mmm | 1 |
| win_giggle | 8 |
| deposit_sniffle | 1 |
| deposit_reconcile | 2 |
| wrapper_shush | 2 |
| snack_drop_voice | 1 |

## Foley pools

| Pool | Takes |
| --- | ---: |
| door_creak_fast | 9 |
| door_creak_slow | 4 |
| footstep_carpet_walk | 2 |
| footstep_carpet_sprint | 3 |
| footstep_wood | 3 |
| fridge_hum | 1 |
| fridge_open_pop | 1 |
| wrapper_crinkle | 2 |
| sink_running | 1 |
| toilet_flush | 1 |

## Event sequences

- Catch: sting, child catch grunt, parent grunt, then snack-context carry
  protest.
- Deposit: sniffle, then reconcile.
- Win: sting plus “mmm”, then giggle.
- Wrapper noise: crinkle, with a low-chance shush.
- Bathroom visit: toilet flush, then sink water.

All pools avoid immediate repeats and use 5–8% pitch jitter. A single voice
channel enforces carry/deposit over catch/found over chase/routine priority.
Chase giggles are rate-limited to 1.5 seconds and use a chance roll. CC0 assets
remain the fallback for unfilled pools and legacy cues.
