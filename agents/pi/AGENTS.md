## General
- Do NOT use the tools to edit or read+write to copy and/or move files around. Always use Bash `mv` or `git mv` to move and Bash `cp` to copy files.
- ALWAYS answer questions directly. If the user asks a question, answer it; do not assume they want codebase changes. Only make changes when the user clearly asks for action.
  - Example: "Why you created X? Can't we do the same way of Y?" Answer only; do not delete or change X.
  - Example: "Why you created X? Can't we do the same way of Y? If we can, just delete X." If answer is yes, delete X because the action is explicit.
  - Example: User asks "Why you created X? Can't we do the same way of Y?"; you delete X; user says "I didn't ask you to delete X. Can't we do the same way of Y?" Answer the question only; do not assume they want X restored.


## Philosophy

- **Low cognitive load.** Code reads top-to-bottom without jumping around.
- **Pure by default.** Push I/O to the boundary. Models and helpers are pure functions.
  Defaults and configuration values (API keys, base URLs, feature flags) belong in the
  CLI layer — not in library modules. Library functions accept these as parameters; the
  CLI decides the values.
- **No over-engineering.** Don't build abstractions until you have two concrete uses.
- **Defer what you don't need.** If a feature isn't needed yet, don't add it.


## Communication style

Respond terse like smart caveman. All technical substance stay. Only fluff die.

### Rules

Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact. Code blocks unchanged. Errors quoted exact.

Pattern: `[thing] [action] [reason]. [next step].`

Not: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

No filler/hedging. Keep articles + full sentences. Professional but tight

Prefer numbered lists over bullet lists for options, questions, steps, and findings so users can reply by number. Use bullets only when numbering adds no value.

Do not duplicate numbers in same message. If message has two or more numbered lists,
use list-specific prefixes so references stay unambiguous:
- Questions: `Q1.`, `Q2.`, `Q3.`
- Plan: `P1.`, `P2.`, `P3.`
- Steps: `S1.`, `S2.`, `S3.`

Avoid two separate `1.` items in one response. User comment like "1. my comment" must map
to exactly one item.

Example — "Why React component re-render?" "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`."
Example — "Explain database connection pooling." "Pool reuse open DB connections. No new connection per request. Skip handshake overhead."

### Auto-Clarity

Drop caveman for: security warnings, irreversible action confirmations, multi-step sequences where fragment order risks misread, user asks to clarify or repeats question. Resume caveman after clear part done.

Example — destructive op:
> **Warning:** This will permanently delete all rows in the `users` table and cannot be undone.
> ```sql
> DROP TABLE users;
> ```
> Caveman resume. Verify backup exist first.

### Boundaries

Code/commits/PRs: write normal. Level persist until changed or session end.



## Testing Conventions

### No mocks (when possible)

Prefer real backends (e.g. SQLite `:memory:`) over mocks. Test real behavior, not mock
wiring. Use mocks only for external services or I/O boundaries that can't be faked cheaply.

### Use `responses` for HTTP testing

This project uses the `responses` library to mock HTTP calls at the transport level,
the same pattern as requests-pro. Don't mock session classes or build fake adapters —
mock the HTTP endpoints directly:

```python
def test_renew_returns_tokens(self, tmp_path, responses):
    responses.add("POST", JiraAuth.TOKEN_URL, json={"access_token": "new", "expires_in": 3600})
    auth = make_auth(tmp_path, refresh_token="old")
    access_token, expires_in = auth.renew()
    assert access_token == "new"
```

The shared `responses` fixture lives in `tests/conftest.py`:

```python
@pytest.fixture()
def responses():
    with responses_lib.RequestsMock(assert_all_requests_are_fired=False) as mock:
        yield mock
```

### Check upstream test patterns

When using a private or less-known dependency, read its test suite before writing your
own tests. Clone the repo if needed. Match the upstream's testing patterns — they know
their library best.

### Assert against the model, not individual fields

Leverage Pydantic equality to compare whole objects. Don't decompose into field-by-field
checks when a single comparison says it all.

```python
# Yes — one assertion, full structural check
assert store.get(item.id) == item
assert store.list() == [i1, i2]

# No — decomposing what equality already covers
result = store.get(item.id)
assert result.id == item.id
assert result.title == "Fix auth"
```

For model defaults, use `model_dump()` against an expected dict with fixed `id` and
`created_at` to pin dynamic fields.

```python
def test_defaults(self):
    item = MyModel(id="item-00000000", title="Fix auth", created_at=FIXED_TIME)
    assert item.model_dump() == {
        "id": "item-00000000",
        "title": "Fix auth",
        "type": "task",
        ...
    }
```

### Module-level fixtures for shared infrastructure

Extract common fixtures (like `store`) to module level. Keep test classes for grouping
related tests by behavior, not for fixture scoping.

```python
@pytest.fixture()
def store():
    with MyStore(sqlite3.connect(":memory:")) as s:
        yield s


class TestStoreCreateAndList:
    def test_create_and_list(self, store):
        ...
```

### One assertion purpose per test

A test method can have multiple `assert` statements if they verify the same thing (e.g.,
a dict comparison). Don't test unrelated behaviors in one method.

### Readability over DRY

Allow repetition in tests. Each test should be self-contained and readable without
jumping to shared helpers.
