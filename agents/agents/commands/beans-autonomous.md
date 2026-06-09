---
name: "beans-autonomous"
skill: beans
thinking: high
---

## Beans Autonomous mode

When running autonomously, loop through ready beans:

```
beans ready → pick highest priority → beans claim → read bean →
implement using TDD red/green loop → test → commit behavior →
refactor while green → test → commit refactor → beans close → next bean
```

(Read the skill `tdd`, including `refactoring.md`.)

For each bean:

1. RED: write one behavior test against public interface. Confirm it fails.
2. GREEN: write minimal implementation until test passes.
3. Repeat red/green one behavior at a time. Do not write all tests first.
4. TEST: run relevant tests. If green, commit behavior change.
5. REFACTOR: after behavior commit, improve code shape without changing behavior. Check refactor candidates: duplication, long methods, shallow modules, feature envy, primitive obsession, and existing code new work reveals as problematic. Keep tests on public interface.
6. TEST: run tests after each refactor step. Never refactor while RED.
7. COMMIT: commit refactor separately if refactor changed code.

When autonomous loop ends, leave instructions of what was implemented and for how user can manually test it.

---

$@
