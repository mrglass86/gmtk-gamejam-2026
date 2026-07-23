# Handoff — 2026-07-23, planning kickoff (Claude, orchestrator session)

## What happened

- Direction locked: **Shoulda Eaten Dinner**, from the externally designed
  brief. Supersedes the three earlier theme-response candidates.
- Roles set: Claude plans and validates; Codex builds in two lanes (A systems,
  B actors); Noah owns editor, playtests, tuning.
- Brief reviewed as validator: 8 spec rulings logged (DECISIONS 2026-07-23 —
  phase 0..4, emissions ∝ rate, carry state, early win, ring radius formula,
  dynamic fridge light, Compatibility renderer + AreaLight3D web risk, minor
  defaults).
- Written this session: `gamejam/PLAN.md` (schedule, naming contract,
  trip-wires), `gamejam/VALIDATION.md` (gate checklists S1–S11),
  `gamejam/codex/lane-a-systems.md` + `lane-b-actors.md` (paste-ready Codex
  briefs), `gamejam/WIRING.md`, the `game/` scaffold (project.godot with input
  map, Main.tscn, three autoload stubs — GameClock near-complete), root
  `.gitignore`, `.claude/launch.json` (static server for web-build validation).
- STATE, DECISIONS, BACKLOG all updated.

## Revised same day — Noah directs, agents build everything

Noah has little Godot experience and takes the game-director seat: decisions,
checkpoint playtests, feel verdicts, paste-able commands only. All scene and
editor work moved to lane A (new package A0: greybox, camera, actor stubs,
navmesh). Agent-authored `.tscn` is sanctioned; MCP preference flipped to
`Coding-Solo/godot-mcp` first. See the DECISIONS division-of-labour entry and
PLAN sections 1, 1.1, 6.

## Next actions

Noah, in order — nothing here requires the Godot editor:
1. Copy the brief into the repo and make the first commit (commands below).
2. Tell Claude which Codex client is in use (CLI or IDE extension) — Claude
   hands back the exact MCP paste-lines for the 30-minute attempt.
3. Open both Codex sessions pointed at their lane files (lane A first — it is
   the critical path with A0).
4. Stay reachable for directorial pass 1: lane A posts a layout screenshot for
   a rooms-and-routes verdict before systems build on top of it.

Lane A: A0 greybox then A1 LightSystem. Lane B: B1 Player.gd. Claude: review
commits as they land; gate CP1.

Commands for step 1:

```bash
mkdir -p "/Users/noahhayes/Documents/GMTK GameJam 2026/gamejam/brief" && cp "/Users/noahhayes/Downloads/shoulda-eaten-dinner-brief.md" "/Users/noahhayes/Documents/GMTK GameJam 2026/gamejam/brief/shoulda-eaten-dinner-brief.md"
```

```bash
cd "/Users/noahhayes/Documents/GMTK GameJam 2026" && git init -b main && git add -A && git commit -m "Jam kickoff: brief, plan, lane briefs, Godot scaffold"
```

```bash
cd "/Users/noahhayes/Documents/GMTK GameJam 2026" && git remote add origin https://github.com/mrglass86/gmtk-gamejam-2026.git && git push -u origin main
```

## Open flags

- AreaLight3D on web/Compatibility unverified — Thursday export smoke test decides.
- Thursday exit criteria: build order 1–6 integrated, export proven, Parent started.
