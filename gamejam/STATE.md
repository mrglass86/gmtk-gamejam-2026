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

- Godot version: 4.7.1-stable — A0 greybox and A1 LightSystem are in `game/`
  (Compatibility renderer). Input-map verification and headless LightSystem
  checks pass; the first director-layout screenshot is committed.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `527dba7` builds the greybox; `8eff7c4` adds analytic
  zone lights and the temporary brightness readout. CP1 awaits lane B's
  player-walk integration and the director's layout verdict.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Thursday: A2 NoiseSystem is next for lane A while lane B integrates player
  movement. Noah's next decision is the layout verdict from the A0 screenshot;
  gates remain in `gamejam/VALIDATION.md`.

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
