# Current State

Update this at the end of meaningful work. Keep it short: it is a dashboard, not
a journal.

## Now

- Jam: GMTK26 — theme: Countdown
- Direction: Shoulda Eaten Dinner (toddler stealth; the countdown is the
  parent's bedtime routine). Locked brief: `gamejam/brief/shoulda-eaten-dinner-brief.md`
- Current phase: build day 1 (Thursday) — systems
- Next playable checkpoint: CP3 — complete the S11 Chrome console check, then
  scrub/replay the phase sequence from the A6 title card.

## Working build

- Godot version: 4.7.1-stable — A0.2 through A6 plus A4.1/A5.1 are in `game/`
  (Compatibility renderer). The approved director layout bakes a connected
  156-polygon navmesh; input, lighting, noise, indicator, route, ambient-mask,
  first/second-walk, countdown-phase, and game-flow checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `d3a9d5d` adds title/controls, the first-input clock/audio
  gate, crib win/expiry loss, and R-to-reload. A1–A6 plus a 600-frame run pass.
  The unchanged single-threaded Web preset exports cleanly and loads the title
  in Safari; Chrome console/start validation remains for S11.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Thursday: finish the S11 Chrome console/start check, then CP3 replay. Noah
  verifies the A4.1 fixes and scrubs all four phases with `]`; gates remain in
  `gamejam/VALIDATION.md`.

## Known blockers or risks

- AreaLight3D cannot cast shadows in the Compatibility renderer (risk check
  section 1) — lighting rig = area-light glow + shadowed spot/omni for the
  shadow language; Safari renders the exported rig, but Chrome is not running
  and needs director permission before the browser-control check can launch it.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Route timing remains unmeasured in play; tune furniture/entrances only if the
  quiet route misses the 1.4–1.6× target.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
