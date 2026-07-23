# Current State

Update this at the end of meaningful work. Keep it short: it is a dashboard, not
a journal.

## Now

- Jam: GMTK26 — theme: Countdown
- Direction: Shoulda Eaten Dinner (toddler stealth; the countdown is the
  parent's bedtime routine). Locked brief: `gamejam/brief/shoulda-eaten-dinner-brief.md`
- Current phase: build day 1 (Thursday) — systems complete
- Next playable checkpoint: CP4 — play B5's authoritative route, catch, and
  chase, with the pulled-forward audio pass audible in the same run.

## Working build

- Godot version: 4.7.1-stable — A0.2 through A6.1 plus A4.1/A5.1 and the CC0
  audio pass are in `game/` (Compatibility renderer). The approved director
  layout bakes a connected 156-polygon navmesh; input, lighting, noise,
  indicator, route, ambient-mask, countdown, game-flow, and audio checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `538d697` clears the stale Parent scene override so B5's
  15-row route is authoritative. `d34f4a8` adds the complete CC0 audio pass,
  credits, first-input Web gate, and `--verify-audio`. A5.1/B5, A6/A6.1,
  audio, clean startup, and release Web export pass. A real Web canvas click
  starts audio with zero console warnings/errors.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Friday/CP4 next: Noah plays the authoritative route, catch/chase, snack round
  trip, and first audio mix against S7/S9/S10.

## Known blockers or risks

- Audio is functionally complete but has not had a director listening pass;
  tune exported direct volumes only if a tell or masking bed is misleading.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Route timing remains unmeasured in play; tune furniture/entrances only if the
  quiet route misses the 1.4–1.6× target.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
