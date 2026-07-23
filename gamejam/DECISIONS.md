# Decision Log

Record decisions another session or tool would otherwise have to rediscover.

## Template

```md
## YYYY-MM-DD — Decision title

- **Decision:**
- **Why:**
- **Rejected / cut:**
- **Owner:**
- **Revisit when:**
- **Evidence / handoff:**
```

## 2026-07-22 — Shared memory convention

- **Decision:** `gamejam/` is the cross-tool project memory; `STATE.md` is the
  short dashboard, `DECISIONS.md` is durable rationale, `BACKLOG.md` is the
  prioritized work queue, and `handoffs/` holds session-level context.
- **Why:** Claude and Codex should consult the same file-based source of truth.
- **Rejected / cut:** Relying on either tool’s chat history as project memory.
- **Owner:** Whole team
- **Revisit when:** The project needs a detailed bug tracker.
- **Evidence / handoff:** Initial workspace setup

## 2026-07-23 — Direction: Shoulda Eaten Dinner

- **Decision:** Adopt the externally designed brief (toddler stealth; the
  countdown is the parent's bedtime routine; the house gets darker-but-safer and
  quieter-but-riskier as it drains). Canonical copy at
  `gamejam/brief/shoulda-eaten-dinner-brief.md`. Its locked sections are design
  law; the planner owns scheduling, lane splits, and cut timing only.
- **Why:** Full design phase already done in a separate session; the brief is
  internally consistent, jam-scoped, and has a pre-agreed cut order.
- **Rejected / cut:** The three earlier theme-response candidates (Bank the
  Clock, Fuse Line, Descending Order).
- **Owner:** Noah (design lock), Claude (plan)
- **Revisit when:** Never during the jam — the cut order resolves conflicts.
- **Evidence / handoff:** `gamejam/handoffs/2026-07-23-plan-kickoff.md`

## 2026-07-23 — Roles: Claude plans and validates, Codex builds

- **Decision:** Two Codex lanes per brief 9.3 — lane A systems (only MCP
  connection), lane B actors (files only, never edits scenes). Noah does editor
  work, playtests, and all tuning calls. Claude writes work packages, reviews
  every commit, runs integration gates against `gamejam/VALIDATION.md` via the
  web build in its browser pane, keeps shared memory, and enforces cut
  trip-wires (`gamejam/PLAN.md` section 4).
- **Why:** Matches the brief's two-agent split, Noah's voice-first
  review-and-decide workflow, and this Claude instance's constraints (no shell;
  file tools plus browser-pane verification).
- **Rejected / cut:** Claude on editor MCP (a second driver on one live editor
  corrupts scene state); Claude as a coding lane.
- **Owner:** Whole team
- **Revisit when:** A lane sits idle waiting on reviews.
- **Evidence / handoff:** `gamejam/PLAN.md`, `gamejam/codex/lane-a-systems.md`, `gamejam/codex/lane-b-actors.md`

## 2026-07-23 — Spec rulings (planner notes against the locked brief)

- **Decision:**
  1. `GameClock.phase` is 0..4 (interface said 0..3; the section 4 table has
     four transitions). Phase 0 = start; transitions at 240/180/120/60 s
     remaining; timings `@export`-tunable. Phase state applied as a pure
     function of phase so scrubbing stays consistent.
  2. All door emissions ∝ rate of openness change (the bold rule in section 5
     wins over the fridge table row); a paused door emits and spills nothing.
  3. Caught → carry: parent navigates to the crib, player attached and input
     locked, snack drops at the catch point, suspicion resets to 0, routine
     resumes at the current clock time.
  4. Entering the crib holding the snack wins immediately (no dead idle time).
  5. Ring audibility radius = post-mask loudness × 8 m (the parent's hearing
     radius), capped at 20 m.
  6. Additive LightSystem helper for the fridge spill:
     `register_dynamic_light(id, pos)` / `set_dynamic_light(id, radius, energy)`.
  7. Renderer: Compatibility (web-safe). AreaLight3D-on-web is unverified —
     Thursday's export smoke test proves it or invokes the omni-cluster
     fallback (visual only; brightness is analytic either way).
  8. Pet is a dog; snack auto-acquired at openness ≥ 0.6; footsteps emit
     post-mask.
- **Why:** Each closes a gap or internal contradiction the brief left; none
  reopens a locked design call. Brief section 3 requires interface changes be
  noted in the repo — this is that note.
- **Rejected / cut:** Openness-scaled fridge emissions (kills crack-and-wait);
  contextual ring gating (brief forbids it); Forward+ web export (WebGPU is
  judge-hostile).
- **Owner:** Claude
- **Revisit when:** A ruling contradicts observed play — tuning numbers are
  free to move without a new entry.
- **Evidence / handoff:** Stubs in `game/autoload/`, lane briefs in `gamejam/codex/`

## 2026-07-23 — Schedule and cut trip-wires

- **Decision:** Thursday = systems (build order 1–6) plus the throwaway web
  export check; Friday = actors and full loop, freezing 19:00 with tag
  `jam-friday` and an itch draft upload; Saturday = audio (2 h cap), one
  outside playtest, tuning, optional dithering only if green by 15:00,
  submission page. Trip-wire table in `gamejam/PLAN.md` section 4 binds each
  cut to a clock time — invoke by lookup, no renegotiation.
- **Why:** The brief mandates a banked Friday build; pre-agreed trip-wires are
  the rested-brain version of 1 a.m. triage.
- **Rejected / cut:** Negotiating cuts at the moment of crisis.
- **Owner:** Claude (enforcement), Noah (override)
- **Revisit when:** A trip-wire fires early or the Thursday exit criteria slip.
- **Evidence / handoff:** `gamejam/PLAN.md` sections 3–4

## 2026-07-23 — Division of labour revised: Noah directs, agents build everything

- **Decision:** Noah is the game director: decisions, checkpoint playtests,
  feel verdicts, cut approvals, paste-able commands only — no editor
  construction, ever. All scene and editor work moves to Codex lane A as
  package A0 (greybox level, camera, actor stubs, navmesh, hazard placement as
  directed). Agent-authored `.tscn` files are sanctioned. MCP preference flips
  to `Coding-Solo/godot-mcp` first (npx only, no editor-plugin install —
  lowest setup burden), 30-minute abort unchanged. Claude may use computer
  control for GUI-only dialogs (export templates, itch upload walkthrough) and
  window screenshots; it stays off editor MCP and does not construct via GUI.
- **Why:** Noah has little Godot experience and wants the director seat. Brief
  9.3's "layout stays yours" and its hand-edited-scene caution were premised on
  a hands-on operator; with agents building, direct `.tscn` authoring of
  primitive greybox scenes is the practical path. The locked layout content in
  brief section 7 still governs what gets built — only the hands changed.
- **Rejected / cut:** Teaching the editor mid-jam; Claude driving the editor
  GUI as a construction path (slow and error-prone next to text authoring and
  MCP).
- **Owner:** Noah (mandate), Claude (plan)
- **Revisit when:** Agent-authored scenes start corrupting or MCP instability
  costs a block.
- **Evidence / handoff:** `gamejam/PLAN.md` sections 1, 1.1, 6; lane briefs
