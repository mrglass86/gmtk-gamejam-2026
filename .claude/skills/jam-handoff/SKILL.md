---
name: jam-handoff
description: Create a concise, factual GMTK26 cross-tool handoff. Use when pausing a session or passing a task between Claude and Codex.
disable-model-invocation: true
---

# Jam Handoff

Read shared memory and inspect the current working state. Create a new dated
handoff in `gamejam/handoffs/` using its template. Keep it under 200 words and
include completed work, current state, decisions, one exact next action with an
acceptance test, risks, and changed files. Update `STATE.md` and `BACKLOG.md` if
the handoff reveals stale status or priorities. Report the handoff path.
