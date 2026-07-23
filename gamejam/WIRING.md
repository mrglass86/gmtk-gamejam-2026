# Wiring requests

Lane B never edits scenes. When you need a node added, renamed, moved, or
wired, append one line here and keep working. Lane A clears the list on its
next scene pass and checks the box.

Format: `- [ ] (who asked) what is needed, which scene, why`

## Open

- [ ] (lane B) Remove `Parent.routine_rows` override from `Main.tscn` so the B5 table in `Parent.gd` is the single source. Exact `(time: x,z / dwell)` rows: `0: -0.2,-4.6 / 53`; `60: 9.5,-3.8 / 15`; `82: -0.2,-4.6 / 98`; `182.8: 0.8,-0.8 / 0`; `187.5: -5.8,-0.8 / 0`; `189.4: -5.8,-3.5 / 15`; `206.3: -5.8,-0.8 / 0`; `211: 0.8,-0.8 / 0`; `213.8: -0.2,-4.6 / 26.2`; `242.8: 0.8,-0.8 / 0`; `244.8: -2,-0.8 / 2`; `251.9: 5.2,-0.8 / 2`; `258: 10.5,-3 / 5`; `268.9: 8,4.8 / 5`; `289.3: -12.75,-0.8 / 10.7`.

## Done

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
