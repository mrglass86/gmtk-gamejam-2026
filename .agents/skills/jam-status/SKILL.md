---
name: jam-status
description: Read and reconcile the GMTK26 shared project memory into a concise current-status report. Use when starting a session, resuming work, or asking what to do next.
disable-model-invocation: true
---

# Jam Status

Read `gamejam/STATE.md`, `gamejam/DECISIONS.md`, `gamejam/BACKLOG.md`, and the
latest relevant handoff. Reconcile contradictions in this order: latest explicit
decision, current state, backlog, then handoff.

Return only:

1. Current phase and playable checkpoint.
2. What is done and what is blocked.
3. The top three ordered tasks, each with its acceptance test.
4. The first feature to cut if time tightens.

Do not change project files unless asked to correct stale memory.
