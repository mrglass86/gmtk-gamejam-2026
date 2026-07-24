# Post-jam refactor list — running log

Read-only review findings. Nothing here is jam work: zero code changes before
submission. This list is for the version of this project that has a future.
Grows through Saturday as review continues.

## Confirmed findings (from code read, 2026-07-23)

1. **Parent.gd verification bloat.** ~560 of ~1550 lines are embedded
   `--verify-*` harness code with 40+ verify exports on the gameplay class.
   Post-jam: extract a `tests/ParentVerification.gd` harness that drives the
   scene externally; Parent.gd keeps gameplay only. (This file is also the
   designated in-jam "bug factory watch" — surgical fixes only.)
2. **Ring/hearing constants duplicated.** The audibility formula
   (loudness × 8, cap 20) lives in the NoiseIndicator layer and, post-B9, in
   Parent exports that "must match." Post-jam: one shared constant source
   (autoload const or resource) consumed by both.
3. **Dead scaffold code.** `scripts/AgentStub.gd` is superseded by Parent/Pet;
   verify nothing references it, then delete.
4. **State machines as enums + match.** Parent's 11-state enum (routine,
   investigate, found, carry, 7 post-deposit micro-states) works but the
   post-deposit sequence begs for a small sequential-step runner or state
   objects post-jam.
5. **LevelBuilder as data.** The layout table proved its worth (relayout in
   one package). Post-jam: move rooms/walls/props/lights into an exported
   Resource or JSON so layout edits don't touch code at all.
6. **Verification culture to keep.** Live SceneTree clock-ticking asserts and
   the committed-tree blob check (`d656df8`) are genuinely good practice —
   formalize into a test runner rather than per-script cmdline flags.

## To review before Saturday night (as time allows)

- Pet.gd, GameFlow.gd, AudioDirector.gd, NoiseIndicatorManager.gd,
  PhaseDirector.gd, SnackVisualPresenter.gd, DebugTools.gd, CameraRig.gd —
  same lens: dead code, duplicated constants, ownership boundaries.
- Brief section 13 validation questions — answer them Saturday night while
  fresh; they decide whether this project graduates.
