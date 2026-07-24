# Audio reference — every sound, every moment (director QA)

Source of truth: `game/scripts/AudioCasting.gd` (pools + event sequences) and
`AudioDirector.gd` (playback). This doc is for QA — mark it up and hand changes
back; they route to lane A. Pools avoid immediate repeats and add pitch jitter;
one voice channel enforces priority carry/deposit(4) > catch/found/grunt(2) >
chase/routine/idle(1).

## How to listen

Open the clip folders in Finder and space-bar through — filenames are grouped
by pool, so "all the investigate lines" sit together:

```
open "/Users/noahhayes/Documents/GMTK GameJam 2026/game/audio/denoised/voice"
open "/Users/noahhayes/Documents/GMTK GameJam 2026/game/audio/denoised/foley"
open "/Users/noahhayes/Documents/GMTK GameJam 2026/game/audio/sfx"
```

(`original/` holds the pre-denoise versions; `cc0/footsteps/` the player steps;
`ambience/` the TV/speaker/fridge/clock beds.)

## The event map — what plays when

Delays are ms from the event firing. "×N" = takes in the pool.

### Sneaking
| Moment | Plays | Notes |
|---|---|---|
| Player step (carpet) | footstep_carpet_walk ×8 / _sprint ×8 (CC0) | near-silent by design after B19 |
| Player step (hardwood) | footstep_wood ×8 (CC0) | |
| Carrying the snack | wrapper_noise: wrapper_crinkle ×2 → wrapper_shush ×1 @350ms, 22% chance | chips only |
| Carrying ice cream | ice_cream_carry (pitched snack_drop, +1.55) | no crinkle |

### Parent notices you
| Moment | Plays | Notes |
|---|---|---|
| First cue (CURIOUS) | curiosity → parent_investigate ×3 ("hm?") | priority 2 |
| Investigating | parent_investigate ×3 | |
| Found you (chase) | found → parent_found_call ×6 | the parent's voice |
| Hears the dog | dog_attention → parent_dog_attention ×1 @250ms | |

### Getting caught → carried → deposited
| Moment | Plays (sequence) | Notes |
|---|---|---|
| Catch | caught_sting @0 → caught_grunt ×2 (kid) @120 → parent_grunt ×7 @650 → **had-snack? carry_red_handed ×7 : carry_empty_handed ×7** @2850 | context-branched |
| Deposit in crib | deposit_sniffle ×1 @0 → deposit_reconcile ×2 @1700 | |
| Escaped-child room check | epilogue_room_check → parent_bed_check ×1, then epilogue_kid_protest → kid_room_protest ×3 | |

### Win / lose
| Moment | Plays | Notes |
|---|---|---|
| Win | win_sting @0 + win_mmm ×1 @0 → win_giggle ×8 @1050 | |
| Lose | caught_sting | |

### Parent's ambient life (routine)
| Time | Plays | |
|---|---|---|
| 0s, 82s | routine_couch → parent_couch_mutter ×3 | "never anything good on…" |
| 60s | routine_kitchen → parent_kitchen_intent ×2 | |
| 189.4s | bathroom_visit → toilet_flush ×1 → sink_running ×1 @9s | |
| 288.5s | routine_bed_check → parent_bed_check ×1 | |

### Kid, idle
| Moment | Plays | Notes |
|---|---|---|
| Free-roaming, random 20–45s | idle_giggle (chase_giggle clips, −8 dB), rate-limited 1.5s + chance | see observation 1 |

### Objects
| Moment | Plays | Notes |
|---|---|---|
| Door opening (rushed) | door_creak_fast — **only 1 of 9 recorded takes wired** | see observation 2 |
| Door opening (slow) | door_creak_slow — **only 1 of 4 wired** | see observation 2 |
| Fridge idle | fridge_hum bed | |
| Pantry snack pickup | snack_pickup_pantry (crinkle grab) | |
| Fridge snack pickup | snack_pickup_fridge_scoop + snack_pickup_fridge_voice ("mmm", = win_mmm clip) | see observation 3 |
| Light switch | light_switch (CC0 sfx) | |
| Parent footsteps | parent_footstep (family wood steps ×3) | |

## Claude's QA observations (candidate changes — your call)

1. **Kid giggles fire on an idle timer, not during the chase.** You wanted
   giggles *while being chased*; today they roll every 20–45s of free-roam, so
   they rarely land during a FOUND chase. Candidate: add a giggle trigger on
   entering/continuing FOUND (rate-limited), separate from idle.
2. **Door-creak variety is unused.** You recorded 9 fast + 4 slow creaks;
   only 1 of each is wired into its pool. Candidate: load all takes so doors
   vary. Cheapest, highest-return audio fix here.
3. **The fridge "yumm" and the win "mmm" are the same single clip**
   (`win_mmm_01`). Both pools have 1 take. Candidate: a distinct fridge-yumm,
   and/or more win-mmm takes (30-second re-record).
4. **Thin single-take pools** (repeat every time): parent_bed_check,
   parent_dog_attention, deposit_sniffle, snack_drop_voice, sink, toilet,
   win_mmm. Fine for jam; flag any that grate.
5. **kid_room_protest reuses the empty-handed carry lines.** Works, but if you
   want the "caught out of bed" scold to feel distinct, it wants its own takes.

Fill in a NOTES column or just tell Claude the changes per row; they go to
lane A as an AudioCasting edit.
