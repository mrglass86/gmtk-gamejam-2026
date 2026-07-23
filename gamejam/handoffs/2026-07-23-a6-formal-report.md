# A6 formal report — win / lose / restart

## Completed and accepted

- Title/controls and first-input start verified live in Chrome by the director.
- First input unlocks play and starts the 5:00 clock.
- Entering the crib with the snack wins immediately.
- Expiry in the crib with the snack wins.
- Expiry anywhere else, or without the snack, loses.
- R performs a real scene reload and returns to the locked 5:00 title state.
- A6.1: camera uses `KEEP_WIDTH` at 31 m; 600×1000 and 1600×700 captures retain
  the full house. Placeholder generator removed. Brightness HUD is debug-only.

## Current state

Commits `d3a9d5d`, `e26ce9c`, `0223b1b`. A1–A6, 600-frame smoke, and release
Web export pass. Director accepted S11: zero Chrome console errors, glow and
shadows present.

## Decision

Saturday audio must use an imported stream started by GameFlow's first input.

## Exact next action

Remove `Main.tscn`'s Parent routine override so B5 owns the route; accept with
S10's bathroom/dining timing rows.

## Risks

Full snack round-trip feel remains a CP5 director playtest.

## Changed files

`Main.tscn`, `GameFlow.gd`, `BrightnessReadout.gd`, `Main.gd`, shared memory.
