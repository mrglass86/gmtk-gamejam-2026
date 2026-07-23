# Codex lane A — systems and scenes

You are the systems-and-scenes engineer for a two-day Godot jam game. The human
on this project is the game director, not a builder — you own everything that
happens inside the Godot project, including the level itself. Read
`gamejam/brief/shoulda-eaten-dinner-brief.md` (design, locked),
`gamejam/PLAN.md` section 2 (naming contract), and `gamejam/VALIDATION.md`
(your acceptance tests) before writing code.

## Guardrails

- Godot 4.7.1 only. Re-read brief section 0 (version notes) and
  `docs/BRIEF_RISK_CHECK.md` (proof tests + fallbacks); documentation links and
  lookup order live in `docs/GODOT_REFERENCE.md` — 4.7 branch only, never
  `latest`. Do not enable HDR output; use Context7 when available. Reject every
  Godot 3 idiom on sight:
  `Spatial`, `KinematicBody`, `connect("x", self, "_m")`, `yield`. In 4.x:
  `Node3D`, `CharacterBody3D`, `signal_name.connect(callable)`, `await`.
- Typed GDScript. Every tuning number is an `@export`.
- The three autoload interfaces in brief section 3 are locked. One additive
  extension is pre-approved (see A2). Any other change: propose it in
  `gamejam/handoffs/`, do not make it.
- You own everything scene-side: the greybox level, camera, actor scene stubs,
  navmesh, hazard prefabs and placement — plus the autoload implementations,
  indicator scenes, masking zones, phase director, debug keys, title/win/lose
  UI, and export presets. You may author `.tscn` files directly as text and/or
  through the Godot MCP connection — both are sanctioned (DECISIONS
  2026-07-23). Only this lane touches scenes.
- You never touch `Player.gd`, `Door.gd`, `Snack.gd`, `Parent.gd`, `Pet.gd` —
  lane B owns those. Lane B's node requests land in `gamejam/WIRING.md`;
  clear them on your next scene pass and check them off.
- If the director opens the editor to peek, pause scene writes until he closes it.
- Verify by running: MCP run/debug output when connected, otherwise headless
  runs. Prefer looking at real output over reasoning about it.
- Commits: plain imperative messages. No co-author trailers, no exclamation marks.
- End every session by appending a short handoff to `gamejam/handoffs/`.

## Planner rulings you build against (already logged in DECISIONS.md)

- `GameClock.phase` is 0..4; phase 0 = start; transitions at 240/180/120/60 s
  remaining. Apply world state as a pure function of phase so scrubbing works.
- Ring audibility radius = post-mask loudness × 8.0 m, capped at 20 m.
- All door emissions are proportional to the rate of openness change; a paused
  door emits nothing.

## Work packages, in order

### A0 — Greybox level, camera, actor stubs (brief 6.1, 7)
First, verify the scaffold: the project opens clean in 4.7.1 and every input
action in the naming contract exists — the input map was hand-serialized; fix
and note anything broken. Then build `scenes/Main.tscn` out per the brief's
section 7 map: the two-route loop (bedroom → hallway/dining → kitchen, living
room open to dining), half-height walls ~1.2 m, fixed orthographic camera over
the whole floor plan, zone lamps (neutral-to-cool white only) registered per
zone, floor colliders in the four surface groups with visually distinct greys
per surface, untextured primitives only. Lighting rig per risk-check section 1:
`AreaLight3D` only for shadowless glow surfaces (TV, window, under-door strip);
the readable shadow language comes from shadowed `SpotLight3D`/`OmniLight3D` —
AreaLight3D cannot cast shadows in the Compatibility renderer. Stub scenes with
the contract names: `Player` (CharacterBody3D + capsule), `Parent`, `Pet`,
`Crib`, `Fridge`, `Pantry`, `BedroomDoor`, `NightstandClock`.
`NavigationRegion3D` baked once, statically (drive the editor bake; no runtime
rebaking per risk-check section 2); agents advance with
`get_next_path_position()` every physics frame and must not path through the
half-height walls — check collision and agent height per brief section 5.
Fridge and pantry on opposite kitchen sides; carpet laid deliberately as the
silent highway (brief 7.3).
Post a screenshot (MCP or a headless capture) for the director's layout pass
before A1 consumes the level.
Accept: VALIDATION S1.

### A1 — LightSystem (brief 3, 4)
Registered lights carry zone, position, radius, enabled. Brightness at a point =
max contribution of any enabled light, linear falloff to zero at the radius
edge. `set_zone_enabled` flips a whole zone and emits `lighting_changed`.
Registration mechanism is your call — document it. Add a temporary on-screen
brightness number for the player position.
Accept: VALIDATION S2.

### A2 — NoiseSystem plus the dynamic light helper (brief 3, 4)
The bus re-broadcasts; listeners do their own falloff; no filtering. Implement
`get_mask_at` against registered ambient sources (A4 fills the sources in).
Additive, pre-approved: `register_dynamic_light(id: String, pos: Vector3)` and
`set_dynamic_light(id: String, radius: float, energy: float)` on LightSystem so
lane B's fridge can spill analytic light scaled by rate (id `fridge`).
Accept: VALIDATION S4 core.

### A3 — Noise indicators and teacher hazards (brief 6.3, 6.8, 7.5)
Immediately after A2 — before anything else consumes noise events. Ring = 8
radial spokes expanding to exactly the audibility radius, fading at arrival.
Icon = billboarded `Sprite3D` at the source, rises ~0.5 m, fades over 1.2 s,
scale maps to loudness. Sustained sources stream small rings with a jittering
icon. Absolute render threshold 0.25 post-mask loudness — never contextual.
Colour `#FF2D95`. Player rings must visibly shrink near the playing TV.
Then hazards: one `NoiseSurface.tscn` prefab with exported
`loudness_multiplier` and `radius`. Place the two teachers: creaky board
(mult 3.0) in the hallway directly outside the bedroom door, outside the
parent's hearing, with a carpet strip immediately after; first toy (mult 4.0)
where its ring is visible but survivable. Every later hazard placement comes
from the director's play notes, not your judgement.
Accept: VALIDATION S4 in full, threshold table verbatim; S10 teacher rows.

### A4 — Ambient masking zones (brief 4)
TV and kitchen speaker as registered ambient sources with a mask radius;
`get_mask_at` returns the strongest overlap. The phase director turns them off
on schedule and their masking dies with them.
Accept: VALIDATION S5.

### A5 — GameClock finish, phase director, debug keys, nightstand clock (brief 4, 10.1)
Finish the scaffolded `GameClock.gd`. Phase director applies the section 4
table (living light → TV → kitchen light + speaker → hall) idempotently from
the current phase value. Debug keys behind `OS.is_debug_build()`: `]` +30 s,
`[` −30 s, `\` overlay (suspicion, actor states, player brightness, mask, last
loudness), `P` teleport player to cursor on navmesh, `N` spawn a `NoiseSurface`
at cursor with scroll-wheel loudness. Nightstand clock: `Label3D`, red m:ss,
readable from the ortho camera, in the world not the HUD.
Accept: VALIDATION S6.

### A6 — Friday: win/lose, title, restart, export (brief 1, 2, 10.2)
Title card with controls; win when the player enters the crib holding the
snack, or survives to expiry in the crib with it; lose at expiry otherwise.
Restart reloads the scene. The first input on the title card starts the game
and audio together (web autoplay rules, risk-check section 3); direct volume
changes only — no audio-bus effects on web. Web export preset: threads off,
Compatibility renderer. Thursday already proved the pipeline with a throwaway
export — keep that preset.
Accept: VALIDATION S9 UI rows and S11.
