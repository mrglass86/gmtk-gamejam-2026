# GMTK26 shared instructions

This is a Godot game-jam workspace shared by Claude and Codex.

## Shared memory

Before proposing a plan, changing code, or making a design decision, read:

1. `gamejam/STATE.md`
2. `gamejam/DECISIONS.md`
3. `gamejam/BACKLOG.md`
4. The most recent relevant entry in `gamejam/handoffs/`

These files are the cross-tool source of truth. Update them as part of meaningful
implementation or design work; do not rely on chat history as project memory.

## Role routing

Use the matching role card in `agents/` when a task needs specialist thinking:

- `design-brain.md` — theme interpretation and core-loop ideation.
- `scope-producer.md` — milestones, estimates, and cuts.
- `godot-engineer.md` — implementation and debugging.
- `art-ux-partner.md` — visual readability, feedback, and asset plans.
- `playtest-critic.md` — build evaluation and prioritized fixes.

For delegated work, give one role one bounded deliverable and include the current
shared-memory files. Reconcile conflicting suggestions in `gamejam/DECISIONS.md`
before implementation.

## Godot reference

- Target Godot **4.7.1-stable** unless the project records a different version.
- Use `docs/GODOT_REFERENCE.md` as the canonical documentation index.
- Prefer the official Godot 4.7 documentation and its matching source branch for
  API or engine-behavior questions. Do not assume Godot 4.8 development features
  are available.

## Jam defaults

- Optimize for a complete, immediately understandable game over feature count.
- Prefer a small vertical slice, placeholder-friendly assets, and Godot-native systems.
- Record irreversible scope or architecture decisions with their rationale and cuts.
