---
name: one-pager
description: Create decision-oriented one-pagers that turn investigations, architecture recommendations, performance diagnoses, and handoffs into self-contained docs for fast decision or execution. Use when the user asks for a one pager, decision memo, recommendation write-up, diagnosis handoff, performance analysis, or asks to make a document actionable and self-contained.
---

# One Pager

A one pager is a **decision page**, not a summary. It gives the reader enough context, evidence, and direction to decide or execute without redoing the investigation.

Core standard: the reader should not need to decode loose prose, search code, reconstruct hypotheses, or guess the recommendation.

## Quick start

1. Identify expected action: decide, approve, implement, prioritize, or review.
2. Gather evidence: numbers, logs, queries, graphs, links, affected files, functions, lines, and snippets.
3. Write the template below; annexes only deepen, first page must decide.
4. Check that a future reader can resume work after context loss.

## Use when

Use for architecture recommendations, performance/operational diagnoses, non-trivial bug investigations, handoffs from analysis to implementation, durable technical decisions, and risky/costly changes. Skip small, obvious, reversible tasks.

## Template

````md
# [Direct title: e.g., Dedup runs too late in message ingestion]

## Action expected

[What the reader should decide, approve, implement, or review.]

## Executive summary

1. [Problem in one sentence.]
2. [Where it happens.]
3. [Practical impact.]
4. [Primary evidence.]
5. [Recommendation.]

## Hypothesis

[Initial suspicion that guided investigation.]

## Evidence

- [Metric, log, query, graph, dashboard, or source link.]
- [Another concrete evidence item.]

## Where it happens

| File | Function | Line(s) | Note |
| --- | --- | --- | --- |
| `[path/to/file]` | `[function]` | `[123-145]` | `[why this matters]` |

```[language]
# file: path/to/file
# PROBLEM: mark exact line/block and why it causes observed behavior.
problematic_code()
```

## Diagnosis

[Connect cause + evidence + impact. Prefer: “System does X after Y. This causes Z because W. Evidence: A, B, C.”]

## Recommendation

1. [Change 1: what and where.]
2. [Change 2: what to remove or keep.]
3. [Risk or alternative if relevant.]

## Acceptance criteria

1. [Functional validation.]
2. [Regression test or reproducible check.]
3. [Metric/log proving improvement.]

## References

- [Links to dashboards, logs, PRs, issues, transcripts, Looms, docs.]
````

## Quality checklist

1. Reader can decide or start implementation without asking follow-up questions.
2. Problem, evidence, recommendation, and acceptance criteria are explicit.
3. Code location includes file, function, line range, and snippet when code is involved.
4. Evidence supports the diagnosis; no “trust me” claims.
5. Annexes are optional, not required for basic understanding.
6. Document will still be useful after context loss.

## Communication principle

Use the rule: “My job is not to investigate. My job is to decide.” If asked to explain why one pagers matter, include that story: first page enables decision; deeper pages are only for validation.
