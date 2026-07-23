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

- Godot version: 4.7.1-stable — project scaffolded at `game/` (Compatibility
  renderer, autoload stubs, input map). Greybox pending (lane A, package A0).
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: opens empty; no gameplay yet; not yet committed to git.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 (created empty — first push pending).

## Current focus

- Thursday: build order steps 1–6 plus the web export smoke test. Noah directs
  (decisions and checkpoint play only — agents build everything, including
  scenes). Lane briefs ready in `gamejam/codex/`; gates in `gamejam/VALIDATION.md`.

## Known blockers or risks

- AreaLight3D on the web/Compatibility renderer is unverified (4.7 feature) —
  Thursday's export test proves it or triggers the omni-cluster fallback.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Agent-authored greybox is the new critical path — the A0 layout screenshot
  gate (directorial pass 1) is the safeguard.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
