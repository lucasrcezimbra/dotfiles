---
name: "beans-plan"
skill: beans
---

Your job is to plan the work using TDD and create the beans.

Before creating any beans, read the `tdd` skill and apply its guidance to the plan.


## Rules

- The plan must use TDD. Structure beans so work follows red-green-refactor: write failing tests first, implement only enough code to pass, then refactor.
- Always write bean titles and descriptions in English, even when the user request is in another language.
- When creating multiple epics, don't duplicate the same bean under two epics or beans (unless the user explicitly ask to). Call it out and ask the user for clarification.


## Splitting

Follow these rules when splitting the work into multiple beans:

- If two beans touch the same file, it should be a dependency (not cyclic). If the user asked you to create multiple beans touching the same file, warn and confirm that the dependency is expected.


## Self-contained beans

Every bean body must contain enough context for someone with no prior conversation to pick it up. Include: what needs to change, why, which files are involved, and what "done" looks like. Never rely on thread context or conversation history.

Every bean must include in the description instructions telling the agent to use the `beans` and `tdd` skills.

Do not copy detailed instructions from skills into bean bodies. If domain guidance is needed (for example Django rules), tell the agent to read and use the relevant skill instead. The agent implementing the bean has access to the same skills.

---

$@
