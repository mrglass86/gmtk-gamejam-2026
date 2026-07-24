# Decision Log

Record decisions another session or tool would otherwise have to rediscover.

## Template

```md
## YYYY-MM-DD — Decision title

- **Decision:**
- **Why:**
- **Rejected / cut:**
- **Owner:**
- **Revisit when:**
- **Evidence / handoff:**
```

## 2026-07-22 — Shared memory convention

- **Decision:** `gamejam/` is the cross-tool project memory; `STATE.md` is the
  short dashboard, `DECISIONS.md` is durable rationale, `BACKLOG.md` is the
  prioritized work queue, and `handoffs/` holds session-level context.
- **Why:** Claude and Codex should consult the same file-based source of truth.
- **Rejected / cut:** Relying on either tool’s chat history as project memory.
- **Owner:** Whole team
- **Revisit when:** The project needs a detailed bug tracker.
- **Evidence / handoff:** Initial workspace setup

## 2026-07-23 — Direction: Shoulda Eaten Dinner

- **Decision:** Adopt the externally designed brief (toddler stealth; the
  countdown is the parent's bedtime routine; the house gets darker-but-safer and
  quieter-but-riskier as it drains). Canonical copy at
  `gamejam/brief/shoulda-eaten-dinner-brief.md`. Its locked sections are design
  law; the planner owns scheduling, lane splits, and cut timing only.
- **Why:** Full design phase already done in a separate session; the brief is
  internally consistent, jam-scoped, and has a pre-agreed cut order.
- **Rejected / cut:** The three earlier theme-response candidates (Bank the
  Clock, Fuse Line, Descending Order).
- **Owner:** Noah (design lock), Claude (plan)
- **Revisit when:** Never during the jam — the cut order resolves conflicts.
- **Evidence / handoff:** `gamejam/handoffs/2026-07-23-plan-kickoff.md`

## 2026-07-23 — Roles: Claude plans and validates, Codex builds

- **Decision:** Two Codex lanes per brief 9.3 — lane A systems (only MCP
  connection), lane B actors (files only, never edits scenes). Noah does editor
  work, playtests, and all tuning calls. Claude writes work packages, reviews
  every commit, runs integration gates against `gamejam/VALIDATION.md` via the
  web build in its browser pane, keeps shared memory, and enforces cut
  trip-wires (`gamejam/PLAN.md` section 4).
- **Why:** Matches the brief's two-agent split, Noah's voice-first
  review-and-decide workflow, and this Claude instance's constraints (no shell;
  file tools plus browser-pane verification).
- **Rejected / cut:** Claude on editor MCP (a second driver on one live editor
  corrupts scene state); Claude as a coding lane.
- **Owner:** Whole team
- **Revisit when:** A lane sits idle waiting on reviews.
- **Evidence / handoff:** `gamejam/PLAN.md`, `gamejam/codex/lane-a-systems.md`, `gamejam/codex/lane-b-actors.md`

## 2026-07-23 — Spec rulings (planner notes against the locked brief)

- **Decision:**
  1. `GameClock.phase` is 0..4 (interface said 0..3; the section 4 table has
     four transitions). Phase 0 = start; transitions at 240/180/120/60 s
     remaining; timings `@export`-tunable. Phase state applied as a pure
     function of phase so scrubbing stays consistent.
  2. All door emissions ∝ rate of openness change (the bold rule in section 5
     wins over the fridge table row); a paused door emits and spills nothing.
  3. Caught → carry: parent navigates to the crib, player attached and input
     locked, snack drops at the catch point, suspicion resets to 0, routine
     resumes at the current clock time.
  4. Entering the crib holding the snack wins immediately (no dead idle time).
  5. Ring audibility radius = post-mask loudness × 8 m (the parent's hearing
     radius), capped at 20 m.
  6. Additive LightSystem helper for the fridge spill:
     `register_dynamic_light(id, pos)` / `set_dynamic_light(id, radius, energy)`.
  7. Renderer: Compatibility (web-safe). AreaLight3D-on-web is unverified —
     Thursday's export smoke test proves it or invokes the omni-cluster
     fallback (visual only; brightness is analytic either way).
  8. Pet is a dog; snack auto-acquired at openness ≥ 0.6; footsteps emit
     post-mask.
- **Why:** Each closes a gap or internal contradiction the brief left; none
  reopens a locked design call. Brief section 3 requires interface changes be
  noted in the repo — this is that note.
- **Rejected / cut:** Openness-scaled fridge emissions (kills crack-and-wait);
  contextual ring gating (brief forbids it); Forward+ web export (WebGPU is
  judge-hostile).
- **Owner:** Claude
- **Revisit when:** A ruling contradicts observed play — tuning numbers are
  free to move without a new entry.
- **Evidence / handoff:** Stubs in `game/autoload/`, lane briefs in `gamejam/codex/`

## 2026-07-23 — Schedule and cut trip-wires

- **Decision:** Thursday = systems (build order 1–6) plus the throwaway web
  export check; Friday = actors and full loop, freezing 19:00 with tag
  `jam-friday` and an itch draft upload; Saturday = audio (2 h cap), one
  outside playtest, tuning, optional dithering only if green by 15:00,
  submission page. Trip-wire table in `gamejam/PLAN.md` section 4 binds each
  cut to a clock time — invoke by lookup, no renegotiation.
- **Why:** The brief mandates a banked Friday build; pre-agreed trip-wires are
  the rested-brain version of 1 a.m. triage.
- **Rejected / cut:** Negotiating cuts at the moment of crisis.
- **Owner:** Claude (enforcement), Noah (override)
- **Revisit when:** A trip-wire fires early or the Thursday exit criteria slip.
- **Evidence / handoff:** `gamejam/PLAN.md` sections 3–4

## 2026-07-23 — Division of labour revised: Noah directs, agents build everything

- **Decision:** Noah is the game director: decisions, checkpoint playtests,
  feel verdicts, cut approvals, paste-able commands only — no editor
  construction, ever. All scene and editor work moves to Codex lane A as
  package A0 (greybox level, camera, actor stubs, navmesh, hazard placement as
  directed). Agent-authored `.tscn` files are sanctioned. MCP preference flips
  to `Coding-Solo/godot-mcp` first (npx only, no editor-plugin install —
  lowest setup burden), 30-minute abort unchanged. Claude may use computer
  control for GUI-only dialogs (export templates, itch upload walkthrough) and
  window screenshots; it stays off editor MCP and does not construct via GUI.
- **Why:** Noah has little Godot experience and wants the director seat. Brief
  9.3's "layout stays yours" and its hand-edited-scene caution were premised on
  a hands-on operator; with agents building, direct `.tscn` authoring of
  primitive greybox scenes is the practical path. The locked layout content in
  brief section 7 still governs what gets built — only the hands changed.
- **Rejected / cut:** Teaching the editor mid-jam; Claude driving the editor
  GUI as a construction path (slow and error-prone next to text authoring and
  MCP).
- **Owner:** Noah (mandate), Claude (plan)
- **Revisit when:** Agent-authored scenes start corrupting or MCP instability
  costs a block.
- **Evidence / handoff:** `gamejam/PLAN.md` sections 1, 1.1, 6; lane briefs

## 2026-07-23 — Identity pass: construction-paper menus + family voice acting

- **Decision:** (1) Menu chrome (title/win/lose only) adopts the director's
  hand-drawn construction-paper-and-crayon style, built from his Photoshop
  mockup exported as layered transparent PNGs — the in-game world's
  greyscale+hue language stays locked; the contrast is intentional framing.
  (2) The brief's "do not record anything" rule is overruled for ORIGINAL
  family voice clips (operator's daughter + operator), capped at one ~20 min
  phone session, wired as swaps over the retained CC0 fallbacks. The parent's
  "hm?"/"what was that?" doubles as an investigate voice tell (readability).
  Publishing the child's voice is the operator-parent's explicit call; no
  names appear anywhere.
- **Why:** Highest charm-per-minute assets available; gives the game an
  identity beyond mechanics; the no-recording rule was a time-budget rule and
  the time now exists.
- **Rejected / cut:** Restyling the in-game world or adding HUD; unbounded
  recording/re-recording sessions.
- **Owner:** Noah (assets), lane A (integration post-freeze), Claude (boundary)
- **Revisit when:** Assets miss the Saturday-morning integration window —
  CC0 + plain menus ship fine without them.
- **Evidence / handoff:** BACKLOG "Director's parallel art track".

## 2026-07-23 — Third-run rulings: masking scope, bark alarm, capture epilogue

- **Decision:** (1) Ambient masking applies ONLY to player-caused noise
  (footsteps, wrapper) — the pet's bark emits unmasked; it is the house's
  alarm and must summon the parent even beside the TV. (2) TV/speaker masks
  reduce, never erase — strength ≈ 0.6 cap, tight radii. (3) Capture epilogue
  (directorial): after depositing the player, the parent exits the kid
  bedroom, closes the BedroomDoor (re-arming the creak-open opening move),
  waits ~3.5 s in the hall, peeks back once, then resumes the routine at now.
  (4) Carry gets a hard 20 s force-deposit failsafe — soft-locks must be
  structurally impossible. (5) The carried snack is a first-class visual:
  larger, emissive, pulsing, with pickup sting and pop — the wrapper-ring
  mechanic only reads once carrying is visible.
- **Why:** Director's third run: deaf parent (mask overtune + masked bark),
  a carry soft-lock, and a still-invisible snack. All observed live.
- **Rejected / cut:** Masking door creaks differently (pantry sits outside
  mask range anyway); silencing the wrapper while standing (it IS the
  return-leg mechanic).
- **Owner:** Noah (behavior beats), lanes A/B (B7/A8), Claude (verify gates)
- **Revisit when:** CP4/CP5 replay verdicts.
- **Evidence / handoff:** B7/A8 work orders in chat + BACKLOG.

## 2026-07-23 — Character-art stretch ruling: sprites maybe, rigs never (this jam)

- **Decision:** Rigged 3D characters (the parked `assets/*.glb`) are out for
  the jam regardless of schedule — brief scope lock plus they fight the
  load-bearing colour/readability language. 2D animated sprite actors are an
  accepted Saturday stretch goal behind the same gate as dithering (everything
  green by 15:00, playtest and audio done) and COMPETING with dithering — one
  look upgrade, not two. Cheap-path spec: capsule stays as invisible collider
  and shadow-caster; visible mesh swaps to a flat-tinted silhouette Sprite3D
  drawn for the fixed camera angle; frames sync to the existing footstep
  timer; hue and brightness modulation carry over unchanged.
- **Why:** Fixed ortho camera removes billboard artifacts, making sprites
  cheap; rigging is a days-class rabbit hole named "Out" by the brief.
- **Rejected / cut:** Rigged GLBs in the jam build; any texture/detail pass
  that breaks hue-belongs-to-actors.
- **Owner:** Noah (look), Claude (gate enforcement)
- **Revisit when:** Saturday 15:00 gate, or post-jam.
- **Evidence / handoff:** BACKLOG Could section; `assets/` GLBs parked.

## 2026-07-23 — Risk-check alignment (docs/BRIEF_RISK_CHECK.md adopted)

- **Decision:** The workspace's researched risk check governs four technical
  calls. (1) Lighting rig: `AreaLight3D` is shadowless in the Compatibility
  renderer → area lights carry only glow (TV, window, door strip); the shadow
  language comes from shadowed spot/omni lights; gameplay brightness stays
  analytic either way. (2) Navmesh: one static editor bake, no runtime
  rebaking; agents advance via `get_next_path_position()` each physics frame.
  (3) Web export: single-threaded; the first input starts game and audio
  together; no audio-bus effects. (4) Dithering must pass a 30-minute
  actors-stay-colored prototype or be cut immediately. MCP alternate if the
  wired Coding-Solo bridge fails inside the abort window: Funplay (risk check
  section 5).
- **Why:** Resolves the AreaLight3D-on-web unknown at planning time instead of
  Thursday night, and pins the navmesh/audio gotchas before agents hit them.
- **Rejected / cut:** Brief section 0's blanket "use AreaLight3D" read as a
  shadow source on web; runtime navmesh baking as a development default.
- **Owner:** Claude
- **Revisit when:** The Thursday export proof contradicts the risk check.
- **Evidence / handoff:** `docs/BRIEF_RISK_CHECK.md`, `docs/GODOT_REFERENCE.md`,
  lane briefs + VALIDATION.md updated same day

## 2026-07-23 — Directorial relayout (A0.2): Noah's floor plan replaces the brief 7 arrangement

- **Decision:** Adopt the director's mockup as the level layout (translation:
  `gamejam/codex/a02-layout-spec.md`; mockup archive owed to
  `gamejam/brief/layout-mockup-v2.png`). The five locked layout properties are
  preserved and mostly strengthened: goals split to opposite corners (fridge
  kitchen NE, pantry closet SE) so goal choice = route choice; the quiet
  carpet corridor passes the adult bedroom door with the light strip (the
  adult door IS the parent's door — closes the deferred fix-5 question); the
  teaching creak sits outside the kid door with an added carpet runner for the
  creak→silence lesson; new bathroom = dark pocket + routine destination; dog
  bed anchors the pet patrol. Zone names stay bedroom/hall/living/kitchen per
  the locked interface — `hall` now means the middle band + alcove lamps.
- **Why:** Director rejected the first greybox as not matching intent; the
  brief explicitly leaves apartment dimensions open to change, and the mockup
  satisfies every locked constraint.
- **Rejected / cut:** Keeping the brief section 7 literal arrangement.
- **Owner:** Noah (layout), Claude (spec), lane A (build A0.2)
- **Revisit when:** Route timing at F3 misses the 1.4–1.6× target (S10) —
  tune with furniture and entrances, not by reopening the layout.
- **Evidence / handoff:** Mockup PNG, `a02-layout-spec.md`, A0.2 commit

## 2026-07-23 — Static-collider navigation bake at startup

- **Decision:** Replace A0's unsafe hand-authored navigation polygons with one
  synchronous startup bake after `LevelBuilder` has created its immutable
  floors, walls, props, and hazard overlays. The bake parses only the
  `nav_source` static-collider group, with agent radius 0.4 m, max climb 0.25 m,
  and 0.1 m cells; it is asserted to contain polygons and never rebaked in play.
- **Why:** CP1 review found the manual mesh crossed a bedroom wall and ignored
  kitchen furniture, so it could not support B3 parent/pet navigation safely.
- **Rejected / cut:** Continuing to hand-maintain polygons; dynamic or repeated
  runtime bakes; runtime obstacle carving.
- **Owner:** Lane A
- **Revisit when:** Level geometry changes after startup (not in current scope).
- **Evidence / handoff:** `gamejam/handoffs/2026-07-23-cp1-review.md`,
  `aa4fbf4`.

## 2026-07-23 — Parent FOUND chase precedes carry

- **Decision:** At maximum suspicion, the parent carries only when the player is
  within the 1.1 m grab distance; otherwise the parent enters a FOUND chase at
  3.8 m/s toward the player's live position. FOUND uses the locked 90-degree
  red cone, exits after 5 seconds without line of sight to INVESTIGATE at the
  last-known position with suspicion 60, and cannot be downgraded by noise.
  Parent routine timing follows `GameClock.run_length` unless an explicit
  positive routine-duration override is configured.
- **Why:** A visible chase makes detection legible and prevents a full suspicion
  meter from causing a remote, teleport-like catch. Using the shared clock keeps
  authored routine timing synchronized with run-length tuning.
- **Rejected / cut:** Immediate carry at maximum suspicion regardless of
  distance; an independent default routine clock.
- **Owner:** Noah (design), lane B (implementation)
- **Revisit when:** CP4 shows the chase is unavoidable or too easy.
- **Evidence / handoff:** B3 review and commit `946cd11`.

## 2026-07-23 — First-walk actor readability and door collision ruling

- **Decision:** Render the parent's cone as an 11-ray, static-hit-clipped floor
  fan rebuilt from its live transform. Routine sweep occurs only while the
  parent is pathing; dwell uses the routine row's fixed facing. Door panels are
  visual-only, while `Door.gd` owns a thin doorway blocker that disables at
  openness 0.35. Goal doors reveal the shared snack at their own position.
- **Why:** The first director walk exposed dishonest through-wall cone geometry,
  a TV-watching parent who would not hold a gaze, and fridge-panel collision
  that physically shoved the player.
- **Rejected / cut:** An unclipped triangle cone; sweeping during dwell; using
  the rotating visual panel as gameplay collision.
- **Owner:** Noah (director), lane B (implementation), lane A (scene cleanup)
- **Revisit when:** CP4 shows cone edges disagreeing with detection, or CP5
  shows a blocker size does not match its doorway.
- **Evidence / handoff:** Director's first-walk B3.1+B3.2 fixpack.

## 2026-07-23 — Second-walk floor safety and fridge hinge ruling

- **Decision:** Every authored floor rectangle deliberately overlaps its
  neighbors, backed by a 30 × 12.8 m hardwood collision slab whose top is
  0.05 m below the playable floor and which is excluded from `nav_source`.
  The fridge door hinges at its far/east edge and opens north against the back
  wall. Interim Parent rows are 0/60/82/242 s with 53/15/151/58 s dwells.
- **Why:** The second director walk found a real east-hall floor hole, an
  implausible fridge swing, and routine travel windows too short for walking.
- **Rejected / cut:** Relying only on visually abutting rectangles; keeping the
  near-edge fridge hinge; teleport-like routine timing.
- **Owner:** Noah (director), lane A (scene implementation)
- **Revisit when:** B5 adds the bathroom trip or changes the Friday routine.
- **Evidence / handoff:** A5.1 commit `003e714` and `--verify-a51`.

## 2026-07-23 — A6 game flow owns the Web gesture and all terminal states

- **Decision:** One `DinnerGameFlow` controller owns TITLE/PLAYING/WON/LOST.
  The first pressed keyboard, mouse, touch, or joypad event hides the title,
  unlocks the player, and starts `GameClock` in the same callback. The
  warning-producing generator placeholder is removed; Saturday's first real
  imported sound must hook this same transition. A non-blocking crib goal
  volume wins when occupied with the snack; expiry applies the same
  crib-plus-snack predicate. Terminal states pause play, and R unpauses before
  reloading the scene.
- **Why:** A single transition point satisfies Web autoplay rules and prevents
  actor/UI work from starting the clock or audio independently.
- **Rejected / cut:** Auto-starting in `Main._ready`; separate title/audio/clock
  gates; adding a menu stack or changing the solid approved crib greybox.
- **Owner:** Noah (rules), lane A (implementation)
- **Revisit when:** CP5 finds the crib goal too generous or the first-input cue
  conflicts with the Saturday audio pass.
- **Evidence / handoff:** Commits `d3a9d5d`, `e26ce9c`, `0223b1b`,
  `--verify-a6`, and `gamejam/handoffs/2026-07-23-a6-formal-report.md`.

## 2026-07-23 — Scene-side, first-input CC0 audio architecture

- **Decision:** `DinnerAudioDirector` observes the existing actor, noise, phase,
  and game-flow signals without changing lane B scripts. It uses only plain
  `AudioStreamPlayer` / `AudioStreamPlayer3D` nodes, direct `volume_db`
  changes, and a player-mounted `AudioListener3D`; no bus effects. Every stream
  starts at or after `GameFlow.game_started`. TV and speaker playback positions
  and max distances match their analytic masking sources.
- **Why:** This keeps Web autoplay, single-threaded export, lane ownership, and
  the audio/masking theme relationship explicit and independently verifiable.
- **Rejected / cut:** Generator placeholders, pre-gesture playback, audio-bus
  effects, actor-script audio edits, and non-CC0 sources.
- **Owner:** Lane A
- **Revisit when:** The director's listening pass finds a countdown tell or
  masking bed misleading; tune exported direct volumes before replacing clips.
- **Evidence / handoff:** `d34f4a8`, `CREDITS.md`, `--verify-audio`, clean
  release Web canvas-click proof.

## 2026-07-23 — A7 presentation mirrors analytic state

- **Decision:** Use a resizable 1920×1080 viewport with `canvas_items`/`expand`
  stretch while leaving the Web canvas preset unchanged. A real fridge
  `OmniLight3D` mirrors the analytic openness rate and clears at zero; the TV
  AreaLight flickers subtly until phase 2; held-door creak volume mirrors
  openness rate and stops when motion stops. Pet cues are actual CC0 dog clips.
  Scene-side snack feedback observes existing signals, and its reveal visual
  clears either goal-door panel.
- **Why:** The director's audio walk found that fridge risk, TV shutoff, door
  effort, pet identity, and snack interaction needed matching visible or
  audible presentation.
- **Rejected / cut:** Constant fridge light; timer-driven creak; bus effects;
  non-dog or non-CC0 pet clips; changes to lane B actor scripts.
- **Owner:** Noah (director), lane A (implementation)
- **Revisit when:** The next director listening pass finds a tell or masking
  bed misleading.
- **Evidence / handoff:** `3def8f8`, `--verify-a7`, clean release Web
  canvas-click proof, renderer captures, and `CREDITS.md`.

## 2026-07-23 — Actor acceptance uses live clocked SceneTree behavior

- **Decision:** Actor verification starts `GameClock` and advances the real
  SceneTree clock/physics loop, asserting visible outcomes rather than routine
  table math or script scans. The dog sleeps on its bed for the first 30
  seconds, then exits the bed and patrols. Parent sight gain stays 1x beyond
  4 m and scales to 3x at or within 2.5 m.
- **Why:** The director twice observed an immobile parent despite static route
  checks passing. Live verification reproduced two physical faults: navigation
  tolerances smaller than actor-to-navmesh height, and the dog bed baking as a
  disconnected walkable island.
- **Rejected / cut:** Treating table interpolation as proof of movement;
  class/property scans as actor acceptance; immediate dog patrol; globally
  accelerating distant sight gain.
- **Owner:** Noah (director), lane B (implementation and verification)
- **Revisit when:** CP4/CP5 shows the dog egress motion reads poorly or
  point-blank detection is too abrupt.
- **Evidence / handoff:** `acaed9d`, `--verify-b6`; live metrics: parent 9.33 m
  displacement and 0.68 m kitchen approach, dog 0.00 m sleep drift and 3.27 m
  patrol displacement, point-blank suspicion 100.

## 2026-07-23 — Practical lights own the neutral-cool hierarchy

- **Decision:** Every static zone light is a visible primitive fixture whose
  emissive shade and child Omni shut off together by phase. Fixture glow stays
  neutral-to-cool; warm hues remain exclusive to alerts. Static Omni range is
  5.8 m and environment ambient energy is 0.08.
- **Why:** Visible sources make countdown shutoffs legible, while localized
  pools and lower ambient give lit-versus-unlit floor meaningful contrast
  without changing the analytic brightness system.
- **Rejected / cut:** Invisible ceiling Omnis; warm domestic bulbs that compete
  with alert language; global darkness that hides room structure.
- **Owner:** Noah (art direction), lane A (implementation)
- **Revisit when:** The CP4 lighting replay finds a route unreadably black or a
  phase shutoff visually ambiguous.
- **Evidence / handoff:** `8812b29`, `89187fe`, `--verify-a9`, and
  `gamejam/handoffs/2026-07-23-a9-lighting.png`.

## 2026-07-23 — Verification reports prove the committed tree

- **Decision:** Every lane A/B verification report must run its editor startup
  check and package verifier from a clean working tree whose tested files match
  `HEAD`. Stash unrelated pending work before the gate, commit the candidate,
  then test that exact commit.
- **Why:** A working-directory pass can include an uncommitted helper or fix
  absent from the reviewed commit, allowing a parse-dead actor into the build.
- **Rejected / cut:** Reporting checks run before the candidate commit or from
  a dirty worktree without proving the on-disk blobs equal `HEAD`.
- **Owner:** Lanes A and B
- **Revisit when:** Never during the jam; a later CI gate may automate it.
- **Evidence / handoff:** Director's B8 parse report; reconciliation commit
  `556aa4c`; clean-HEAD Godot 4.7.1 editor startup and `--verify-b8`.

## 2026-07-23 — A10 practical presentation uses honest physical silhouettes

- **Decision:** The bathroom quiet-zone entrance is a scripted
  `Level/BathroomDoor` with a stationary doorway blocker and collisionless
  panel. The fridge door occupies the kitchen-facing west side, hinges at its
  north/wall edge, sweeps outward through open kitchen space, and rests along
  the north wall. Static ambient energy is 0.05. Trial lamps are debug-only
  L/K placements whose scroll-adjusted radii print as `_add_omni` rows.
  Carpet footsteps sit 15 dB below hardwood.
- **Why:** Run five needed readable furniture and pet silhouettes, a usable
  quiet-zone door, a physically honest fridge swing, stronger countdown light
  cues, darker unlit floor, and rapid director-controlled light placement.
- **Rejected / cut:** The visual-only ajar bathroom panel; the inward fridge
  sweep through its body; collision on a moving door panel; release-build
  placement tools; bus effects or dynamic mix processing.
- **Owner:** Noah (art direction), lane A (scene/presentation implementation),
  lane B (Parent/Pet routine consumers).
- **Revisit when:** Director run six finds the fridge orientation, TV pulse,
  bathroom passage, or 0.05 ambient floor unreadable in live play.
- **Evidence / handoff:** `6436fdd`–`606a627`, combined head `a9efbae`,
  `--verify-a10`, `--verify-b9`, and the three A10 labeled renderer captures.

## 2026-07-23 — Run-six actors make visible reach and haste truthful

- **Decision:** (1) A noise ring is exactly the parent's hearing reach:
  `min(loudness × 8 m, 20 m)` with linear falloff. (2) The bathroom door
  closes for the parent's dwell and opens on exit; the late route crosses the
  carpet band and ends facing the kid door around 292 s; the dog periodically
  visits its bowl. (3) Dwelling parents glance 100–160° every ~15 s. Noise
  accumulation at 75 without sight enters amber-red HUNT toward the newest
  heard event; HUNT uses found speed/cone and exits below 60 or after 8 s.
  Player run noise is 1.2.
- **Why:** The hard 8 m listener contradicted visible rings, while a naive
  40-second sprint bypassed the routine's tension.
- **Rejected / cut:** Invisible fixed-radius hearing; a passive couch dwell;
  escalating unseen noise directly to omniscient FOUND.
- **Owner:** Noah (direction), lane B (actors), lane A (bathroom/bowl props)
- **Revisit when:** Director run six finds HUNT unavoidable, unreadable, or
  still too easy to outrun.
- **Evidence / handoff:** `a9efbae`, `bb1dc61`, clean-HEAD `--verify-b9` and
  `--verify-b10`.

## 2026-07-23 — A11 separates visual detail from lighting and navigation cost

- **Decision:** Low emissive shades remain visible practical fixtures, while
  their rendered Omni sources sit at y 4.5 and bias toward room centers.
  Positional shadow filtering is High; shadowed Omnis use blur 2.0 and every
  shadowed light uses opacity 0.8. Furniture may use many primitive silhouette
  meshes, but each table-and-chair group contributes one simplified nav
  collider. The dog's local front is `-Z`, matching Pet movement facing.
  Creak hazards use three alternating hardwood-family planks and one collider.
- **Why:** Run six found hard black wall wedges, unreadable block tables, a
  directionless dog, a front-door walkway obstruction, and beacon-bright
  creaks. Separation preserves readable dressing without destabilizing
  gameplay brightness or nav complexity.
- **Rejected / cut:** Lights at shade height; one-block table visuals; per-leg
  or per-chair collision; a walkway floor lamp; emissive or high-contrast
  creak markers.
- **Owner:** Noah (art direction), lane A (scene implementation), lane B
  (authoritative Pet facing).
- **Revisit when:** The director's next renderer walk finds a room unreadable,
  shadows still wedge-shaped, or table collision too broad.
- **Evidence / handoff:** `6df8cff`, `6b48552`, combined head `23ffd7c`,
  clean committed-tree `--verify-a11`, B6/B9/B10 regressions, and
  `gamejam/handoffs/2026-07-23-a11-lighting.png`.

## 2026-07-23 — Threat visuals expose escalation and dog hearing

- **Decision:** Parent cone presence scales with threat: alpha starts at 0.12,
  lerps to 0.34 with suspicion, uses 0.40 in HUNT, and remains 0.45 in
  FOUND/carry. The awake dog shows its exported hearing radius as a faint
  purple floor ring that pulses yellow during ALERT/INVESTIGATE; the ring is
  hidden for its opening sleep.
- **Why:** Threat should become visually louder as danger rises, and the dog
  needs an honest, readable reach before it reacts.
- **Rejected / cut:** A constantly prominent parent cone; an invisible dog
  hearing radius; showing the dog ring while it sleeps.
- **Owner:** Noah (direction), lane B (actor presentation)
- **Revisit when:** Director run six finds the calm marks distracting or the
  alert pulse unreadable at gameplay camera scale.
- **Evidence / handoff:** `1fada23`, clean committed-tree `--verify-b12`.

## 2026-07-23 — Original audio remains audition-gated with CC0 fallback

- **Decision:** A13 family voice and A14 household foley stay unwired until the
  director names exact keeper candidates and event mappings. Selected original
  foley replaces the corresponding CC0 cue through nonrepeating variation pools
  with ±5–8% pitch jitter; selected voice follows the A13 event mapping with
  ±5% jitter. Empty or unselected categories retain their CC0 fallback.
- **Why:** The director must judge performance and recording quality, while the
  existing CC0 pass preserves a complete, shippable mix during auditions.
- **Rejected / cut:** Automatically wiring every processed take; deleting CC0
  cues when an original category is empty; treating transcript guesses as
  keeper assignments.
- **Owner:** Noah (audition and mapping), lane A (post-pick integration)
- **Revisit when:** The director returns exact keeper filenames and mappings.
- **Evidence / handoff:** `assets/voice/candidates/MANIFEST.md` and
  `gamejam/handoffs/2026-07-23-lane-a-a14-audio-intake.md`.
