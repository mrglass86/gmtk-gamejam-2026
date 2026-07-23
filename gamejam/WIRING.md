# Wiring requests

Lane B never edits scenes. When you need a node added, renamed, moved, or
wired, append one line here and keep working. Lane A clears the list on its
next scene pass and checks the box.

Format: `- [ ] (who asked) what is needed, which scene, why`

## Open

- [ ] (lane B) Attach `res://scripts/Player.gd` to the `Player` `CharacterBody3D` in `Main.tscn`; add a `MeshInstance3D` child named `Capsule` and a floor collision shape. Put each floor collider in exactly one `surface_carpet`, `surface_hardwood`, `surface_creaky`, or `surface_toys` group so B1 can derive footstep noise.

## Done

_None yet._
