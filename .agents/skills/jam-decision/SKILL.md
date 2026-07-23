---
name: jam-decision
description: Record a durable GMTK26 game-design, scope, architecture, or production decision in shared memory. Use after the team chooses a direction or rejects an important alternative.
disable-model-invocation: true
---

# Jam Decision

Read shared memory. Use the arguments as decision context; when missing, infer
only from this conversation and ask for the decision if it cannot be inferred.

Append one completed entry using the template in `gamejam/DECISIONS.md`. Include
the decision, why it was chosen, rejected/cut alternatives, owner, revisit
trigger, and evidence. Update `STATE.md` and `BACKLOG.md` only when current
focus or priority changes. Report changed files.
