# Lane A — B5 wiring, A6.1, and pulled-forward audio

## Completed

- Removed the Parent scene override; B5's 15-row route is authoritative
  (`538d697`).
- Reconfirmed A6.1: `KEEP_WIDTH`/31 m camera, no placeholder audio, release-only
  brightness HUD gate.
- Added all brief 6.7 CC0 audio: three countdown tells, surface/toy and parent
  footsteps, win/caught stings, pet chirp/bark, door creak, TV/speaker masking
  beds, fridge hum, and clock tick (`d34f4a8`). Sources are in `CREDITS.md`.

## Current state

`--verify-a51`, `--verify-a6`, `--verify-audio`, clean startup, and release Web
export pass. A real Web canvas click produced zero console warnings/errors.

## Decision

Audio is scene-side, first-input gated, plain 2D/3D players with direct volume
only; no bus effects or lane B edits.

## Exact next action

Noah plays CP4 from the title through one catch/chase. Accept when B5's route is
believable and TV-off, light-switch, and moving-parent tells are unmistakable.

## Risks

Functional coverage is complete; mix levels and loop seams await the director's
first listening walk.

## Changed files

`Main.tscn`, `Main.gd`, `AudioDirector.gd`, `game/audio/`, `CREDITS.md`, shared
memory, this handoff.
