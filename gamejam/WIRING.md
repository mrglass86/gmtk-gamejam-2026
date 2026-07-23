# Wiring requests

Lane B never edits scenes. When you need a node added, renamed, moved, or
wired, append one line here and keep working. Lane A clears the list on its
next scene pass and checks the box.

Format: `- [ ] (who asked) what is needed, which scene, why`

## Open

_None._
- [ ] (lane B) After A0.2, replace `Parent`'s `AgentStub.gd` with `res://scripts/Parent.gd`, add a `MeshInstance3D` child named `VisionCone`, keep its `NavigationAgent3D`, and replace the placeholder `routine_rows` coordinates with the final relayout positions. Confirm the default sibling paths resolve `Player`, `Crib`, and `Snack`.

## Done

- [x] (lane B) Attached `res://scripts/Player.gd` to `Player` in `Main.tscn`.
  The existing `Capsule`, collision shape, and tagged floor colliders satisfy B1.
- [x] (lane B) Attached `Door.gd` to BedroomDoor, Pantry, and Fridge with
  configured kinds, physical `DoorVisual` pivots, and snack-providing goal
  doors. Added the shared scripted `Snack` node and visual.
