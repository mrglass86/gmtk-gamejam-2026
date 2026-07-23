# Current State

Update this at the end of meaningful work. Keep it short: it is a dashboard, not
a journal.

## Now

- Jam: GMTK26 — theme: Countdown
- Direction: Shoulda Eaten Dinner (toddler stealth; the countdown is the
  parent's bedtime routine). Locked brief: `gamejam/brief/shoulda-eaten-dinner-brief.md`
- Current phase: build day 1 (Thursday) — systems
- Next playable checkpoint: CP1 — player walking the lit grey-box with the
  capsule brightness readout live (`gamejam/PLAN.md` section 3).

## Working build

- Godot version: 4.7.1-stable — A0.1, A1, A2, and A3 are in `game/`
  (Compatibility renderer). The navmesh now bakes once from static colliders;
  input, lighting, noise-bus, and indicator threshold checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `aa4fbf4` applies CP1 fixes; `e7c1f68` adds NoiseSystem and
  the fridge helper; `04c34a0` adds the indicators and teaching hazards. The
  revised layout capture is ready; CP1 requires Noah's in-game walk.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Thursday: A4 ambient masking is next for lane A. Before CP1, Noah walks all
  four surfaces and compares a lamp pool with dining shadow; gates remain in
  `gamejam/VALIDATION.md`.

## Known blockers or risks

- AreaLight3D cannot cast shadows in the Compatibility renderer (risk check
  section 1) — lighting rig = area-light glow + shadowed spot/omni for the
  shadow language; Thursday's export proof confirms readability in browsers.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Agent-authored greybox is the new critical path — the A0 layout screenshot
  gate (directorial pass 1) is the safeguard.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
