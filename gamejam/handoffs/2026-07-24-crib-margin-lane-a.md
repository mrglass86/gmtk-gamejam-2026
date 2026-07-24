# 2026-07-24 — lane A crib-boundary QA fix

## Completed

- Reduced `GameFlow.goal_body_margin` from 0.4 to 0.08 m.
- Removed capsule-inflated `Area3D.overlaps_body()` as an alternate win path;
  crib containment now tests the player centre.
- Added A6 coverage for both the established inside position and the reported
  outside-X position.

## Proof

- A6: inside player holding the snack wins immediately and at expiry.
- Lane-C `crib-margin`: 2.04 m from crib centre remains PLAYING; scenario
  passes.

## Decision

Keep the current crib layout and open-end approach. Tighten only win
containment.

## Next acceptance

Lane C reruns `--qa-scenario=crib-margin` on the integrated head; expected
metric is `offset=2.04 state=1`.

## Files

`game/scripts/GameFlow.gd`, `game/scripts/Main.gd`,
`gamejam/qa/findings.md`.
