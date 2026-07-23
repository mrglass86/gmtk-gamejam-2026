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

- Godot version: 4.7.1-stable — A0.2 through A7 plus A4.1/A5.1 and the CC0
  audio pass are in `game/` (Compatibility renderer). The approved director
  layout bakes a connected 156-polygon navmesh; input, lighting, noise,
  indicator, route, ambient-mask, countdown, game-flow, audio, and A7
  presentation checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `538d697` clears the stale Parent scene override so B5's
  15-row route is authoritative. `d34f4a8` adds the CC0 audio pass.
  `3def8f8` adds A7: 1920×1080 expand stretch, visible rate-driven fridge
  spill, TV flicker, rate-driven creak, actual dog cues, and snack pickup/drop
  feedback plus reveal clearance. `acaed9d` adds B6's live-clock actor fixes:
  the parent reaches the kitchen, the dog sleeps 30 s then patrols, and
  point-blank sight accelerates suspicion. A5.1/B5, B6, A6/A6.1, audio, A7,
  clean startup, and release Web export pass. A real Web canvas click starts
  audio with zero console warnings/errors; renderer captures prove the snack
  and fridge spill.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Friday/CP4 next: Noah plays the authoritative route, catch/chase, snack round
  trip, and A7 listening/readability pass against S7/S9/S10.

## Known blockers or risks

- A7 is functionally and renderer verified but awaits the director's listening
  pass; tune exported direct volumes only if a tell or masking bed misleads.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Route timing remains unmeasured in play; tune furniture/entrances only if the
  quiet route misses the 1.4–1.6× target.
- The dog's exported bed-egress point works in the live verifier; CP5 still
  needs a visual verdict that the rise-off-bed motion reads naturally.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
