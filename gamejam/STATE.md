# Current State

Update this at the end of meaningful work. Keep it short: it is a dashboard, not
a journal.

## Now

- Jam: GMTK26 — theme: Countdown
- Direction: Shoulda Eaten Dinner (toddler stealth; the countdown is the
  parent's bedtime routine). Locked brief: `gamejam/brief/shoulda-eaten-dinner-brief.md`
- Current phase: build day 1 (Thursday) — systems complete
- Next playable checkpoint: CP4 — integrate B5's authoritative routine, then
  play the catch and chase.

## Working build

- Godot version: 4.7.1-stable — A0.2 through A6.1 plus A4.1/A5.1 are in `game/`
  (Compatibility renderer). The approved director layout bakes a connected
  156-polygon navmesh; input, lighting, noise, indicator, route, ambient-mask,
  first/second-walk, countdown-phase, and game-flow checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `e26ce9c`/`0223b1b` fix A6.1 camera framing, remove the
  warning-producing placeholder audio, hide the brightness label in release,
  and formally verify immediate/expiry win, expiry loss, and real scene reload.
  A1–A6 plus a 600-frame run pass. S11 is accepted from the director's live
  Chrome proof: zero console errors, title/input, glow, and shadows all green.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Friday/CP4 next: remove the stale `Main.tscn` Parent routine override so B5's
  script table is authoritative, then play the catch/chase against S7 and S10.

## Known blockers or risks

- Audio is intentionally absent until Saturday's capped pass; the first
  imported sound must start from GameFlow's first-input transition.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Route timing remains unmeasured in play; tune furniture/entrances only if the
  quiet route misses the 1.4–1.6× target.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
