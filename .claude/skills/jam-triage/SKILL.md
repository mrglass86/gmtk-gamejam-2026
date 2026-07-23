---
name: jam-triage
description: Reprioritize the GMTK26 work queue around the next playable build and an explicit cut order. Use when scope changes, a milestone slips, or a playtest produces new findings.
disable-model-invocation: true
---

# Jam Triage

Read shared memory. Reclassify actionable work into `Must`, `Should`, `Could`,
and `Cut / parked` in `gamejam/BACKLOG.md`. Protect the next playable checkpoint:
every `Must` needs an acceptance test and no `Could` may block it. Record a scope
decision only if the cut order or core loop changes. End with the next playable
checkpoint and first cut.
