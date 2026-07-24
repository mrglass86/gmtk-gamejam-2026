# Claude adversarial code-read — seed for lane C

Not the findings report (lane C owns `findings.md`). This is a head start from
reading GameFlow.gd + Snack.gd + the Parent carry seam with a bug-hunting eye,
2026-07-24, focused on the B20 class: actions firing during locked / carry /
transition states, and win/lose triggering from unexpected states.

## Confirmed closed by read

- **B20 free-win (caught while carrying → win):** fully closed. `_begin_carry`
  drops the snack (clears `carrying_snack`), and `Snack.pick_up()` now refuses
  while `player.input_locked` or `is_attached_to_carrier()`. The GameFlow win
  requires `carrying_snack and in_crib`, unreachable during a capture. Keep a
  standing regression on it.

## Candidate worth a look (from read, unverified in play)

- **Generous crib win zone (minor).** `GameFlow._is_player_in_crib()` accepts
  `overlaps_body` OR a manual box test with `goal_body_margin = 0.4` added to a
  crib box already 3.2 × 3.8 m. Test whether the player can win while standing
  *beside* the crib rather than in it — if so, tighten the margin. Suspected:
  `GameFlow.gd` lines ~163-180. Owner: A (export tune) or B.

## Hunt list for lane C (the B20 class — highest yield)

Drive REAL ticked play into each, assert clean resolution (no double-win, no
soft-lock, no error, exactly one end state):

1. **Clock expiry during every actor state:** mid-carry, mid-epilogue (each of
   the 7 post-deposit sub-states), mid-FOUND, mid-INVESTIGATE, mid-searchlight.
   Expect a clean single LOSE/WIN, never a stuck frame.
2. **Restart fuzzing:** press restart repeatedly on the result screen; press it
   the same frame a win/lose fires; confirm exactly one scene reload.
3. **Snack dropped in nasty places:** on the crib, inside a wall, on a switch,
   on a hazard, outside the navmesh — can it be recollected? does it grant a
   win by sitting in the crib zone? (it shouldn't — win needs the PLAYER
   carrying, but confirm.)
4. **Double interaction:** stand where a door and a switch overlap; hold
   interact while a switch is also in range; open the fridge while carrying the
   (other) snack; re-open a goal door after taking its snack.
5. **Carry/epilogue collisions:** get caught during the parent's peek; get
   caught by the parent while the dog is also investigating you; two catches in
   quick succession; caught immediately after a deposit.
6. **Monkey/fuzz bot:** thousands of frames of randomized input; assert no
   uncaught errors, no >N-second input-lock with no exit, clock always ends.

Route confirmed real bugs (with concrete repro) to A or B via Claude; mark
intended-by-design ones closed with a note.
