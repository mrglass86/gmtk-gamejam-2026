# Build plan — Shoulda Eaten Dinner (GMTK26)

Planner and validator: Claude. Builders: two Codex lanes — including all scene
and editor work. Director: Noah — decisions and player experience, no
construction. Source design: `gamejam/brief/shoulda-eaten-dinner-brief.md` —
its locked sections govern; this plan only schedules them.

Revised 2026-07-23: division of labour moved fully to agents (DECISIONS entry).

Today is Thursday 2026-07-23. Friday ends with a tagged, exported, playable web
build regardless of state. Saturday is feel, audio, and submission.

## 1. Roles

| Who | Owns |
|---|---|
| Noah — game director | Decisions and player-experience verdicts: approves the layout from screenshots, plays every checkpoint build, answers the directorial questions Claude poses, calls tuning ("too slow", "unfair"), approves cuts. Pastes terminal commands Claude supplies and operates the two Codex sessions. Never constructs anything in the editor. |
| Codex lane A — systems and scenes (the only MCP connection) | Everything scene-side: greybox level, camera, actor scene stubs, navmesh, hazard placement as directed — plus LightSystem, NoiseSystem, noise indicators, masking zones, GameClock + phase director + debug keys, win/lose/title, export presets. May author `.tscn` text directly (sanctioned) and via MCP. Brief: `gamejam/codex/lane-a-systems.md` |
| Codex lane B — actors (files only, never edits a .tscn) | Player.gd, Door.gd, Snack.gd, Parent.gd, Pet.gd, routine data rows. Wiring requests go to `gamejam/WIRING.md` for lane A. Brief: `gamejam/codex/lane-b-actors.md` |
| Claude — planner and validator | Translates the director's calls into work packages with acceptance tests, reviews every commit, runs integration gates (VALIDATION.md) by driving web builds in the browser pane, uses computer control for the few GUI-only dialogs and for window screenshots, keeps shared memory, enforces cut trip-wires, drafts submission copy |

## 1.1 How the director's seat works

- Noah never edits files. Claude turns every directorial call into agent tasks.
- At each checkpoint Noah plays the build for a couple of minutes and answers
  2–3 concrete questions posed with it (example: "watching the pink rings,
  could you tell which of your sounds the parent could hear?"). Plain-words
  verdicts are enough — Claude converts them into numbers and tasks.
- Layout, hazard placement, and tuning work the same way: lane A moves things,
  Noah says warmer or colder from play.
- Terminal steps arrive as single paste-able commands. Anything GUI-only is
  either walked through click by click or handled by Claude's computer control.

## 2. Naming contract — locked, all lanes must match

- Autoloads: `LightSystem`, `NoiseSystem`, `GameClock` at `res://autoload/`.
- Light zones: `bedroom`, `hall`, `living`, `kitchen`; dynamic light id `fridge`.
- Floor collider groups: `surface_carpet`, `surface_hardwood`, `surface_creaky`, `surface_toys`.
- Nodes under `Main`: `Level`, `Player`, `Parent`, `Pet`, `Crib`, `Fridge`, `Pantry`, `BedroomDoor`, `NightstandClock`.
- Input actions (already in project.godot): `move_left/right/forward/back`, `run`,
  `interact`, `restart`, `debug_skip`, `debug_rewind`, `debug_overlay`,
  `debug_teleport`, `debug_spawn_noise`.

## 3. Schedule

### Thursday — systems day (build order steps 1–6 plus the export smoke test)

| Block | Noah (director) | Lane A | Lane B |
|---|---|---|---|
| T1 setup | Paste: brief copy + git init; paste MCP setup for lane A (30-min hard abort); open both Codex sessions on their lane files | MCP sanity test if connected, else straight to A0 | Read brief, start B1 |
| T2 | Directorial pass 1 — from lane A's first screenshot: do the rooms and the two routes read; camera angle verdict | A0 greybox level, camera, actor stubs, navmesh, scaffold verification → A1 LightSystem | B1 Player.gd |
| CP1 | Play it: walk the lit greybox | Player moves, capsule readout live, walls block paths | |
| T3 | Directorial pass 2 — door feel: sneak-open trickle vs rush-open bang | A2 NoiseSystem → A3 indicators + teacher hazards | B2 Door.gd + Snack.gd |
| CP2 | Play it: make noise on every surface | Rings match the threshold table exactly | |
| T4 | Walk both routes in-build; timing verdicts | A4 masking → A5 clock, phase director, debug keys, nightstand clock | B3 Parent.gd started |
| CP3 | Play it: scrub phases with `]` | Phases re-price the world consistently; throwaway web export loads in a browser with one AreaLight3D and one shadow verified | |

Thursday exit criteria: steps 1–6 integrated, export proven, Parent in progress.

### Friday — actors and the full loop

| Block | Work |
|---|---|
| F1 | B3 Parent complete (suspicion, investigate, carry). CP4: full catch loop — dark-inside-cone is safe, carry resets and resumes at now. Noah plays the catch |
| F2 | B4 Pet; A6 win/lose/title/restart; snack + wrapper + return leg wired |
| CP5 | Winnable and losable end to end from the title card — Noah plays a full run |
| F3 | B5 routine rows (drink run promoted); route balance to 1.4–1.6x measured from Noah's runs, lane A adjusts; tuning pass 1 (Noah verdicts, lanes apply) |
| F4 19:00 | Freeze. Noah pastes the tag ritual (section 7), lane A exports, Claude validates the build, Noah uploads the itch draft with Claude's click-by-click walkthrough |

### Saturday — feel day

Audio (2-hour cap, CC0, Claude supplies the shortlist links, lane A wires — the
three load-bearing countdown sounds first), one outside playtester watched
silently, tuning from that, dithering only if everything is green by 15:00,
submission page (Claude drafts, Noah posts), final export and submit.

## 4. Cut trip-wires — invoke by lookup, no renegotiation

Cut order is brief 12.1. Dithering is already gated to Saturday (cut 1).

| Time | If | Then |
|---|---|---|
| Thu 21:00 | Steps 2–6 not integrated | No cuts; Friday reorders to finish systems before Parent |
| Fri 12:00 | Parent catch loop not stable | Cut 2 — pet |
| Fri 15:00 | Not winnable end to end | Cut 3 — ambient masking (TV stays as light + sound) |
| Fri 17:30 | Still not end to end | Cut 4 — second route (block the dining doorway) |
| Sat 12:00 | Round trip broken or unfun | Cut 5 — one-way to the pantry, retune clock to ~180 s |
| Sat 15:00 | Green and playtested | Dithering window opens; otherwise it never does |
| Sat 18:00 | Always | Content freeze, submission page hour |

Never cut: three movement speeds, brightness detection, noise → suspicion, the
clock, lights going out as it drains.

## 5. Validation loop mechanics

- Every Codex commit gets read by Claude in the same block, against VALIDATION.md
  and the guardrails (Godot 3 idioms, untyped GDScript, interface drift).
- Integration gates: web export (threads off) → static server via
  `.claude/launch.json` (`web-build`, port 8060) → Claude drives the build in the
  browser pane with keyboard input, screenshots, and console reads.
- Every gate ends with a directorial pass: Noah plays for two minutes against
  2–3 posed questions. His verdicts become the next block's tasks.
- Findings become BACKLOG.md items or an immediate bounce to the owning lane.
  Rulings go to DECISIONS.md. Nothing merges on a red gate.
- After every green gate: commit and push to the remote
  (https://github.com/mrglass86/gmtk-gamejam-2026) so progress is banked
  off-machine.

## 6. Tooling rules

- MCP, lane A only, 30-minute hard abort (brief 9.2): try
  `Coding-Solo/godot-mcp` first — npx only, no editor-plugin install, and the
  capability that matters most (run the project, read debug output) with the
  least setup. Step up to `mkdevkit/godot-mcp` later only if we want its
  screenshot/input bridges and have slack. Context7 into Codex regardless.
  Claude supplies the exact paste-lines once Noah confirms which Codex client
  he's running.
- Scene authoring: lane A owns the editor session and may write `.tscn` files
  directly — reliable for primitive greybox scenes and sanctioned now that no
  human is doing layout. Lane B still never touches scenes.
- If Noah opens the editor to peek, lane A pauses scene writes until he closes it.
- Claude's computer control is a fallback for GUI-only moments (export-template
  dialog, itch upload walkthrough, editor screenshots), not a construction path
  — text authoring and MCP are faster and safer. First use triggers a one-time
  macOS permission prompt for Noah to approve.
- Fallback if MCP aborts: lane A authors scenes as text and verifies with
  headless runs (`--headless`) via paste-able commands or its own shell.

## 7. Friday tag ritual

```bash
cd "/Users/noahhayes/Documents/GMTK GameJam 2026" && git add -A && git commit -m "Friday freeze" && git tag jam-friday && git push origin main --tags
```

Then lane A exports the web build and Noah uploads the zip to itch as a draft.

## 8. Watch-items — non-blocking, playtest-owned

- Red nightstand numerals share a hue with found-you red (locked by the brief;
  motion and size disambiguate — confirm in playtest).
- Catch pacing: +25/s seen and −8/s decay may be too forgiving.
- Pet alert radius 6 m and bark loudness 5.0 (ring caps at 20 m).
- Footstep cadence: start 0.35 s sneak / 0.25 s run, `@export`.
