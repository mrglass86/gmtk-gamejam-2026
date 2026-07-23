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

- Godot version: 4.7.1-stable — A0.2 through A4 are in `game/`
  (Compatibility renderer). The approved director layout bakes a connected
  155-polygon navmesh; input, lighting, noise, indicator, layout-route, and
  ambient-mask checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `50e550f` builds A0.2, `9d5fd6f` adds the locked visual
  front door, and `18dd081` implements A4. The refreshed labeled capture is
  ready; CP1/CP2 still require Noah's in-game walk and door-feel review.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Thursday: A5 GameClock and phase director are next for lane A. Before the
  next gate, Noah walks all four surfaces, compares a lamp pool with dining
  shadow, and reviews door feel; gates remain in `gamejam/VALIDATION.md`.

## Known blockers or risks

- AreaLight3D cannot cast shadows in the Compatibility renderer (risk check
  section 1) — lighting rig = area-light glow + shadowed spot/omni for the
  shadow language; Thursday's export proof confirms readability in browsers.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Route timing remains unmeasured in play; tune furniture/entrances only if the
  quiet route misses the 1.4–1.6× target.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
