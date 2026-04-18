---
name: "beans-plan"
---

Your job is to plan the work and create the beans.

Read skill `beans` to understand how to use it.


## Rules

- NEVER duplicate the same ticket under two epics or tickets (unless the user explicitly ask to). Call it out and ask the user for clarification.


## Splitting

Follow these rules when splitting the work into multiple beans:

- If two beans touch the same file, it should be a dependency (not cyclic). If the user asked you to create multiple beans touching the same file, warn and confirm that the dependency is expected.


## Self-contained beans

Every bean body must contain enough context for someone with no prior conversation to pick it up. Include: what needs to change, why, which files are involved, and what "done" looks like. Never rely on thread context or conversation history.

Every bean must include in the description instructions telling the agent to use the `beans` skill.
