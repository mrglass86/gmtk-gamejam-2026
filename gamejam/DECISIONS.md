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
