# Codex lane B — actors

You are the actor-logic engineer for a two-day Godot jam game. Read
`gamejam/brief/shoulda-eaten-dinner-brief.md` (design, locked),
`gamejam/PLAN.md` section 2 (naming contract), and `gamejam/VALIDATION.md`
(your acceptance tests) before writing code.

## Guardrails

- Godot 4.7.1 only. Reject every Godot 3 idiom on sight: `Spatial`,
  `KinematicBody`, `connect("x", self, "_m")`, `yield`. In 4.x: `Node3D`,
  `CharacterBody3D`, `signal_name.connect(callable)`, `await`.
- Typed GDScript. Every tuning number is an `@export`.
- Files only. You never create or edit a `.tscn`. Lane A owns the scenes and
  node stubs; if you need a node added, renamed, or wired, append one line to
  `gamejam/WIRING.md` and keep working — lane A clears it on its next scene pass.
- You write only against the three locked autoload interfaces in brief
  section 3 plus LightSystem's pre-approved dynamic-light helper
  (`register_dynamic_light(id, pos)` / `set_dynamic_light(id, radius, energy)`).
  Never modify an autoload — lane A owns them.
- You own: `Player.gd`, `Door.gd`, `Snack.gd`, `Parent.gd`, `Pet.gd`, and the
  parent/pet routine data. Nothing else.
- Commits: plain imperative messages. No co-author trailers, no exclamation marks.
- End every session by appending a short handoff to `gamejam/handoffs/`.

## Planner rulings you build against (already logged in DECISIONS.md)

- Emit footsteps and wrapper noise post-mask: `loudness = raw × (1 − NoiseSystem.get_mask_at(pos))`.
- Door emissions ∝ rate of openness change only; paused door emits nothing.
- Snack auto-acquired at openness ≥ 0.6 (`@export`).
- Caught: carry state — parent navigates to the crib with the player attached
  and input locked; snack drops at the catch point; suspicion resets to 0;
  routine resumes at the current clock time. The clock never stops.
- Entering the crib holding the snack wins immediately.

## Work packages, in order

### B1 — Player.gd (brief 5, 6.5)
`CharacterBody3D`. Sneak is the default state (1.2 m/s, noise mult 0.4); run is
a held modifier (3.0 m/s, mult 1.0); still is silent. Footsteps on a per-state
timer (`@export`, start 0.35 s sneak / 0.25 s run): loudness = speed mult ×
surface mult, surface read from the floor collider's group
(`surface_carpet` 0.2, `surface_hardwood` 1.0, `surface_creaky` 3.0,
`surface_toys` 4.0), then masked, then `NoiseSystem.emit_noise`. Capsule
readout: lerp albedo and emission by `LightSystem.get_brightness_at` — dim and
desaturated in shadow, bright saturated blue in light. Snack flag: while
carrying, emit loudness 0.3 every 0.6 s regardless of movement, including still.
Accept: VALIDATION S3.

### B2 — Door.gd and Snack.gd (brief 5 goal interaction)
One door script for bedroom, pantry, fridge. Hold `interact`: `openness` fills
0→1; fill time ~5 s, or ~1 s while `run` is also held. Release pauses where it
is. Emissions strictly ∝ |d openness/dt|: pantry and bedroom stream creak noise
through NoiseSystem while moving; fridge drives the `fridge` dynamic light
(radius and energy ∝ rate) so the player standing there lights up. Paused door
emits nothing and spills nothing. Snack: auto-acquired at openness ≥ 0.6; when
dropped (carry), it spawns at the drop point and can be re-collected.
Accept: VALIDATION S9 door and snack rows.

### B3 — Parent.gd (brief 5) — the big one
Routine is data: an array of `{ time, position, dwell, facing }` rows;
`get_base_target(t)` interpolates. Base behaviour is a pure function of time —
after carry or investigate, resume where the clock says, never where you left
off. `NavigationAgent3D` for movement. Vision: 60° cone, 7 m, node-yaw sweep
±35° on a slow sine; detection requires in-cone, clear line of sight, and
`get_brightness_at(player) > 0.35` — all three. Suspicion 0–100: noise
+loudness×10 with linear falloff over 8 m; seen +25/s; decay −8/s; at 50 push
investigate (navigate to remembered position, look ≤4 s, hard 10 s state
timeout, 8 s / 2 m repeat cooldown); at 100 carry. Readability hooks: tint the
cone toward amber with suspicion; on investigate stop dead, narrow the cone,
stop the sweep; on found accelerate and snap the cone wide. No suspicion bar,
ever.
Accept: VALIDATION S7, including the stand-in-the-dark-inside-the-cone test.

### B4 — Pet.gd (brief 5)
`BASE → ALERT → INVESTIGATE → BARK → BASE`. Base = fixed patrol circuit at
1.5 m/s, time-indexed like the parent. On `noise_emitted` within 6 m: ALERT —
freeze a full 1.0 s (telegraph, not optional). Then navigate to the noise; if
the player is within 2 m on arrival, BARK: `emit_noise(pos, 5.0, self)`. No
vision. Same investigate timeout and cooldown rules as the parent.
Accept: VALIDATION S8.

### B5 — Friday: routine rows (brief 5.4, 7.2)
Add as data, not code: drink retrieval around phase 2 (kitchen, dwell 15 s) —
promoted, it is the best tension in the game; bathroom trip phase 3 crossing
the hall; lights-off walk phase 4 room to room. Author the late rows so the
parent contests the dining route exactly when the clock makes it attractive.
Accept: VALIDATION S10 route-contest row.
