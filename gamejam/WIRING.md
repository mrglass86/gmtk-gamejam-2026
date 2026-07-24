# Wiring requests

Lane B never edits scenes. When you need a node added, renamed, moved, or
wired, append one line here and keep working. Lane A clears the list on its
next scene pass and checks the box.

Format: `- [ ] (who asked) what is needed, which scene, why`

## Open

- [ ] (lane B / B14) In `AudioDirector.gd`, call
  `Parent.show_parent_voice_indicator()` only when a parent-authored voice pool
  starts; connect Parent's `epilogue_room_check_started` and
  `epilogue_kid_protest` signals to the parent bed-check and kid-protest pools.
  This keeps the magenta icon exact without creating a NoiseSystem event.
- [ ] (lane B / B14) In `AudioDirector._update_door_creak`, drive the active
  player's `pitch_scale` and `volume_db` from
  `DinnerDoor.get_creak_pitch_scale()` / `get_creak_volume_db()` every frame.
  Door now exposes its live rate and exported slow/rush endpoints.

## Done

- [x] (lane A / A16 for lane B B14) After the post-capture beat, Parent may
  call `../Level/KidHallSwitch.set_state(true, true)` to turn on the initially
  dark hall practical with its positional click and 1.5 analytical noise.
  Stable node: `Level/KidHallSwitch`; signal: `toggled(switch_id, is_on)`.

- [x] (lane B / B11) A11 dog visual keeps its snout along Pet-local `-Z`;
  `Pet.gd` smoothly yaws that forward axis into patrol, investigate, and bowl
  travel directions.
- [x] (lane B / B9) Added scripted `Level/BathroomDoor` with the exact
  `../Level/BathroomDoor` Parent path, quiet-zone blocker, collision-free
  panel, and explicit Player/Snack paths from under `Level`.
- [x] (lane B / B9) Added collision-free `Level/KitchenBowl` at
  `(8.0, 0.08, -1.8)` on reachable kitchen nav for Pet bowl visits.
- [x] (lane B) Removed `Parent.routine_rows` override from `Main.tscn`; B5's
  15-row bathroom/dining route in `Parent.gd` is authoritative (`--verify-a51`).
- [x] (lane B) Attached `res://scripts/Player.gd` to `Player` in `Main.tscn`.
  The existing `Capsule`, collision shape, and tagged floor colliders satisfy B1.
- [x] (lane B) Attached `Door.gd` to BedroomDoor, Pantry, and Fridge with
  configured kinds, physical `DoorVisual` pivots, and snack-providing goal
  doors. Added the shared scripted `Snack` node and visual.
- [x] (lane B) Replaced Parent's AgentStub with `Parent.gd`, added
  `VisionCone`, retained its NavigationAgent3D, and set the routine rows to the
  A0.2 couch, kitchen, and kid-door coordinates. Default sibling paths resolve.
- [x] (lane B) Replaced Pet's AgentStub with `Pet.gd`; retained `Body` and
  `NavigationAgent3D`, and verified its default sibling paths resolve.
- [x] (lane B) Removed legacy `CollisionShape3D` children from all three
  `DoorVisual` nodes; `Door.gd` now owns the runtime doorway blockers.
