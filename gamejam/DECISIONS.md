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

## 2026-07-24 — Lane C added: adversarial QA / playtest agent

- **Decision:** Add a third Codex lane (C) dedicated to breaking the game —
  exploits, soft-locks, edge cases, state-machine collisions — via scripted
  adversarial headless scenarios plus a randomized monkey/fuzz bot, driving
  REAL ticked play (the gap where `--verify-*` passes but play breaks). Lane C
  NEVER edits gameplay; it writes test scripts (`game/tests/qa/`) and a ranked
  report (`gamejam/qa/findings.md`); fixes route to A/B via Claude. Brief:
  `gamejam/codex/lane-c-playtest.md`.
- **Why:** The recurring failure mode all jam has been "green gates, broken
  play" (deaf parent, free-win-on-catch). An adversarial tester that plays the
  game weirdly catches what checklists and the author miss.
- **Rejected / cut:** A Claude subagent for this (can't drive the live game
  with ticked time the way a Codex headless run can).
- **Owner:** Noah (runs lane C), Claude (routes findings to A/B)
- **Revisit when:** Findings dry up, or post-submission.
- **Evidence / handoff:** `gamejam/codex/lane-c-playtest.md`

## 2026-07-24 — SHIP-IT verdict reached; lighting-gradient ruled a renderer limit

- **Decision:** The director's full-play verdict is positive and definitive:
  the game wins and loses, the chase is "fun and exciting," switches "feel
  good," and he "literally laughed out loud" fleeing with the snack. This is
  feature-complete and ship-worthy. The one open note — lighting feels
  "gradient" not naturally bounced — is ruled a KNOWN CONSTRAINT of the
  Compatibility (web-safe) renderer, which has no global illumination; lamps
  are direct point sources by necessity. Fake-bounce polish (fill lights,
  per-room ambient tint) is a POST-FREEZE, cuttable item, never a blocker.
  Path to freeze: land B18/A21, re-validate, tag + export + itch draft, then
  post-freeze polish only. `jam-safety-1` protects the current good build.
- **Why:** After ~40 packages over two days, the director confirmed the core
  loop is fun in live play. Continued iteration past a positive verdict on
  freeze day is the classic way a finished game misses its deadline.
- **Rejected / cut:** Chasing true bounced light on the web renderer (not
  available); treating the lighting note as a freeze blocker.
- **Owner:** Noah (verdict), Claude (freeze enforcement)
- **Revisit when:** Post-freeze polish window; Saturday.
- **Evidence / handoff:** This session; `jam-safety-1` tag.

## 2026-07-24 — Light-agency feature accepted; regression gate; freeze-day trip-wire

- **Decision:** Run-six directorial batch. (1) REGRESSIONS FIRST (B13):
  perception must stay live through the post-deposit epilogue (code-read
  suspect: both perception paths early-return through all post-deposit
  states), and FOUND gains a bigger grab radius plus a direct close-range
  lunge — director acceptance in play required before features. (2) FEATURE
  ACCEPTED: player-and-parent light agency — five switches (dining, kitchen,
  foyer lamp, bathroom, hall-by-kid-door punishment light), parent tracks
  phase-expected light state and restores anomalies, parent turns the TV off
  to listen while alerted and back on when settled, living/dining wall
  removed, all light from practicals with inverse-square visual falloff
  (analytic untouched). Epilogue peek v3 = real crib check with a clock-burn
  scold if the player is out. (3) Trip-wire: not green by 15:00 → degrade to
  player-switches-only; threatens 17:00 → cut feature; 19:00 freeze immovable.
- **Why:** Director's run six: two live regressions plus a feature that
  deepens the locked light-inversion theme rather than diluting it.
- **Rejected / cut:** A snack "rummage" hold (illustrative only, not ordered);
  parent VO as real noise events (dog would investigate its owner — visual
  indicator only).
- **Owner:** Noah (feature design + acceptance), lanes (B13/B14/A16), Claude
  (gate + trip-wire enforcement)
- **Revisit when:** B13 acceptance run, then 15:00 trip-wire check.
- **Evidence / handoff:** B13/B14/A16 work orders in chat, 2026-07-24 ~01:30.

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

## 2026-07-24 — Director-named picks drive data-defined original audio

- **Decision:** The director's flat `assets/voice/picks/` folder is casting
  truth. Selected takes are copied to anonymous runtime pools. `AudioCasting`
  defines pools and ordered event steps; selection avoids immediate repeats
  and adds 5–8% pitch jitter. One dedicated VO player enforces
  carry/deposit > catch/found > chase/routine priority. Catch passes one
  `had_snack` boolean to select red-handed versus empty-handed protest.
  Unfilled events keep their CC0 fallbacks.
- **Why:** The director has made performance choices; a data table keeps
  sequencing, context, and substitutions auditable without branching event
  code or exposing family names in the committed runtime tree.
- **Rejected / cut:** Wiring audition candidates directly; filename parsing at
  runtime; parallel overlapping voice players; removing CC0 coverage; assigning
  the unmatched kitty line without a scenario.
- **Owner:** Noah (casting), lane A (integration)
- **Revisit when:** The director's mix walk changes a keeper, event delay,
  priority, or pool assignment.
- **Evidence / handoff:** `assets/voice/A15_CASTING.md`,
  `game/scripts/AudioCasting.gd`, and `--verify-audio`.

## 2026-07-24 — Hearing uses bounded source bursts and two-cue interest

- **Decision:** Sustained emitters count suspicion at most once per source
  every 0.4 s, and one uninterrupted sustained burst supplies only one interest
  cue. A first received contribution of at least 10 enters CURIOUS: stop, face
  the source, play the parent “hm?” tell, and hold about 2 s without walking.
  A second qualifying cue within 8 s, or any visual sighting, starts the normal
  INVESTIGATE walk. HUNT remains immediate at 75 suspicion. Bark and toy
  single-shots are never suppressed by the sustained-source cooldown.
- **Why:** Door streams emit every 0.12 s and were stacking a full contribution
  per tick, while a single sound jumping straight to a walkover denied the
  player a readable warning beat.
- **Rejected / cut:** Per-tick full suspicion; a single 25+ sound immediately
  walking the parent over; globally reducing the ruled 1.5 switch click before
  source tracing distinguishes it from the door stream.
- **Owner:** Noah (director), lane B (hearing behavior), lane A (interaction
  overlap follow-up)
- **Revisit when:** The director’s B15 play finds CURIOUS too permissive, or a
  source trace proves the switch—not the door stream—is the dominant cue.
- **Evidence / handoff:** B15 work order and director follow-up, 2026-07-24.

## 2026-07-24 — A17 uses renderer-only hot practicals and exclusive interaction

- **Decision:** Keep Omni attenuation at 2.0, Sun absent, and ambient at 0.05;
  raise only practical renderer energy to 32.0 so lit rooms recover the A10
  pool brightness. Interaction resolves to one nearest target, with doors
  winning exact distance ties. Player steps use separate 8-take CC0
  carpet/wood pools; family foley remains on household props and parent steps.
- **Why:** Lower Omni energy left the raised 4.5 m sources cave-dark. Overlapping
  independent input handlers could trigger a door and switch together, and the
  family player-step takes did not meet the director's quality bar.
- **Rejected / cut:** Restoring Sun or flattening attenuation; player-centered
  prompts; multi-target E presses; replacing family household foley.
- **Owner:** Noah (director), lane A (world/audio/UI implementation)
- **Revisit when:** The director's in-motion contrast pass finds clipped hot
  cores, or the CC0 step mix masks sub-threshold carpet feedback.
- **Evidence / handoff:** `2d4e142`, `--verify-a17`, and
  `gamejam/handoffs/2026-07-24-a17-lighting.png`.

## 2026-07-24 — Idle giggles are rare, honest player-authored noise

- **Decision:** During active free play, an unattached and input-enabled player
  self-giggles at a newly randomized 20–45 s interval. Each giggle emits one
  fixed, unmasked 0.5 `NoiseSystem` event from the player, producing the
  standard 4 m magenta ring/icon. Carry and TITLE/WON/LOST states pause the
  timer. Audio observes `Player.idle_giggled`; it never emits a second gameplay
  event and excludes the tagged event from footstep/wrapper inference.
- **Why:** The toddler should create a tiny involuntary risk that remains
  legible and mechanically honest wherever it occurs.
- **Rejected / cut:** Masking the tell below its promised 4 m ring; giggling
  during capture or result screens; implementing a second timer in the audio
  layer; treating the event as wrapper or footstep noise.
- **Owner:** Noah (director), lane B (player behavior), lane A (audio playback)
- **Revisit when:** CP5 finds the giggle too frequent, too loud in the mix, or
  unfair during a close pass.
- **Evidence / handoff:** B16 work order and `--verify-b16`, 2026-07-24.

## 2026-07-24 — Snack identity belongs to the shared Snack

- **Decision:** Goal doors pass an explicit `StringName` identity on reveal:
  FRIDGE defaults to `ice_cream`, PANTRY to `chips`. The shared `DinnerSnack`
  stores the value in its public `snack_type` property and emits
  `snack_type_changed`; pickup, carry, catch-drop, ground drop, and re-collection
  never mutate it.
- **Why:** Visual and audio presentation need stable item identity throughout
  the round trip, independent of where the shared Snack node currently sits.
- **Rejected / cut:** Inferring type from world position after reveal; storing
  type only on Door or Player; clearing/reselecting type on drop or pickup.
- **Owner:** Noah (director), lane B (identity authority/API), lane A
  (presentation/audio consumption)
- **Revisit when:** The design adds a third snack or permits exchanging one
  carried snack for another during the same run.
- **Evidence / handoff:** B17 work order and `--verify-b17`, 2026-07-24.

## 2026-07-24 — Practical shadows use invisible full-height wall blockers

- **Decision:** Keep practical sources high at 4.5 m, but extend each authored
  wall to 5.2 m with a shadow-only mesh. Every practical Omni casts soft
  shadows at renderer attenuation 1.45 and 7.8 m visual range; ambient remains
  0.05 and the 5.8 m analytic light model remains unchanged.
- **Why:** High decoupled sources otherwise leak over the intentionally low
  greybox walls. Shadow-only extensions make pools end at walls while allowing
  honest spill through door gaps without changing collision, nav, or sight.
- **Rejected / cut:** Lowering sources back to fixture height; raising visible
  walls into the fixed camera; changing analytic brightness or sight thresholds.
- **Owner:** Noah (contrast verdict), lane A (renderer implementation)
- **Revisit when:** The director's in-motion walk finds lit rooms flat, a
  doorway spill unclear, or any Compatibility/Web shadow discrepancy.
- **Evidence / handoff:** `338de63`, `--verify-a18`,
  `gamejam/handoffs/2026-07-24-a18-lighting.png`, and
  `gamejam/handoffs/2026-07-24-a18-wall-blocking.png`.

## 2026-07-24 — Composite level props use fitted single colliders

- **Decision:** Preserve the approved A0.2 layout, but derive one box collider
  from the complete visual bounds of each composite nav prop. Use a fitted
  cylinder for the round dog bed. Door blockers match their closed panel
  dimensions exactly; decorative fixtures, wall switches, bowl, mat, and
  front-door overlay remain collisionless where the supporting wall/floor
  already supplies collision.
- **Why:** Hand-entered padded footprints left colliders shorter, wider, or
  differently centered than the visible crib, couch, tables/chairs, toilet,
  fridge body, and side table. Exact bounds remove invisible snags and holes
  while retaining one nav shape per group.
- **Rejected / cut:** Redesigning room or furniture footprints; adding a
  collider per primitive part; using visible door panels as rotating physics
  bodies.
- **Owner:** Noah (visual verdict), lane A (geometry/collision implementation)
- **Revisit when:** CP5 exposes an invisible snag, a route regression, or a
  gameplay prop needs a deliberately larger interaction footprint.
- **Evidence / handoff:** `bb881ac`, `--verify-a19`, and
  `gamejam/handoffs/2026-07-24-a19-geometry-audit.png`.

## 2026-07-24 — Snack identity changes presentation, never mechanics

- **Decision:** `SnackVisualPresenter` consumes `DinnerSnack.snack_type`
  directly: PANTRY/chips is a bright pulsing foil packet; FRIDGE/ice cream is
  a pulsing cone and scoop. Pantry pickup/carry uses the existing grab and
  wrapper skin. Fridge pickup uses the director's cleaned kid “mmm” take plus
  a soft scoop, then a quiet spoon-tap carry skin with no crinkle. Both types
  retain Player's single authoritative 0.3 loudness event every 0.6 s.
- **Why:** The goal choice should read and sound different without changing
  the locked return-leg stealth cost or inferring identity from world position.
- **Rejected / cut:** Separate Snack actors; position-based type inference;
  fridge wrapper audio; different noise radii/cadences by snack type.
- **Owner:** Noah (director), lane B (identity authority), lane A
  (visual/audio presentation)
- **Revisit when:** A third snack type is added or CP5 finds either primitive
  silhouette/audio skin unclear in motion.
- **Evidence / handoff:** `8f92e36`, `0da7c83`, `--verify-a20`,
  `--verify-audio`, and `--verify-b17`.

## 2026-07-24 — Big cues and unauthorized light changes investigate immediately

- **Decision:** Keep the B15 two-cue model for received contributions from 10
  through 29.9. Any single post-falloff contribution of at least 30 bypasses
  CURIOUS and starts INVESTIGATE immediately, unless the existing 75-suspicion
  HUNT escalation has priority. Any actual wall-switch toggle not authored by
  the parent also investigates immediately, even when its click is inaudible.
  General analytic-light changes are evaluated after same-frame phase
  application settles; off-schedule switch-light changes investigate, while
  scheduled phase transitions and parent restores do not.
- **Why:** Toy traps, close creaky running, and nearby barks are the game’s
  strongest authored alarms and need an immediate consequence. Light changes
  are visible household anomalies, not merely positional click sounds.
- **Rejected / cut:** Sending every 10+ cue straight to a walkover; making
  brightness awareness depend on the switch click’s hearing radius; reacting
  to transient intermediate states inside one phase-application call.
- **Owner:** Noah (director), lane B (parent intelligence)
- **Revisit when:** CP5 finds the 30 threshold too binary, or an authored light
  transition is incorrectly classified as player-caused.
- **Evidence / handoff:** B18 items 1–2 work order and
  `--verify-b18-core`, 2026-07-24.

## 2026-07-24 — Shadow walls include upper doorway frames

- **Decision:** Every authored wall segment keeps a shadow-only blocker from
  floor to at least 0.7 m above the highest practical source. Each bounded
  inter-room doorway also gets a shadow-only lintel from 2.4 m to the same
  height, so light can spill through the lower opening but cannot treat it as
  a floor-to-ceiling hole. `LightSystem.nearest_switch_to(pos)` returns a
  dictionary with the closest switch node, its `light_id`, and distance.
- **Why:** The 4.5 m hall source projected a broad wedge through the unbounded
  kid-room doorway even though adjacent wall segments had 5.2 m blockers.
  Parent searchlight staging also needs one stable source of switch/light
  identity.
- **Rejected / cut:** Raising visible cutaway walls; lowering practicals;
  sealing doorways completely; duplicating LevelBuilder's switch table in
  Parent.
- **Owner:** Noah (bug ruling), lane A (renderer geometry and helper)
- **Revisit when:** A doorway spill becomes too narrow in motion or another
  bounded opening is added.
- **Evidence / handoff:** `94c3879`, `--verify-a21`, and the labeled A21
  before/after captures.

## 2026-07-24 — Dark searches take one light-switch diversion

- **Decision:** On entering a dark area during INVESTIGATE or HUNT, Parent uses
  `LightSystem.nearest_switch_to` to visit the nearest off practical, turns it
  on with the normal click, then resumes the live investigation/noise target.
  Each controlled light is attempted at most once per continuous search
  episode. B14's explicit anomaly-restoration target retains priority.
- **Why:** The parent should act intelligently in a dark house without losing
  the player/noise objective or bouncing forever between an ineffective switch
  and the search target.
- **Rejected / cut:** Duplicating the switch map in Parent; repeatedly trying
  the same switch when its pool does not light the route; rerouting routine,
  carry, FOUND, or explicit B14 anomaly behavior.
- **Owner:** Noah (director), lane A (nearest-switch contract), lane B
  (search diversion)
- **Revisit when:** Export smoke finds a switch visit visually confusing, or a
  new room places its nearest switch outside the reachable nav region.
- **Evidence / handoff:** `94c3879`, `--verify-a21`, and live
  `--verify-b18`, 2026-07-24.

## 2026-07-24 — Plain sneak footsteps sit below the visible-noise gate

- **Decision:** Set Player's exported `sneak_noise_multiplier` to 0.2. Keep
  surface multipliers unchanged at hardwood 1.0, creaky 3.0, toys 4.0, and
  keep the run multiplier at 1.2. The resulting unmasked profile is 0.2 on
  hardwood, 0.6 on creaky boards, 0.8 on toys, and 1.2 for run-hardwood.
- **Why:** Quiet floors plus shadows need to support deliberate stealth, while
  authored boards and toys remain obvious risk gates instead of every sneak
  step producing the same visible warning.
- **Rejected / cut:** Lowering all surfaces; lowering run noise; adding a new
  stealth mode or threshold system; hiding creaky/toy tells.
- **Owner:** Noah (director), lane B (Player tuning)
- **Revisit when:** Export play finds plain sneak inaudible to the player
  rather than merely low-risk, or trap surfaces fail to read.
- **Evidence / handoff:** B19 work order and live `--verify-b19`, 2026-07-24.

## 2026-07-24 — Parent perception tells only what the parent can know

- **Decision:** The wall-clipped cone is split into floor-brightness cells:
  brightness at or above 0.35 uses the vivid threat colour, while darker cells
  are faint. Non-parent light changes are noticed only when their fixture is
  currently in the cone with line of sight, or enters it within a two-second
  memory window; switch-click noise is ignored by Parent. A player-authored
  single-shot of at least 3.0 loudness gets the 30-point big-event floor, and
  base visual suspicion rises at 40/s.
- **Why:** Threat graphics and reactions must expose the same stealth rules;
  omniscient light detection, quiet-looking danger, and four-second far-cone
  sight contradicted the director's QA play.
- **Rejected / cut:** Uniform cone opacity; hearing switch clicks; persistent
  expected-zone scans; retaining 25/s far-cone sight; weakening quiet steps.
- **Owner:** Noah (director), lane B (Parent behavior and presentation)
- **Revisit when:** Web profiling finds the segmented fan expensive, or play
  finds 1.2-second far-cone registration too harsh.
- **Evidence / handoff:** `b9dfecf`, live `--verify-b21`, 2026-07-24.

## 2026-07-24 — Family VO chains follow live gameplay states

- **Decision:** Reserve `carry_red_handed_01` for the one-shot game-start
  motivation line. During `FOUND`, continuously chain the combined chase/win
  giggle pool; during `CARRY`, chain kid protests selected by catch snack
  context and periodically interleave the matching parent-grunt pool. Stop
  those chains on the authoritative state/deposit signals. Use
  `caught_grunt_03` for catch and reserve 01/02 for chance-based world bumps.
- **Why:** The live state lifetime naturally makes voice coverage scale with
  each chase and carry without predicting path duration, while one dedicated
  VO player preserves clear casting and priority.
- **Rejected / cut:** Predicting carry time from distance; a fixed single
  protest; overlapping a second VO player; inferring geometry bumps inside
  AudioDirector.
- **Owner:** Noah (director), lane A (casting/scheduler), lane B (world-contact
  trigger)
- **Revisit when:** A listening pass finds the 0.14–0.30 s chain gaps or
  3.0–4.8 s parent-grunt cadence too dense.
- **Evidence / handoff:** `eed6e31`, `--verify-audio`, A23 handoff, and the
  open A23 row in `WIRING.md`.

## 2026-07-24 — Crib wins use player-centre containment

- **Decision:** `GameFlow` tests the player's centre against the authored crib
  goal with an 0.08 m tolerance. `Area3D.overlaps_body()` is not an alternate
  success path.
- **Why:** Body overlap inflates the goal by the player capsule radius and
  awarded a win at the reported 2.04 m beside-the-rails position. Centre
  containment keeps the open-end approach reliable without accepting the
  parallel outside edge.
- **Rejected / cut:** Shrinking the visual crib; using raw body overlap;
  redesigning the goal or layout during freeze.
- **Owner:** Lane C (finding), lane A (GameFlow fix)
- **Revisit when:** The inside approach misses at gameplay speed.
- **Evidence / handoff:** A6 immediate/expiry verification and lane-C
  `crib-margin` scenario, 2026-07-24.

## 2026-07-24 — Quiet carpet corridor is a switchable light gamble

- **Decision:** Light the bottom carpet corridor with two shadow-casting
  overhead practicals controlled together by a new `carpet_hall` wall switch.
  The switch exposes one stable primary light id to
  `LightSystem.nearest_switch_to`, while its secondary target follows the same
  state. Lit west/center/east probes must exceed the unchanged 0.35 detection
  threshold; switching the pair off must return all three below it. Dining,
  kitchen, kid-hall, and foyer practicals become flush ceiling discs; the kid
  nightstand remains a lamp.
- **Why:** The quiet carpet route had no meaningful light tradeoff and could
  hide a point-blank player. A player-controlled pair makes it a readable
  stealth choice without changing global ambient, analytic falloff, or sight
  thresholds.
- **Rejected / cut:** Raising ambient light; widening unrelated room lights;
  adding analytic-only spill without a visible source; changing inverse-square
  renderer settings, shadow casting, or the 0.35 gameplay threshold; restyling
  the kid nightstand.
- **Owner:** Noah (director), lane A (lighting and switch implementation)
- **Revisit when:** The director's in-motion pass finds the lit corridor too
  punishing, the switch hard to read, or either overhead pool visually weak.
- **Evidence / handoff:** `281cbab`, `--verify-a22`, and the labeled A22
  before/after and fixture captures, 2026-07-24.

## 2026-07-24 — Switch clicks are presentation-only

- **Decision:** A wall-switch flip may play its soft positional click but emits
  no `NoiseSystem` event. Parent awareness of unscheduled light changes remains
  exclusively on the existing switch/light-state signal path. Each squeaky-toy
  hazard uses one 2.6 × 1.4 m, 0.02 m-tall overlay carrying a spread
  pill/train/block visual pile.
- **Why:** A switch is a visible household-state anomaly, not a hearing cue.
  Wider toy piles make the authored noise trap more likely to catch a careless
  route while remaining flat and readable.
- **Rejected / cut:** Retaining a low switch loudness; invisible trigger-only
  expansion; adding colliders to individual toy meshes.
- **Owner:** Noah (director), lane A (switch and hazard presentation)
- **Revisit when:** The click is inaudible to the player or a widened pile
  blocks a route.
- **Evidence / handoff:** `cebba87`, `--verify-a24`, and A16/A17/A19/A22 plus
  B14/B18 regressions.

## 2026-07-24 — Post-freeze perception polish: sight range, trap summon, light memory

- **Decision:** Three surgical `game/scripts/Parent.gd` fixes from the director's
  live playtest, all default/export or logic changes, no scene edits (the Main
  Parent node overrides neither export).
  1. Raise `vision_range` 7.0 → 9.5 so a brightly lit player across the
     A16-merged living/dining (wider than 7 m) is seeable. Cone angle,
     brightness gate, and line-of-sight checks are unchanged, so only reach
     grows; close-range detection verifies still pass.
  2. Make the solid-stomp big-event floor source-agnostic. In `_on_noise_emitted`
     any single-shot at or above `solid_stomp_loudness_threshold` (3.0) that is
     not a pet and not a door now gets the 30-point big-event floor and
     investigates immediately from anywhere in its audible ring, bypassing
     falloff and the two-cue curious stage. Player run-stomps on toys (surface
     4.0 → 4.8 loudness) and creaky boards (3.0 → 3.6) already hit this via the
     old `source is DinnerPlayer` gate; the generalization also covers any
     future trap that emits from its own node. Pets keep the bark model
     (`event_alert_threshold` floor, so far barks stay CURIOUS), doors keep the
     sustained two-cue creak — both are excluded via an `elif` after the pet
     branch and a `not (source is DinnerDoor)` guard.
  3. Light-change awareness persists until seen or resolved instead of expiring
     after 2 s. `light_change_memory_duration` raised 2.0 → 120.0 (a safety
     backstop, not the drop window), and the recent-change scan now forgets a
     change once the zone is back to its phase-expected on/off state. The parent
     still learns of a change only visually (cone plus line of sight); switch
     clicks stay silent, so B21's visual-only rule holds.
- **Why:** Director QA found a lit player invisible past 7 m across the open
  room; far-hallway toy/creak stomps read as traps but falloff dropped them
  under the investigate threshold beyond ~7 m; and a dining light flipped across
  the room was forgotten before the cone swept it.
- **Rejected / cut:** Applying the stomp floor to pets or doors (breaks the B15
  far-bark and first-rush-door CURIOUS gates and B9 far bark); a truly infinite
  or purely state-based light memory (B21 `expired_change_ignored` requires a
  finite, test-reachable expiry, so unbounded memory cannot pass — the timeout
  stays, tied to `light_change_memory_duration`, kept under ~195 s so B21's
  expiry loop reaches it inside its 12000-frame budget); adding new `--verify-*`
  code to the frozen script (Bash is blocked in this instance, so new verify
  code is uncompilable here and a parse slip would fail the whole suite — the
  two candidate tests are described as manual checks instead).
- **Owner:** Noah (director), Claude (implementation), operator (runs verifies).
- **Revisit when:** The 120 s backstop reads too long or short in play, a
  non-player trap emitter is added that wants its own tuning, or the operator
  wants automated coverage for the source-agnostic summon and the
  persist-past-2 s light memory.
- **Evidence / handoff:** `vision_range`, the `_on_noise_emitted` floor,
  `light_change_memory_duration`, and `_update_recent_light_change_awareness` in
  Parent.gd. Verify battery: `--verify-b21 --verify-b15 --verify-b18-core
  --verify-b18 --verify-b6 --verify-b13`, plus touched `--verify-b8 --verify-b9
  --verify-b10 --verify-b12 --verify-b14`. Not committed; operator commits after
  review.

## 2026-07-24 — Trap surfaces: always loud, visually hidden in one wood floor

- **Decision:** Two paired director rulings from live play.
  1. Footstep trap floors in Player.gd: a step on a toy pile emits at least
     `toys_trap_floor` (4.0) and a step on a creaky board at least
     `creaky_trap_floor` (3.2) regardless of gait, applied before masking.
     Both sit above Parent's 3.0 stomp-summon threshold, so any trap step
     summons an immediate investigate from its full ring. Carpet and hardwood
     keep gait scaling; the unmasked B19 profile becomes 0.2 / 3.2 / 4.0 /
     1.2 and the live `--verify-b19` expectations move with it. This
     supersedes the earlier "Plain sneak footsteps" profile numbers (0.6 /
     0.8) — sneaking no longer silences a trap, only normal floor.
  2. One shared world-triplanar plank material (`WoodFloorMaterial.gd`,
     seeded procedural texture, no sourced assets) skins every hardwood slab,
     so the wood area reads as one continuous board floor and slab joints
     disappear. Creaky overlays sitting on wood (CreakKitchen, CreakAdult)
     set `show_surface_visual = false` and render nothing — the continuous
     floor beneath shows through, hiding the trap. The kid-hall CreakTeacher
     keeps its poke-through planks on the rug as the teaching example, and
     toy piles stay fully visible. This supersedes the earlier rejection of
     "hiding creaky/toy tells" for wood-sitting creaks only.
- **Why:** The director wants Mark-of-the-Ninja-style traps: toys and boards
  are route hazards you learn and path around, not tiptoe across, and a
  uniform wood floor must not advertise where the squeaks are.
- **Rejected / cut:** Hiding toy piles; hiding the rug teacher; a
  sneak-exemption on traps; sourcing a wood texture (agents cannot download
  in this setup).
- **Owner:** Noah (director), Claude (implementation), operator (verifies).
- **Revisit when:** First-run play finds invisible creaks unfair (re-add a
  faint seam tell), the 20 m trap rings read too punishing, or the world
  triplanar projection misbehaves in the web export.
- **Evidence / handoff:** `WoodFloorMaterial.gd`, LevelBuilder hardwood
  material branch, NoiseSurface `show_surface_visual`, Main.tscn creak
  overrides, Player trap floors, updated `--verify-b19` expectations.

## 2026-07-24 — First playtest round: hide the tells, flip the fridge, foyer trap

- **Decision:** From watching the first outside playtester (director's wife):
  1. The kid-hall CreakTeacher hides too (`show_surface_visual = false`) —
     every creaky board is now invisible and discovered by sound. Supersedes
     this morning's "rug teacher stays visible" carve-out.
  2. Ceiling practicals build no fixture visual at all; playtesters read the
     glowing discs as floor pickups. The floor light pool (plus the switch
     plates) is the light's only tell. The kid nightstand lamp keeps its
     furniture visual.
  3. New `ToyFoyer` squeaky-toy pile at (8.3, 4.75) beside the front-door
     shelf, gating the straight alcove line toward the pantry; both careful
     routes around it (hall side, door-mat side) stay open.
  4. The fridge door hinges on its right (east) edge: `DoorVisual` moves to
     the east corner, the panel extends west, and the swing mirrors to +90°.
     Interaction point, snack reveal, spill light, and blocker are unchanged.
- **Why:** Real-player reads beat authored intent: visible trap planks and
  glowing discs both misread, the fridge swing looked wrong, and the pantry
  route had no noise gate.
- **Rejected / cut:** Removing the nightstand lamp visual; moving the fridge
  interaction point with the hinge (would relocate snack reveal and spill).
- **Owner:** Noah (director), Claude (implementation), operator (verifies).
- **Revisit when:** A playtester cannot find any creak by trial, the alcove
  squeeze past ToyFoyer reads unfair, or the mirrored fridge swing clips a
  prop.
- **Evidence / handoff:** Main.tscn CreakTeacher/ToyFoyer/Fridge edits,
  LevelBuilder ceiling-fixture removal. Companion behavior fixes (bathroom
  set-piece audio and door, dog motion smoothing, dropped-snack marker, dog
  switch check) tracked in the same evening's engineer pass.

## 2026-07-24 — Playtest behavior fixes: bathroom set-piece, dog motion, dropped snack

- **Decision:** Three script-only fixes plus one investigation ruling from the
  wife's live web-build session.
  1. Bathroom visit is now a staged set-piece. Parent.gd opens the door ahead
     of arrival (entry lead = sneak_open_duration x open target + 0.75 s
     margin), holds within 1.2 m of the panel until openness clears the 0.35
     blocker threshold, closes it on arrival as before, and
     `bathroom_door_open_openness` rises 0.7 -> 0.85. A new
     `bathroom_visit_started` signal fires at the arrival close;
     AudioDirector plays the toilet/sink event from that signal and the
     wall-clock 189.4 s ROUTINE_EVENTS row is deleted (it silently expired
     whenever an investigate held the parent off ROUTINE across the window).
     BathroomFoley is promoted to the house-wide tell class: -13 -> -8 dB,
     max_distance 8 -> 18 m, matching the switch-click tells.
  2. Dog stutter was the time-indexed patrol carrot: the nav target refreshes
     every 0.05 m while the carrot moves ~0.17 m/s, so the dog stood still
     and hopped 5 cm at ~3 Hz. Pet.gd now glides straight toward the live
     carrot (capped by new `patrol_glide_max_distance` 0.5) once the nav path
     reports finished — presentational only; states, targets, noise, and
     ring are untouched.
  3. Dropped snack gets a rescue-beacon skin: Snack.gd tracks a
     presentation-only `was_dropped` flag (set on drop_at, cleared on pickup
     and door reveals) and SnackVisualPresenter pulses the same meshes with
     HUD-prompt-orange emission (0.96, 0.58, 0.28), faster/stronger energy
     pulse, and a 0.16 scale pulse. No new lights; mechanics and the 0.3
     loudness cadence unchanged.
  4. Ruling (investigate-only): the dog cannot touch lights — Pet.gd has no
     LightSystem/WorldSwitch references. The "dog turned off the kitchen
     light" read is the scheduled phase-3 sweep: GameClock phase 3 fires at
     exactly 180 s, PhaseDirector kills the kitchen zone and syncs the wall
     switch, AudioDirector clicks at the kitchen switch — and the patrol
     table puts the dog at its kitchen row (7.4, -1.5) at clock 180 exactly
     (cycle 60 s + 30 s sleep offset). Deterministic co-occurrence, not a
     bug.
- **Why:** Live playtest: parent phased through the closed bathroom panel
  with no flush/sink audio, the dog read as low-framerate, and the dropped
  snack vanished into the dark after a catch.
- **Rejected / cut:** Widening the audio table window or dropping its
  ROUTINE-state gate (flush would play with the parent mid-chase); repathing
  the dog every tick (cost, and the brief's smoothing intent); an OmniLight
  under the dropped snack (fakes lit floor, contradicts light=danger; scene
  edit territory); moving snack drop mechanics.
- **Owner:** Noah (director), Claude (engineer pass), operator (verifies).
- **Revisit when:** The 18 m flush tell reads too loud/quiet in play, the
  0.85 swing clips a prop, the dog's carrot-speed amble reads too slow, or
  playtesters want the dropped beacon on door-revealed snacks too.
- **Evidence / handoff:** Parent.gd door staging/hold/signal + noise guard,
  AudioCasting.gd ROUTINE_EVENTS, AudioDirector.gd handler + foley exports,
  Pet.gd glide, Snack.gd `was_dropped`, SnackVisualPresenter.gd dropped
  pulse. Battery: `--verify-b9 --verify-b6 --verify-b12 --verify-b14
  --verify-b13 --verify-b15 --verify-b8 --verify-b20 --verify-b17
  --verify-a20 --verify-audio`. Not committed; operator commits after
  review.

## 2026-07-24 — Hall rug retreats past the hidden bedroom creak

- **Decision:** HallRug shrinks from x -13.0..-4.0 to x -10.7..-4.0 (center
  -7.35, length 6.7 m). The kid-bedroom exit zone and the whole hidden
  CreakTeacher span (-12.7..-10.9) become exposed wood floor; the quiet rug
  resumes east of the creak and still carries the hall toy pile.
- **Why:** An invisible creak under carpet contradicts the carpet-is-quiet
  rule. Wood creaks are coherent; the first steps out of bed now teach the
  hidden-trap mechanic on an honest surface.
- **Rejected / cut:** Moving the creak instead (it belongs at the bedroom
  door); a visible rug seam tell.
- **Owner:** Noah (director), Claude (implementation).
- **Revisit when:** The noisier first steps out of bed read as unfair, or the
  rug's new west edge looks arbitrary in play.
- **Evidence / handoff:** LevelBuilder `HallRug` line; rides the evening's
  pending verify/commit batch.

## 2026-07-24 — Scheduled shutdowns are parent-initiated at the fixture

- **Decision:** No countdown light or TV change happens on a bare timer. A
  phase boundary arms a shutdown errand instead: the parent, next time the
  routine has control, walks to the controlling fixture or switch (living
  floor lamp, TV console, kitchen switch, then the dining and foyer switches
  for the final hall sweep) and initiates the change with the normal click —
  only then does the world state apply. If the parent is investigating,
  hunting, or carrying, the errand queues and the house stays lit until the
  routine resumes. Debug scrubbing force-completes pending errands so ]/[
  stays usable; restart resets them.
- **Why:** The playtester read a timer-driven kitchen light-off as the dog
  doing it. Diegetic shutdown makes the countdown watchable and honest — the
  bedtime routine is the parent visibly closing down the house.
- **Rejected / cut:** Keeping any bare-timer light change (director's rule is
  categorical); teleporting the parent to the switch.
- **Owner:** Noah (director), engineer pass 2 (implementation), Claude
  (spec and review), operator (verifies).
- **Revisit when:** Endgame pacing suffers because the phase-4 hall sweep
  chains two switch stops inside the last minute, or a queued errand starves
  long enough that a phase never visibly lands.
- **Evidence / handoff:** PhaseDirector.apply_phase is today's pure sweep
  (zone lines 65-71, fixture visibility 73-80); B14 asserts phase-2 TV
  behavior and B9 asserts routine row timing — implementation must read those
  verifies first and update expectations deliberately.

## 2026-07-24 — Parent-initiated shutdowns: implementation record

- **Decision:** Errand architecture as ruled, in scripts only.
  1. PhaseDirector splits into a signal path and a pure path. Live
     `GameClock.phase_changed` (clock moved by one frame's delta) ARMS
     errands — living(1), tv(2), kitchen(3), dining+foyer(4) — and a single
     `_write_world_state()` keys every shutdown line off applied effects
     instead of raw phase. The public `apply_phase(n)` keeps its legacy
     contract: force-complete to the pure end-state (used by A5/A7/A22
     direct calls and boot). Scrubs, direct time writes, `_enter_title`,
     and restarts are detected as clock jumps > `scrub_detection_jump`
     (5 s, exported) against a per-frame observed clock and route to
     `apply_phase` — live-boundary detection failing under low FPS
     degrades to the legacy instant sweep, never to a stall.
  2. Parent executes errands in the ROUTINE layer only (searchlight-style
     detour: walk, act 0.6 s, click, rejoin the live row). New exports:
     `shutdown_errand_reaction_delay` 2.0 (also keeps B6's 60 s kitchen
     sample green), `shutdown_errand_speed` 1.5, arrival 0.8, act 0.6.
     Kitchen/dining/foyer flip their real WorldSwitch under
     `_parent_operating_switch` (B14-restore exemption class); living lamp
     and TV console report to PhaseDirector, whose completion signal
     carries the presentation click (AudioDirector: living switch sound,
     TVClickOff). Claims defer while a routine door row span is active so
     an errand cannot pull the parent through the bathroom panel; busy
     states queue naturally (hook only exists in `_update_routine`).
  3. AudioDirector's faked phase clicks are deleted; ambient beds follow
     shutdown flags set by completions (silent on force-completions) and
     cleared by backward scrubs. Parent TV machinery
     (`_set_tv_enabled`/suppress/enforce/restore) keys off the applied tv
     effect with a raw-phase fallback when no PhaseDirector exists.
     `begin_audio_verification` expectations updated (B19 precedent): each
     boundary now asserts the errand-completion click instead.
  4. Kitchen ruling: the kitchen_speaker ambient dies on the same switch
     completion — one kitchen trip. Phase 4 ruling: per-stop fixture
     visibility (dining hides Mid+DiningEntry, foyer hides Alcove), hall
     zone falls when BOTH complete. Searchlight precedence: a pending
     errand still completes after the search; a searchlight-relit light
     whose errand already completed stays on (legacy parity, no re-arm).
  5. Player counter-play confirmed covered by existing machinery: post-
     errand the light is genuinely switch-state, `_is_switch_expected_on`
     already matches post-errand reality, so a player flip is a normal
     B14 anomaly restore. No new code.
  6. Verify shims, both precedented: `_prepare_point_blank_verification`
     force-completes pending errands (B6/B12 planted poses must not be
     walked away from); `--verify-b21` runs PhaseDirector in legacy
     timer mode (its 120 s live memory wait would otherwise send errand
     walks sweeping the staged dining anomaly) — same in-code flag
     precedent as the B15 counter.
- **Why:** Director ruling above; the errand delay is the intended
  pressure (multiple pending phases keep the house visibly lit late).
- **Rejected / cut:** Touching GameClock's locked interface for scrub
  detection (jump heuristic observes it instead); re-arming errands the
  searchlight undoes; a dining-zone split (no such zone exists — hall is
  the phase-4 zone); deferring AudioDirector bed state through polling
  (signal ordering with PhaseDirector is scene-order dependent; flags are
  order-independent).
- **Owner:** Noah (director), Claude (engineer pass 2), operator (verifies).
- **Revisit when:** Live play shows a starved errand keeping a phase
  invisible too long, the 5 s scrub threshold misreads on a very slow
  machine, the phase-4 two-stop chain crowds the endgame, or the dining
  stop's transient visual-vs-analytic mismatch (hall zone waits for both
  stops) reads wrong.
- **Evidence / handoff:** PhaseDirector.gd rewrite (arm/force split,
  `_write_world_state`), Parent.gd `_update_shutdown_errand` +
  `_perform_active_shutdown_errand` + door-window claim gate + TV
  gating, AudioDirector.gd completion handler + bed flags + edited
  `begin_audio_verification`. Battery: full B suite (b6 b7 b8 b9 b10 b12
  b13 b14 b15 b17 b18-core b18 b20 b21) + `--verify-a5 --verify-a7
  --verify-a8 --verify-a20 --verify-a22 --verify-audio` + QA scenarios
  (monkey, expiry set, restart-fuzz, switch-spam). Not committed.

## 2026-07-25 — Playtest pass 3: cone layer split, lamp body, dog yield, VO scribbles

- **Decision:** Four items from the director's post-pass-2 playtest; item 5
  (per-type sound-glyph language) descoped to a design per the allowance.
  1. Floor-detail collision leaves layer 1. NoiseSurface sets a new
     `surface_collision_layer` export (default 2) on itself; the Player
     OR-s a new `floor_detail_collision_mask` (2) into its scene mask so
     it still rides and slide-detects overlays (b19's detection is
     group-based, layer-agnostic). The parent's cone rays and LOS keep
     mask 1 and can no longer notch on flat or invisible overlays — a
     cone notch at empty floor was advertising the hidden creak trap.
     HallRug stays LevelBuilder-owned (forbidden this pass); flagged.
  2. The living-lamp shutdown no longer hides furniture. PhaseDirector's
     `_set_living_lamp_lit` keeps the Base/Pole/Shade body visible,
     toggles only the OmniLight child and swaps the shade's material to a
     duplicate with emission off (albedo kept — dark fabric read).
     Brightness is analytic (LightSystem), so this is purely cosmetic.
     A5's three living-lamp visibility asserts updated to the Light child
     (B19 precedent); disc-less ceiling practicals keep node visibility.
  3. Dog yields to the parent: presentational soft separation in Pet.gd
     (`parent_yield_distance` 0.7, `parent_yield_speed` 1.4) — a capped
     radial drift away, stronger with overlap, never while bedded or
     sleeping (b6 sleep drift 0.00 holds). Parent motion untouched.
  4. Parent VO indicator rebuilt as scribbles: the ParentVoiceIndicator
     node survives mesh-less (name + visible flag are asserted by b14 and
     the audio verify — expectations KEPT, not edited) and a new
     ParentScribbleEmitter (TVNoteEmitter pattern) watches it, spawning
     2-3 deterministic code-drawn sine-stroke squiggle sprites that rise,
     wobble, and fade in paper-white. Magenta stays reserved for
     noise-danger tells; b16's giggle ring is untouched.
- **Why:** Cone notches leaked hidden traps and read as broken; vanishing
  furniture broke the room; actor overlap read as a bug; the magenta VO
  block clashed with the danger-color language.
- **Rejected / cut:** Editing forbidden files (Main.tscn, Door.gd,
  DebugTools.gd, LevelBuilder.gd — the fixture region proved unnecessary
  since the lamp split mutates materials at runtime); Label3D font glyphs
  for scribbles (no-assets rule); parent-side separation (verify-locked
  paths); item 5 build-out this pass (battery risk) — design recorded in
  the engineer report: derive glyph type in NoiseIndicatorManager from
  the emitted source node + a Player surface-kind getter
  (`_current_surface_kind` already exists), AudioDirector call sites for
  presentation-only clicks, motion grammar per sound class.
- **Owner:** Noah (director), Claude (engineer pass 3), operator (battery).
- **Revisit when:** a21/a22's polygon==164 trips (then the navmesh parse
  mask must include layer 2 — orchestrator side), the yield radius reads
  wrong at the bowl, the scribble cadence reads too busy, or item 5 gets
  scheduled.
- **Evidence / handoff:** NoiseSurface.gd layer export, Player.gd mask,
  PhaseDirector.gd `_set_living_lamp_lit`, Main.gd A5 expectation edits,
  Pet.gd `_apply_parent_separation`, ParentScribbleEmitter.gd (new),
  Parent.gd `_setup_voice_indicator` rebuild. Full battery + QA rerun.
  Not committed.

## 2026-07-25 — Playtest round 2: readability and juice rulings

- **Decision:** From the director's morning session on the shipped build.
  1. Switches remount on real wall spans: DiningSwitch to z 2.0 (LVertical),
     KitchenSwitch to z -1.7 (inside DogKitchenDivider) — the old spots
     floated in doorway gaps.
  2. ToyFoyer moves to (9.7, 1.85): the trap now gates the kitchen-table to
     foyer-cabinet squeeze on the pantry corridor, not the front-door mat.
  3. Retro dither ships as an in-engine mockup: screen-space Bayer dither +
     per-channel palette quantise (`shaders/retro_dither.gdshader`) on a
     CanvasLayer under the UI, toggled with G, default OFF, deliberately
     outside the debug gate so the look is judgeable in the release web
     export. Director rules on default state (and whether the key stays)
     before submission.
  4. Over-door light leaks close: DoorStripGlow removed; the never-opening
     adult door's shadow frame drops to its panel top (lintel override
     1.25); every swing-door visual spawns a shadow-only extension from
     panel top to the 2.4 m doorway band, riding the panel so an opening
     door releases light with the swing — the bathroom visit now reads as a
     light cue.
  5. Doors read against walls: shared door panels turn a warm wood tone
     (0.49, 0.435, 0.375) with a knob cylinder at the free end; the fridge
     keeps an appliance tone via its own material. Pantry discoverability
     was the driving worry.
  6. Engineer pass 3 (behavior lane): cone rays must ignore floor-detail
     colliders (they notch on invisible creak boxes today — a secret leak);
     the living-lamp shutdown keeps the lamp body visible (glow and light
     die, furniture stays); parent/dog soft separation (dog yields,
     presentational only); the mutter block becomes floaty scribble words;
     and a per-type sound-glyph language (click pop, creak wobble, step
     dot, squeak burst — tempo matches the sound) built on the
     TVNotes/indicator patterns.
- **Why:** Round-2 live reads: floating switch, vanishing lamp, phasing
  actors, cone notches on hidden traps, indistinct doors, over-wall spill,
  and the chunky mutter block; the long-wished retro dither is now cheap to
  audition in-engine without Codex.
- **Rejected / cut:** A static image mockup for the dither (unjudgeable
  without motion and the real palette); recoloring walls instead of doors;
  removing the locked-adult-door fiction.
- **Owner:** Noah (director), Claude (scene/level/shader lane), engineer
  pass 3 (behavior lane), operator (verifies).
- **Revisit when:** The dither verdict lands (default on, off, or strip the
  key), a knob or shadow extension clips a swing, or the glyph language
  crowds the night read.
- **Evidence / handoff:** LevelBuilder switch/glow/lintel edits, Door.gd
  `_decorate_door_visual`, Main.tscn retro filter + fridge material + toy
  move, `shaders/retro_dither.gdshader`, and the pass-3 report when it
  lands.

## 2026-07-25 — Collision inspector on B; the fridge grows a handle

- **Decision:** (1) DebugTools gains a runtime collision inspector on the B
  key, deliberately outside the debug gate so it works in the web export:
  green unshaded no-depth wireframes for every NoiseSurface collider (the
  now-invisible creaks and the toy piles), door blockers, the crib win
  volume, and interaction-radius circles for every interactable. It reveals
  the hidden traps, so it MUST be stripped or debug-gated before the itch
  submission build — same pre-submission gate as the G dither key ruling.
  (2) The fridge door carries a long vertical handle bar on its free west
  edge (exports `fridge_handle_length` / `fridge_handle_edge_inset`),
  riding the panel so it swings with the door; swing doors keep their small
  knobs.
- **Why:** The director needs hitbox visibility while tuning invisible
  traps, and the fridge silhouette needed an unmistakable appliance tell.
- **Rejected / cut:** Godot's editor-only visible-collision mode (absent in
  release web builds); a handle on the hinge side.
- **Owner:** Noah (director), Claude (implementation).
- **Revisit when:** The submission build is cut (strip or gate B, rule on
  G), or the inspector should also show pet/parent perception radii.
- **Evidence / handoff:** DebugTools.gd KEY_B branch and wireframe
  builders; Door.gd `_add_fridge_handle`.

## 2026-07-25 — Paper stop-motion filter, margin controls, big clock, corner lamp

- **Decision:** Four director calls after the dither audition.
  1. The G filter becomes construction-paper stop-motion instead of Bayer
     dither: soft posterise (flat paper tones), fine paper-fibre grain, a
     coarse cutout wobble, and a slight exposure flicker — grain, wobble,
     and exposure all re-randomise at `boil_fps` (8) so the frame boils
     like hand-photographed cutouts. Same shader file, same G toggle,
     still default off pending the director's verdict.
  2. A persistent controls hint sits in the bottom screen margin during
     play (WASD sneak, hold Shift run, hold E open, R restart); the title
     and result cards draw over it.
  3. The nightstand clock scales up (font 48 to 64, pixel size 0.008 to
     0.01) — the countdown must read at a glance.
  4. The kid lamp leaves the nightstand for the far west floor corner so
     nothing obstructs the clock. Its analytic pool moves with it: the
     crib side of the bedroom is darker now (safer return leg), the west
     corner is lit. a1/a9/a19 expectations updated to the new anchor and
     floor-lamp form.
- **Why:** The Bayer look read as pixel-retro, not the construction-paper
  fiction; first-time players need controls without re-reading the title
  card; and the clock is the theme — nothing may sit in front of it.
- **Rejected / cut:** Keeping the dither as a second toggle (one look,
  one verdict); a HUD clock duplicate (the diegetic nightstand clock is
  the countdown).
- **Owner:** Noah (director), Claude (implementation), operator
  (verifies).
- **Revisit when:** The boil reads as noise on the itch embed, the darker
  crib corner changes catch/return balance in playtest, or the director
  rules on the filter default.
- **Evidence / handoff:** `shaders/retro_dither.gdshader` (paper-boil
  rework), Main.tscn ControlsHint + NightstandClock scale, LevelBuilder
  KidLampVisual corner move, Main.gd a1/a9/a19 expectation updates.

## 2026-07-25 — Sightline interactions, red world wireframes, fair toy hitboxes

- **Decision:** Three rulings from the director's in-editor inspector pass.
  1. Interactions require a wall-free flat sightline (0.95 m, under the
     1.2 m walls): pressing E at a switch mounted on the far face of a
     wall no longer works, and the HUD prompt hides with it. The target's
     own bodies are excluded so closed doors remain grabbable;
     floor-detail overlays (layer 2) never block.
  2. The B inspector adds RED wireframes for world collision — walls,
     furniture, crib, props — alongside the green gameplay set (traps,
     blockers, win volume, interaction radii). Floors stay undrawn.
  3. Toy piles trade their 2.6 x 1.4 blanket collider for three tight
     per-piece boxes (pill 0.92 x 0.62, train 1.25 x 0.58, block
     0.64 x 0.64, small grace margins): walking between the toys is now
     honestly silent. a24/a41/a19 expectations updated (3 colliders per
     pile, all floor-flush); b19's toy sample moves inside the train
     piece.
- **Why:** The through-wall flip read as a bug on sight; trap fairness
  must match the visible pieces now that placement is tuned with the
  inspector.
- **Rejected / cut:** Per-piece separate bodies (one body, three shapes —
  surface detection is body-group based); drawing floor slabs in red
  (blankets the view).
- **Owner:** Noah (director), Claude (implementation), operator
  (verifies).
- **Revisit when:** A legitimate interaction spot reads as blocked (ray
  height or furniture exclusions may need tuning), or piece margins feel
  stingy in play.
- **Evidence / handoff:** Player.gd `_has_interaction_sightline` + b19
  toy-sample export, NoiseSurface.gd `_add_toy_piece_collisions`,
  DebugTools.gd red world pass, Main.gd a24/a41/a19 updates.

## 2026-07-25 — Warm monotone art pass, style cycler, alarm clock, louder creaks

- **Decision:** Director's art-direction round on the paper-filter build.
  1. The house desaturates at the source (works with any filter): neutral
     warm light colour, neutral ambient and background, warm-grey walls,
     props, appliances, and fittings. Hue is reserved for the kid (blue),
     adult and dog (purple), snacks (now orange — packet, scoop, and the
     shared material; the dropped beacon shifts hotter red-orange to stay
     distinct), and the signal colours (threat red, magenta, hunt orange,
     clock red).
  2. Floorboards lengthen: ~0.26 m wide boards running 1.4-2.1 m with
     single-pixel fainter seams and less per-board jitter — boards, not
     tile.
  3. The nightstand digits sit on a physical dark alarm-clock body on the
     nightstand; the kid and living lamps become lamp-shaped (cylinder
     base and pole, truncated-cone emissive shade) keeping the
     Base/Pole/Shade contract; a9/a19 expectations updated (cool-emission
     assert dropped, kid shade is a CylinderMesh).
  4. The G key becomes a style cycler: off, paper stop-motion, storybook
     halftone, pencil hatch, VHS night-video — all boiling, all sharing
     the same shader with a style uniform. Director auditions and rules
     on one (and its default) before submission.
  5. Creaky boards get louder now (`creak_step_volume_db` -3 to +1, a18
     updated); the longer groan — creaky steps borrowing the recorded
     slow door-creak takes at lowered pitch — rides the next engineer
     audio micro-pass.
- **Why:** The blue/purple cast diluted the actor colours; the short
  planks read as tile; floating digits and cube lamps broke the fiction;
  the paper filter needs competitors to be judged fairly; the creak tell
  was too small for its gameplay weight.
- **Rejected / cut:** Desaturating via the filter (must hold when the
  filter is off); recoloring walls per room; a HUD clock.
- **Owner:** Noah (director), Claude (implementation), engineer (long
  creaks), operator (verifies).
- **Revisit when:** The style verdict lands, the orange snack fights the
  hunt-cone orange in play, or lamp cones clip furniture.
- **Evidence / handoff:** WoodFloorMaterial consts, LevelBuilder palette +
  `_add_fixture_visual` rebuild, Main.tscn environment/snack/clock-body,
  SnackVisualPresenter identity colours, Door.gd fittings,
  `retro_dither.gdshader` style uniform + DebugTools cycler, Main.gd
  a9/a18/a19 updates, AudioDirector creak volume.

## 2026-07-25 — Photographed construction-paper menu

- **Decision:** The title card becomes the director's photographed
  construction paper: the live game sits blurred and dimmed behind
  (`menu_blur.gdshader` on both cards' Dim rects), a centred stack of the
  black, scribbled-red, and blue paper cutouts drifts and tilts on
  desynchronised sines (`MenuPaperLayer.gd`), and four photo props float
  in the corners. White backgrounds are keyed out in a shader
  (`menu_paper_key.gdshader` — bright-and-unsaturated pixels go
  transparent), so no hand masking. The old navy panel goes transparent;
  its labels now sit on the blue paper. Photos live at 1600 px in
  `game/art/menu/` (converted from the director's HEICs via sips). The
  halftone print style (steady, no boil) is the director's current filter
  favourite. Corner-prop image assignments are provisional pending the
  director's manifest of which photo is which snack/crayon; the
  handwriting font (Route A OFL download or Route B calligraphr) swaps in
  when the file arrives.
- **Why:** Real photographed paper is the game's fiction made literal, and
  the shuffling stack reads as the toddler's craft table.
- **Rejected / cut:** Hand-masked alpha PNGs (shader key is faster and
  keeps edges); rebuilding labels as part of the photos (text stays live
  for edits and the coming font).
- **Owner:** Noah (director, photos, manifest, font), Claude
  (implementation), operator (import + verifies).
- **Revisit when:** The key threshold eats a pale prop, the drift reads
  seasick, or the font lands.
- **Evidence / handoff:** `menu_paper_key.gdshader`, `menu_blur.gdshader`,
  `MenuPaperLayer.gd`, Main.tscn TitleCard/ResultCard wiring. NOTE: new
  textures need one editor focus or export run to import before headless
  gates load the scene.

## 2026-07-25 — Endgame lane split: Codex returns as tooling and lane C

- **Decision:** For the final stretch, code lanes A and B are consolidated
  under Claude and its engineer subagent (all gameplay/scene/audio-wiring
  edits, carrying the verify-gate and expectation-edit context). Codex,
  back online early, takes (1) shell tooling/pipeline jobs — rembg menu-art
  cleanup and ffmpeg audio clip extraction, both delivered — and (2)
  lane C validation: real-Chrome end-to-end playtests of the exported
  build (Claude's browser pane throttles frames between interactions, so
  Codex's live Chrome is the only full-session watcher) and itch page
  asset prep (cover/banner crops from IMG_7110). Codex does not edit
  gameplay files or commit; findings route through the director.
- **Why:** Hours from submission, split by tool strengths: Codex has the
  shell and a real browser; Claude's side holds the verify-suite context.
  Collision risk drops to zero by construction.
- **Rejected / cut:** Returning Codex to code lanes mid-stretch (would
  re-learn the gate discipline the expensive way).
- **Owner:** Noah (director), Claude (code lanes), Codex (tooling +
  lane C).
- **Revisit when:** The jam ends, or a Codex finding needs a code fix
  (routes to Claude's engineer as usual).
- **Evidence / handoff:** Codex reports in the director's session; the
  cleaned art in `art/menu/keyed/` and clips in
  `audio/family/toys/clips/`.

## 2026-07-25 — Menu masks via Photoshop; Cabin Sketch replaces Schoolbell

- **Decision:** The four snack/crayon prop images are masked by Photoshop
  Select Subject, driven by Codex over computer use — the fourth and final
  masking approach after the runtime shader key, the GDScript baker, and
  rembg all failed on them. Second Codex pass delivered tight content
  crops (goldfish 577×497, gummies 636×533, animal crackers 803×552,
  crayons 1143×617, each with a 14 px transparent margin) overwriting
  `art/menu/keyed/`. The three construction-paper sheets keep the
  GDScript-baker output, which worked for them. UI font: the Schoolbell
  download failed twice, so Codex substituted Cabin Sketch (OFL,
  sketchier crayon look) — `fonts/CabinSketch-Regular.ttf` +
  `CabinSketch-OFL.txt`. Wired as a shared `Theme` (default size 20) on
  TitleCard, ResultCard, ControlsHint, and InteractHUD; the
  NightstandClock keeps its blocky digits deliberately (it is a digital
  clock). The OFL file ships beside the font and the itch page must carry
  the credit line.
- **Why:** Colorful edge junk defeats luminance/saturation keying;
  Photoshop's subject model is the strongest mask on hand. Cabin Sketch
  arguably fits construction paper better than Schoolbell anyway.
- **Rejected / cut:** Runtime white-key shader on the props (dim iPhone
  whites), rembg output (director: "really bad"), retrying the Schoolbell
  download.
- **Owner:** Codex (masks, font fetch), Claude (wiring), Noah (F5
  verdict).
- **Revisit when:** F5 shows the font misreading at its per-card sizes, or
  the director wants the neater Schoolbell handwriting after all (one
  path swap in the Theme).
- **Evidence / handoff:** `art/menu/keyed/IMG_71{12,13,16,19}.png`,
  `fonts/CabinSketch-Regular.ttf`, Main.tscn `Theme_handwritten`
  sub-resource. New PNGs/TTF still need one editor focus before headless
  gates run.

## 2026-07-25 — Menu type spec, mask ownership, and cluster layout (UX audit)

- **Decision:** Per the art-ux-partner audit: (1) Photoshop Select Subject
  owns ALL seven menu masks — the three papers had surviving contact
  shadows/table margins from the luminance baker (which also skewed their
  crops so the stack never registered), and the crackers + crayons files
  on disk turned out fully unmasked; all five go back through the Codex
  Photoshop pass (uniform tight crop, consistent paper scale, 1–2 px
  defringe). The baker's `SOURCES` list is emptied so a stray re-run
  can't overwrite masks. (2) Cabin Sketch reads ~15–20% small: floor
  19 px, sizes lifted across the board (Theme default 22; Eyebrow 22 with
  brighter slate; Title 52 + soft shadow; Objective 24; Controls 22;
  StartPrompt 28 + shadow; ResultHeading 48; ResultDetail 23;
  RestartPrompt 26; in-play ControlsHint 20 with alpha .85 + shadow). On
  photographed paper use soft shadows, never outlines (outlines clog the
  double-stroke hatching). (3) The in-world InteractHUD prompt stays
  neutral sans (ThemeDB fallback) for glanceability — deliberate, not a
  wiring gap. (4) Clusters were part-offscreen at 1280×720: goldfish
  (1230,170)→(890,110), gummies (1080,620)→(860,480), crackers
  (310,500)→(150,430); paper stack offsets now reveal black+red on more
  edges (black −6,−26 / red 14,−12 / blue −10,8). Crayons stay at
  (250,130); labels draw above clusters by canvas order, so the title
  reads over them.
- **Why:** Director: "weird masking on the construction paper" + "font
  size doesn't look right." Audit confirmed both and found the two
  unmasked props.
- **Rejected / cut:** Retuning the space-aligned Controls columns (the a6
  gate asserts that label's text; zigzag accepted for the jam), outlines
  on paper text, re-parameterising the baker (can't despill and risks
  the red paper's scribbles).
- **Owner:** Noah (director), Claude (scene edits), Codex (five re-masks).
- **Revisit when:** F5 after the re-masks; or the heading overflows on a
  longer runtime result string.
- **Evidence / handoff:** Audit report in the director's session;
  Main.tscn GameFlow block; `process_menu_art.gd` retired header.

## 2026-07-25 — Pantry readability: visual-only shelf dressing

- **Decision:** The pantry gets an identity the way the fridge got its
  handle: a shelf unit with snack bags inside the alcove, visible when
  the door swings. Implementation rule: pantry dressing is PURELY visual
  — group-less MeshInstance3D/Node3D, BoxMesh only, zero colliders — so
  the navmesh bake (nav_source group; pinned 164 polygons) and every
  mesh-sweep gate stay untouched. Exactly one saturated item: an orange
  bag matching SnackMaterial (0.95, 0.6, 0.27), non-emissive so the real
  pickup glow still wins; boards/uprights/other bags in the warm neutral
  palette. Door-clearance rule recorded in the helper: keep pantry props
  ≥3.6 m from the hinge at (11.325, 2.2) (panel sweep 3.56 m).
- **Why:** Playtesters could read the fridge but not the pantry; bags on
  a shelf are the cheapest possible "this is where food lives" signal,
  and the orange bag doubles as a snack-color teach.
- **Rejected / cut:** Broader kitchen-primitive remodel (submission is
  tomorrow); colliders on the shelf (navmesh pin); any cylinder shapes
  (disc-absence sweeps).
- **Owner:** Claude engineer (build), Noah (eyeball).
- **Revisit when:** The door clips the shelf in play, or the shelf pokes
  through the south wall from the play camera.
- **Evidence / handoff:** `LevelBuilder.gd` `_add_pantry_shelf()` (called
  from `_build_props()`), nodes prefixed `PantryShelf*` under
  `PantryShelfUnit` at (13.1, 0, 6.09).

## 2026-07-25 — Release look locked; debug keys gated (pre-submission gate)

- **Decision:** The steady storybook halftone (retro_dither style 2, the
  director's twice-stated favourite) ships as the DEFAULT look:
  RetroFilter visible at load, `shader_parameter/style = 2` on the scene
  material, DebugTools `_retro_style` initialised to 2. Both loose keys
  are now debug-only via a single `OS.is_debug_build()` gate at the top
  of `_unhandled_input`: G (style cycler — editor tuning only now) and B
  (collision inspector — reveals hidden traps, must never ship). The
  redundant mid-function debug check was removed. Headless verifies run
  in debug builds, so any gate exercising these keys still passes;
  release web exports exclude both.
- **Why:** Two logged pre-submission gates resolved with the director's
  known preference (repeated-favourite rule); captures for the itch page
  need the shipped look on by default and must never show wireframes.
- **Rejected / cut:** Leaving G player-facing in release (accidental
  presses land on hatch/VHS and misrepresent the game); shipping filter
  off (halftone IS the game's look).
- **Owner:** Claude (implementation), Noah (veto on next F5 if the
  default look reads wrong in motion).
- **Revisit when:** F5/battery flags a gate asserting the filter hidden
  (flip that expectation, B19 precedent), or the director vetoes.
- **Evidence / handoff:** Main.tscn RetroFilter/ShaderMaterial_dither,
  DebugTools.gd `_unhandled_input` gate.

## 2026-07-25 — Itch page system (research + design pass)

- **Decision:** Page adopts the title-card system. Theme colors (sampled
  from the actual paper photos): page background `#6268B0`, content
  column `#F2EFE9`, text `#221F1C`, links `#B8334A`, button `#F29945`
  with DARK text (white fails contrast). Rules: sampled paper colours
  darken one step when used as small text; orange appears exactly once
  per surface (snack in game, play button on page). Banner ships only as
  a ~1920×560 top-strip crop (full 1080 pushes the embed below the
  fold); cover ships as an ANIMATED title-card loop at 630×500 (current
  cover.png reads as a blank blue rectangle at thumbnail size; fallback
  = title stamped on the photo). Capture rules: everything captured at
  the shipped default look, never with debug overlays. Asset priority:
  cover GIF → beats 3 ("countdown walks") and 4 ("busted") as body GIFs
  → sidebar PNGs → banner crop last. Jam-rule compliance: GMTK 2026 bans
  generative-AI art/audio for game AND page (we are clean — original
  photography/foley, OFL font, CC0 packs); external audio MUST be
  credited on the page — the CC0 source list does not exist yet and
  Codex is reconstructing it (it fetched the packs). Deadline: 2026-07-26
  17:00 BST (noon ET).
- **Why:** Research across 8 GMTK winner/top pages: animated cover is
  the top-leverage asset, twist-first copy and explicit theme naming are
  universal, custom theming is not where winners spend effort (ours is
  cheap so we apply it), and the AI/credit rules are
  disqualification-level.
- **Rejected / cut:** Full-height banner header; static cover as-is;
  custom background images; emoji-heavy copy.
- **Owner:** Noah (form + captures), Codex (GIF pipeline, crops, CC0
  list), Claude (copy, merge).
- **Revisit when:** The cover GIF exceeds ~3 MB (trim the loop), or the
  CC0 list can't be reconstructed (then swap those pools to family
  recordings before submission).
- **Evidence / handoff:** Research + design agent reports in the
  director's session; final page copy in the director's chat.

## 2026-07-25 — The 31 "extracted clips" never existed; pools parked

- **Decision:** `audio/family/toys/clips/` does not exist and never did —
  Codex searched the repo, git history, /tmp, Documents, and its
  worktrees and found no `toy_squeak_*.ogg` or `dog_*.ogg` anywhere. The
  earlier "31 clips extracted" report was wrong. This is the root cause
  of the scene refusing to load: `AudioCasting.gd` preloaded 31
  non-existent files, which is a compile error, which takes down every
  script that touches the casting table. Both pools are PARKED on their
  placeholder streams (single-entry `streams` + same fallback) with
  restore instructions in-line; the rest of the wiring (pet_bark
  channel, toys footstep branch, both origin allowlists) stays, since it
  is correct and inert. Re-extraction runs from the raw recordings,
  which are safe at `gamejam/recordings/raw/` (Codex moved the 10 raw
  WAVs out of the project and deleted their failing .import sidecars —
  they are compressed WAVs Godot cannot import but ffmpeg reads fine).
- **Why:** Deadline is noon ET tomorrow; a bootable game beats missing
  audio, and the director cannot record capture footage until it loads.
- **Rejected / cut:** Diagnosing encoding formats (there was nothing to
  diagnose); reverting the whole audio pass (the wiring is sound).
- **Owner:** Claude (park + restore), Codex (re-extract with evidence),
  Noah (F5, capture).
- **Revisit when:** Codex delivers real files WITH a directory listing —
  then swap the two parked entries back to the real preloads using the
  actual filenames and count, not assumed ones.
- **Evidence / handoff:** `AudioCasting.gd` `toy_squeak` / `pet_bark`
  entries carry TEMP comments with restore instructions.
- **RESOLVED same evening:** Codex re-extracted from the raws and proved
  it with a real `ls -la`: 68 clips, all OGG Vorbis 44.1 kHz, durations
  0.206–2.424 s — but the split is **66 toy squeaks + only 2 dog takes**,
  not the fictional 24 + 7. Both pools now wired to the true filenames
  (`toy_squeak_01..66`, `dog_01..02`); pet_bark jitter raised 0.04 → 0.07
  because two takes alone read as a loop. Pruning = delete preload lines;
  no gate asserts either pool's size.
- **Naming caveat (director, same evening):** the `dog_*.ogg` takes are
  NOT a real dog — they are a toy that plays a dog sound. Filenames stay
  as-is (renaming on submission eve buys nothing), but the credits must
  not claim a real animal, and the takes are deliberately kept OUT of the
  `toy_squeak` pool despite literally being a toy: the player has to be
  able to tell "I stepped on something" from "the dog noticed me," and
  one sound cannot mean both in a stealth game.

## 2026-07-25 — LESSON: a binary-read error does not prove a file exists

- **Decision:** Never treat "cannot read binary file" from the Read tool
  as evidence that a file EXISTS. The tool rejects known-binary
  extensions (.ogg/.wav/.png) on extension alone, BEFORE checking
  existence, so a missing `foo.ogg` and a present `foo.ogg` return the
  identical error. Only text-extension paths return a true
  "File does not exist". To prove a binary asset exists from a
  no-shell instance: check for its sibling `.import` file (a real text
  file), look for it in the export/scan log, or have a shell-capable
  tool run `ls` and paste the listing.
- **Why:** This exact false test cost the project an evening on
  submission eve. Claude invented the test, wrote it into an engineer
  subagent's brief as gospit ("a binary/cannot-display error means the
  file EXISTS"), and the subagent dutifully applied it to 31 phantom
  files and reported all 31 present. Claude then repeated the same probe
  itself and drew the same wrong conclusion.
- **Rejected / cut:** Trusting any subagent's existence claim that rests
  on a probe method rather than a directory listing.
- **Owner:** Claude.
- **Revisit when:** Never — bake it into every future asset brief:
  demand the listing, not the claim.
- **Evidence / handoff:** The engineer's STEP 0 report vs Codex's
  filesystem search.

## 2026-07-25 — Family toy squeaks and dog barks wired as sanctioned pools

- **Decision:** The 31 Codex-extracted clips (all probed present on disk)
  become two A15-style pools in `AudioCasting.gd`: `toy_squeak` (24 takes,
  channel `player_footsteps`, jitter 0.05) replaces the placeholder squeak
  in `_play_player_footstep`'s toys branch, and `pet_bark` (7 takes, new
  `pet_bark` channel case in `_play_pool`, jitter 0.04) replaces the
  placeholder "seagull" in `_on_pet_bark_started` and the PetBark seed in
  `_wire_streams_and_tuning`. Both placeholders stay wired as pool
  fallbacks. Volumes ride the untouched existing exports
  (`toy_squeak_volume_db` -3, `pet_bark_volume_db` -3) — perceived level
  matched to the placeholders conservatively; the director tunes by ear.
  The clips directory is sanctioned in BOTH origin gates
  (`AudioDirector.verify_configuration` and the Main.gd a18 sweep) via the
  door_creak_ pattern: ban roots extended to `res://audio/family/` with a
  `res://audio/family/toys/clips/` carve-out, so the raw session WAVs
  beside the clips stay banned. Neither pool's size is asserted anywhere,
  so the director can prune takes by deleting preload lines without gate
  edits. Gameplay noise (Player toys 4.0 / creaky 3.2 floors, Pet bark
  emission) untouched.
- **Why:** Director casting call; the recorded family sounds are the
  game's identity layer and the bark placeholder read as a seagull.
- **Rejected / cut:** Dropping the placeholders from the pools (fallback
  keeps the every-pool pattern at zero cost); deleting the now-unused
  `TOY_SQUEAK_STREAM`/`PET_BARK_STREAM` consts (no shell in this instance
  to prove them unreferenced project-wide — shell-side cleanup candidate);
  the placeholder's ±8% jitter (real-take pools supply variety; lower
  jitter avoids pitch artifacts on voice-like recordings); any
  volume_offset_db trim (no ears here — flat match to the export is the
  conservative baseline).
- **Owner:** Noah (ear pass + pruning), Claude engineer (wiring),
  operator (import + battery).
- **Revisit when:** The ear pass finds levels hot/quiet (tune the two
  exports), a take lands badly (prune its preload line), or the chirp
  placeholder (`PET_CHIRP_STREAM`, deliberately untouched) wants the same
  treatment.
- **Evidence / handoff:** `AudioCasting.gd` toy_squeak/pet_bark pools;
  `AudioDirector.gd` toys branch, pet_bark channel, bark handler, PetBark
  seeding, verify_configuration allowlist; `Main.gd` a18 sweep allowlist.
  NOT imported yet: one editor focus is mandatory before any headless
  gate runs, else every verify fails at AudioCasting preload. Not
  committed; operator commits after the battery.

## 2026-07-25 — Teleported bodies must land outside aggregate prop colliders

- **Decision:** `Parent.crib_player_offset` moves from `(0.0, 0.65, 0.0)` to
  `(-1.55, 0.15, 0.0)`. Rule behind it: any code path that assigns
  `global_position` directly on the player (carry deposit, drop, respawn) must
  land the capsule OUTSIDE the A19 visual-bounds prop colliders, because there
  is no physics step to arbitrate the overlap — `move_and_slide` recovers along
  the SHORTEST penetration axis, and for a body sitting near the top of a waist
  height prop that axis is straight up. The deposit is therefore specified by
  four constraints, not by a look: 0.34 m (capsule radius) clear of the prop
  box, inside `Crib/WinArea`, inside `post_deposit_crib_safe_radius`, and clear
  of the neighbouring prop.
- **Why:** The director's "the kid can climb over the wall into the bathroom".
  The old offset dropped the player at the crib's exact centre, 0.68 m inside
  CribBlock's solid 1.1 m collider; recovery ejected it onto the crib roof, and
  the crib roof (1.1 m) is one 0.10 m step across a 0.215 m gap from the
  KidBathDivider wall top (1.2 m). Every wall in the house is 1.2 m, so one
  capture put the player on the whole wall network. Lane C had already met the
  same aggregate collider ("a centre teleport resolves outward") and worked
  around it in `qa_runner.gd` instead of routing it back to lane B — the
  workaround hid the production bug.
- **Rejected / cut:** The open-end offset `(0.0, 0.15, 1.95)` that A6 and lane C
  use as the canonical in-crib spot (1.95 m > the 1.75 m
  `post_deposit_crib_safe_radius`, so it would also force an AI-predicate change
  on freeze night — revisit post-submission if the west-rail read is wrong);
  hollowing the crib collider (it is `nav_source`, so it re-bakes the pinned
  164-polygon navmesh); tightening Player's floor snap (the player never
  climbed — it was placed).
- **Owner:** Noah (director), Claude engineer (fix)
- **Revisit when:** Post-submission, if the west-rail deposit reads worse than
  the open end; or if any new teleport target is added.
- **Evidence / handoff:** `game/scripts/Parent.gd` `_finish_carry` +
  `crib_player_offset`; CribBlock world box x -9.81..-7.59, y 0..1.1,
  z -6.15..-3.25 from `LevelBuilder._add_crib` +
  `_add_visual_bounds_box_collision`. Navmesh untouched (exported value only).

## 2026-07-25 — Doors block until the swung panel leaves a kid-wide gap

- **Decision:** Two separate mechanisms sit behind "kid or adult clipping
  through doors"; the director has now flagged this twice, so both get the
  shippable half of the fix and the structural half is booked as post-jam.
  (1) PLAYER — APPLIED. Door panels are collisionless by the 2026-07-23/A10
  rulings; gameplay collision is a stationary doorway slab switched off
  wholesale at `Door.blocker_disable_openness`, which was 0.35 — where the
  panel has swung only 31.5° and still covers 85% of the opening. Raised to
  **0.55**, the principled minimum: the clear gap a swung panel leaves is
  `width x (1 - cos(90 x openness))`, which first exceeds the 0.68 m player
  capsule diameter at openness 0.50 on the 2.30 m bedroom door, 0.44 on the
  2.95 m bathroom door and 0.40 on the 3.55 m pantry door. 0.55 clears the
  narrowest by 0.13 m. **HARD CEILING 0.70**, re-verified: two parent states
  stand and wait on `openness >= blocker_disable_openness` with NO timeout —
  `_update_post_deposit_room_enter` (commands only
  `post_deposit_room_entry_openness` = 0.70) and `_is_waiting_for_routine_door`
  (commands `bathroom_door_open_openness` = 0.85). Above 0.70 the capture
  epilogue soft-locks permanently.
  (2) PARENT — SCOPED MITIGATION APPLIED, STRUCTURAL FIX DEFERRED POST-JAM.
  `Parent` is a plain `Node3D` moved by direct `global_position` assignment, so
  it has no collision at all, and the navmesh has no door data (blockers are
  runtime children, never in `nav_source`). ROUTINE stages the doors it uses;
  INVESTIGATE, HUNT, FOUND and CARRY never did. `_update_carry` now calls
  `_open_bedroom_door_for_carry()`, which commands `open_to(1.0)` while the
  blocker is still live. CARRY is the only state where this is cheap and safe:
  `_on_noise_emitted` early-returns for the whole state so the creak cannot
  feed back into the parent's own suspicion, the kid is attached and
  input-locked, BedroomDoor provides no snack so no reveal can fire, and
  POST_DEPOSIT_CLOSE_BEHIND re-closes the door immediately after — the authored
  beat regardless. It is a mitigation, not a cure: the panel opens at 0.2/s, so
  a short carry can still reach the doorway before the panel is clear.
- **Why:** Standing rule — an issue flagged twice ships in the next deliverable
  with a risk note rather than sitting behind an approval gate. The parent
  walking through a shut door was visible on every catch after the first,
  because the epilogue closes that door itself.
- **DEFERRED POST-JAM (do not lose):** the parent still passes through closed
  doors in INVESTIGATE, HUNT and FOUND — most visibly when it hunts the player
  into the bathroom, whose door is shut for the first ~187 s of every run. The
  same rootless-body problem produces the dining-table sighting:
  `_move_directly_toward_player` clamps to `map_get_closest_point`, and the
  aggregate A19 table collider bakes a walkable nav island on its 1.06 m top
  that the clamp can snap onto. Real fixes are a collider on the parent or
  door-aware pathing; both land in the most gate-covered file in the project
  (B7/B8/B9/B13/B15/B18/B20/B21) and were explicitly held out of the jam build.
- **Rejected / cut:** Collision on the rotating panel (outlawed 2026-07-23 and
  A10 — it shoved the player); leading the panel's visual swing so it is open
  by 0.35 (creak is rate-driven, so a motionless door would keep creaking); a
  shrinking blocker (new geometry code, untestable from a no-shell instance);
  door opening in INVESTIGATE/HUNT/FOUND (those states DO hear the creak, so it
  would feed the parent its own noise and retarget the hunt).
- **Owner:** Noah (feel verdict on the longer door hold), lane B (parent) post-jam
- **Revisit when:** The extra door hold reads as annoying rather than weighty —
  it is one exported value; or post-jam for the structural parent work.
- **Evidence / handoff:** `Door.gd` `blocker_disable_openness`,
  `_disable_visual_collision`, `_spawn_blocker`, `_update_blocker_collision`;
  `Parent.gd` `_open_bedroom_door_for_carry`, `_move_along_path`,
  `_move_directly_toward_player`; `Main.tscn` Parent node type. Expectation
  edit: `Main.gd` a10 bathroom-door probe 0.4 -> 0.6. Navmesh untouched by both
  changes (no geometry, no `nav_source` member, no collider size changed) — 164
  polygons stand.

## 2026-07-25 — Director listening pass: dog routing reversed, gates reconciled

Supersedes the pool sizes and the dog casting in "Family toy squeaks and dog
barks wired as sanctioned pools" (same day, above). Everything else there stands.

- **Decision (dog routing, applied):** The two dog cues swap sources. The Pet's
  *notice* cue — `alert_started`, the 1 s ears-up freeze, no gameplay noise —
  now plays the family take `dog_02.ogg` instead of the cut `sfx/pet_chirp.ogg`
  (`AudioDirector.PET_CHIRP_STREAM` retargeted). The *bark* — `bark_started`,
  which emits the 5.0 house-alarm noise and fires `dog_attention` — goes back to
  `sfx/pet_bark.ogg`, via the `pet_bark` pool's existing fallback with `streams`
  emptied (the same empty-streams idiom the sting/hum pools use, so
  `_select_pool_stream` still returns a non-null stream).
- **Decision (dog level, applied):** `pet_chirp_volume_db` -7.0 -> **-3.0**
  (+4 dB), matching the bark. That export is the only lever that works here:
  the chirp channel is a direct `AudioStreamPlayer3D`, never routed through
  `_play_pool`, so a pool `volume_offset_db` is ignored — and the `pet_bark`
  channel case in `_play_pool` does not read `volume_offset_db` either. Neither
  dog export is asserted by any gate, and `Main.tscn`'s AudioDirector node
  carries no property overrides, so the script default is authoritative.
- **Decision (gate reconciliation, applied):** Two A17 expectations reconciled
  to the director's cuts. Carpet footstep minimum 8 -> 4 (carpet_05..08 cut),
  expressed as a per-pool minimum dictionary so wood stays pinned at 8.
  `parent_footstep` origin prefix `res://audio/denoised/foley/` ->
  `res://audio/cc0/footsteps/` ("use the same sounds as footsteps of the
  child"). A17's printed `footsteps=%d carpet/%d wood` self-corrects to 4/8.
- **Decision (silence over substitution, PARTIAL):** `wrapper_shush` removed —
  provably dead (its only reference was a step on the `wrapper_noise` event,
  which nothing plays; carried-snack foley runs straight from
  `_update_wrapper_audio`). The other four cut stand-ins are NOT removed; see
  the escalation below.
- **Why:** Director's full listening pass. His words on the dog: `dog_02.ogg`
  "should be the only dog noise except for the bark"; `pet_bark.ogg` "should be
  the sound when the dog is alerted".
- **AMBIGUITY FLAGGED, ONE LINE TO CORRECT:** the code's signal for "dog
  notices you" is literally named `alert_started`, so "the sound when the dog is
  alerted" reads word-for-word as the *notice* cue — the opposite of what
  shipped. The implemented mapping is the only one consistent with "the only dog
  noise except for the bark", so it is what is wired. If the director meant the
  literal reading, swap `PET_CHIRP_STREAM` and the `pet_bark` fallback.
- **Decision (door creak pitch, applied — was inert, now real):** The new
  `"base_pitch": 0.85` never reached the speaker: `_update_door_creak` called
  `_play_pool` (which applies base_pitch) and then unconditionally overwrote
  `_door_creak.pitch_scale = moving_door.get_creak_pitch_scale()` on the very
  next line, every frame. Fixed by latching the chosen pool's base_pitch into a
  new `_door_creak_base_pitch` at the moment playback starts, and multiplying it
  into that per-frame assignment. Latched rather than recomputed per frame on
  purpose: the pool is only re-picked when the player is stopped, so a door that
  speeds up mid-swing would otherwise jump 0.85 -> 1.0 underneath a still-playing
  slow take. Matching expectation edit in `begin_audio_verification`: both door
  pitch asserts become
  `pitch_scale == door.get_creak_pitch_scale() * slow_creak_base_pitch`, reading
  the multiplier from `CASTING.POOLS[&"door_creak_slow"]` so the assert checks
  the product rather than restating the runtime.
- **COMPOUNDING TO WATCH — the door already had this exact lever.**
  `Door.get_creak_pitch_scale()` lerps `creak_slow_pitch_scale` **0.85** to
  `creak_fast_pitch_scale` 1.15 by rate weight, so a genuinely eased-open door
  was already pitched to 0.85. The pool's 0.85 now multiplies on top: a slow
  open lands at **0.85 x 0.85 = 0.7225**, a 28% drop from nominal, and the deep
  end of "lower and longer". If that reads as too far, the one-value fix is the
  pool's `base_pitch`, and the simpler equivalent lever the director may have
  actually wanted is `Door.creak_slow_pitch_scale` on its own.
  `floor_creak_step`'s 0.65 base_pitch was never affected by any of this
  (nothing overwrites the footstep channel's pitch) and no gate pins it.
- **DEFERRED BY RULING — the four remaining cut stand-ins stay wired.**
  `sfx/snack_pickup.ogg`, `sfx/snack_drop.ogg`, `sfx/caught_sting.ogg` and
  `sfx/win_sting.ogg` are NOT removed. Ten assertions across four gates plus two
  crash traps plus an unproven silent-stub workaround is not a last-night trade
  for three minor SFX. Their premise is load-bearing, not cosmetic:
  `verify_configuration` asserts all **19** audio players hold a non-null
  stream, and those four files are the only stream five of those players ever
  get at wiring time. Removing them also falsifies five behavioural asserts that
  encode "this moment makes a sound" (`_caught_sting.playing`,
  `_snack_pickup.playing`, `_snack_drop.playing`, `_fridge_pop.playing`, and the
  A20 pickup-skin `_pool_contains_stream` pair), across four gates
  (`--verify-audio`, `--verify-a20`, `--verify-a7`, `--verify-a8`). Two further
  traps: cutting `caught_sting` from `EVENTS[&"catch"]` makes
  `catch_steps[1]` an out-of-range index (a runtime error, not an assert), and
  `_pool_contains_stream` returns TRUE for a null stream against a
  fallback-less pool (`null == null`), inverting A20's "not a scoop" assert.
- **Recommended mechanism if the director holds the line:** keep every pool key
  and every player wired, and point the four cut fallbacks at one silent stub —
  a hand-written `AudioStreamGenerator` `.tres` (two properties, no binary, no
  import step) which plays as real silence. That keeps all 19 streams non-null
  and all `.playing` asserts honest with zero expectation edits. Unproven from
  a no-shell instance: it needs one live run before it ships.
- **Owner:** Noah (director — the dog ambiguity and the silence call), Claude
  engineer (wiring + expectation edits), operator (import + battery).
- **Revisit when:** The director rules on the four remaining stand-ins, on the
  dog-cue ambiguity, or on the inert door creak pitch.
- **Evidence / handoff:** `game/scripts/AudioCasting.gd` `pet_bark` pool,
  `wrapper_shush` removal, `wrapper_noise` event;
  `game/scripts/AudioDirector.gd` `PET_CHIRP_STREAM`, `pet_chirp_volume_db`;
  `game/scripts/Main.gd` `_verify_a17_acceptance_fixes` footstep expectations.
  A18's `denoised_stream_count >= 60` recounted by hand at **66** after all
  cuts (was 70; -3 parent_footstep, -1 wrapper_shush). `POOLS.size() >= 30`
  holds at 40. No geometry touched — navmesh stands at 164.
