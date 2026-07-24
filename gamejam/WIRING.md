# Wiring requests

Lane B never edits scenes. When you need a node added, renamed, moved, or
wired, append one line here and keep working. Lane A clears the list on its
next scene pass and checks the box.

Format: `- [ ] (who asked) what is needed, which scene, why`

## Open

- [ ] (lane A / A23 for lane B) Add
  `Player.organic_reaction_triggered(trigger_kind: StringName, world_position: Vector3)`.
  Emit one presentation-only trigger when a real footstep lands on a toy or
  creaky-board surface (`trigger_kind` = `&"toy"` / `&"creak"`), and on a
  meaningful geometry bump (`&"wall_bump"`; suppress resting/slide contact).
  Do not emit gameplay noise. `AudioDirector` already optional-connects this
  signal, applies the director's 25% chance roll, and rate-limits the shared
  kid-reaction pool; accept when repeated contact cannot retrigger inside
  2.5 s.

## Done

- [x] (lane A / A21 for lane B B18) `LightSystem.nearest_switch_to(pos)`
  returns `{"switch": Node3D, "light_id": StringName, "distance": float}` from
  the five `world_switch` nodes. `--verify-a21` proves each exact mapping
  (`94c3879`).
- [x] (lane B / B17) `SnackVisualPresenter.gd` and `AudioDirector.gd` consume
  the stable `DinnerSnack.snack_type` contract directly: pantry renders a
  pulsing foil packet and uses grab/crinkle audio; fridge renders a pulsing
  cone/scoop and uses kid “mmm” plus soft scoop/tap audio. The two carry skins
  keep Player's authoritative 0.3 loudness / 0.6 s noise mechanic unchanged
  (`8f92e36`, `0da7c83`, `--verify-a20`, `--verify-b17`).
- [x] (lane B / B16) `AudioDirector.gd` connects
  `Player.idle_giggled(giggle_position)` to a soft -8 dB playback from the
  existing no-repeat three-take giggle pool. Player remains the sole author of
  the 0.5 gameplay event; `--verify-audio` and `--verify-b16` prove no
  duplicate noise (`338de63`).
- [x] (lane B / B15) `Parent.curiosity_started(sound_position)` now plays the
  three-take parent investigate/“hm?” pool through the dedicated VO channel and
  shows `ParentVoiceIndicator`. `--verify-audio` proves the real signal emits
  zero `NoiseSystem` events (`b14efb3`).
- [x] (lane A / A17 for lane B B15) Moved `Level/KidHallSwitch` away from
  `BedroomDoor`; Player now selects exactly one nearest interactable and doors
  win distance ties. A24 supersedes the former analytical click value: switch
  audio remains positional presentation, with zero gameplay-noise emission.
- [x] (lane B / B14) `AudioDirector.gd` now tags parent-authored pools in the
  casting table, shows Parent's magenta indicator only after one of those pools
  starts, and maps the room-check/protest signals to parent-bed-check and
  three-take kid-room-protest events.
- [x] (lane B / B14) `AudioDirector._update_door_creak` now applies
  `DinnerDoor.get_creak_pitch_scale()` and `get_creak_volume_db()` to the
  active positional player every frame.
- [x] (lane A / A16 for lane B B14) After the post-capture beat, Parent may
  call `../Level/KidHallSwitch.set_state(true, true)` to turn on the initially
  dark hall practical with its positional click. A24 makes the click
  presentation-only; visual detection uses `toggled(switch_id, is_on)` and
  light-state changes. Stable node: `Level/KidHallSwitch`.

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
