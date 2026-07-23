# Wiring requests

Lane B never edits scenes. When you need a node added, renamed, moved, or
wired, append one line here and keep working. Lane A clears the list on its
next scene pass and checks the box.

Format: `- [ ] (who asked) what is needed, which scene, why`

## Open

- [ ] (lane B) Attach `res://scripts/Door.gd` to `BedroomDoor`, `Pantry`, and `Fridge` in `Main.tscn`; configure their `door_kind` values and add an optional `DoorVisual` pivot child to animate. Add a `Snack` `Node3D` at the goal with a `MeshInstance3D` child named `Visual`, attach `res://scripts/Snack.gd`, and assign it to whichever goal doors should award the snack (`provides_snack = true`).

## Done

- [x] (lane B) Attached `res://scripts/Player.gd` to `Player` in `Main.tscn`.
  The existing `Capsule`, collision shape, and tagged floor colliders satisfy B1.
