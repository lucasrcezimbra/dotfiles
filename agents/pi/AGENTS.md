## General
- Do NOT use the tools to edit or read+write to copy and/or move files around. Always use Bash `mv` or `git mv` to move and Bash `cp` to copy files.


## Philosophy

- **Low cognitive load.** Code reads top-to-bottom without jumping around.
- **Pure by default.** Push I/O to the boundary. Models and helpers are pure functions.
  Defaults and configuration values (API keys, base URLs, feature flags) belong in the
  CLI layer — not in library modules. Library functions accept these as parameters; the
  CLI decides the values.
- **No over-engineering.** Don't build abstractions until you have two concrete uses.
- **Defer what you don't need.** If a feature isn't needed yet, don't add it.


## Python

### Imports

#### Never re-export for backwards compatibility

When moving code to a new module, do not keep compatibility imports in the old module.
Update every caller to import from the new location instead. Re-exporting hides stale
boundaries, keeps dead paths alive, and makes future refactors harder.

```python
# Yes — callers import from the new home
from app.domain.items import Item

# No — old module re-exports the moved symbol
from app.domain.items import Item
```

### Code Style

#### No underscore prefixes

Don't use `_` to signal "private." In Python everything is accessible regardless, so
the prefix is noise that conveys nothing the code structure doesn't already show. A
function only called by one other function in the same module is obviously a helper —
you can see that from usage. If it's in the module, it's part of the module.

The real "private" boundary is what you choose to test, not a naming convention. Test
through the public-facing functions; helpers get coverage indirectly. If you refactor
a helper away, no tests break.

#### Functions over methods

If it doesn't need `self`, it's a standalone function, not a method. Compose small
functions rather than building class hierarchies.

```python
# Yes
def columns(cursor):
    return [desc[0] for desc in cursor.description]

def row(cols, values):
    return dict(zip(cols, values))

# No
class SomeStore:
    def _get_columns(self, cursor): ...
    def _row_to_dict(self, cols, values): ...
```

#### Inline trivial calls

Don't create helper functions that only call another function or method with the same
arguments. Call the underlying function inline instead. Helpers should add behavior,
not hide one obvious operation behind another name.

```python
# Yes
with self.connection.cursor() as cursor:
    cursor.execute(sql)
    row = cursor.fetchone()
self.connection.commit()

# No
def commit_read(connection) -> None:
    connection.commit()

with self.connection.cursor() as cursor:
    cursor.execute(sql)
    row = cursor.fetchone()
commit_read(self.connection)
```

#### Default arguments for configurability

Never reference module-level constants directly inside function bodies. Instead, pass
them as default arguments. This makes functions testable and reusable without adding
configuration infrastructure. For classes, use class attributes instead of reaching for
the global.

```python
# Yes — constant flows through the signature
def find_config_dir(start=None, dirname=CONFIG_DIR) -> Path: ...

# Yes — class owns its configuration
class SomeId(str):
    prefix = ID_PREFIX
    def __new__(cls, value="", **kwargs):
        if not value.startswith(cls.prefix): ...

# No — function reaches for the global directly
def find_config_dir(start=None) -> Path:
    candidate = current / CONFIG_DIR  # hidden dependency
```

#### `**kwargs` over dict for named fields

When a function accepts a set of named fields, use `**kwargs` instead of a dict parameter.
It reads better at the call site and lets the interpreter catch typos.

```python
# Yes
def update(self, item_id, **fields) -> int: ...
store.update(item_id, title="New title", status="closed")

# No
def update(self, item_id, fields: dict) -> int: ...
  store.update(item_id, {"title": "New title", "status": "closed"})
```

#### Constants for magic values

```python
ID_BYTES = 4
```


#### Never silently skip exceptions

Don't swallow exceptions with bare `except` or `except: pass`. Logging and moving on
counts as swallowing — the code keeps running in a broken state and the log line gets
ignored. If the exception is expected, handle it explicitly and recover gracefully. If
it's not expected, let it propagate — better to stop the application than hide bugs
behind silent failures.

```python
# Yes — expected, handled explicitly
try:
    config = json.loads(path.read_text())
except FileNotFoundError:
    config = default_config()

# No — silent skip hides real failures
try:
    config = json.loads(path.read_text())
except Exception:
    config = {}

# No — logging then continuing is still swallowing
try:
    config = json.loads(path.read_text())
except Exception as e:
    logger.error("failed to load config: %s", e)
    config = {}
```


### Dependency Injection

#### Inject, don't construct

Classes take their dependencies as arguments, not paths or config. Factory classmethods
handle construction. This enables testing with in-memory or fake backends.

```python
# Production
store = MyStore.from_path("data.db")

# Testing
store = MyStore(sqlite3.connect(":memory:"))
```


### Django

- Do not write Django migrations manually (e.g. using the Write tool). Always use Django's CLI to generate migrations instead.
- Never make database operations (obj.save, Model.objects.whatever, etc.) inside loops
- Don't create constants to use in `model_to_dict` fields, unless same fields are used multiple times.
    Good:
    ```python
    payload = model_to_dict(user, fields=["id", "email", "first_name"])
    ```

    Bad:
    ```python
    USER_FIELDS = ["id", "email", "first_name"]
    payload = model_to_dict(user, fields=USER_FIELDS)
    ```

    Good when reused:
    ```python
    USER_FIELDS = ["id", "email", "first_name"]

    payload = model_to_dict(user, fields=USER_FIELDS)
    audit_payload = model_to_dict(other_user, fields=USER_FIELDS)
    ```


### Pydantic

- Don't manually convert what Pydantic validates and coerces automatically. For example,
Pydantic coerces ISO strings to datetime — don't call `fromisoformat()` yourself.


### Pytest

- When running pytest, always include `--maxfail=5` to fail fast.


## Communication style

Respond terse like smart caveman. All technical substance stay. Only fluff die.

### Rules

Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact. Code blocks unchanged. Errors quoted exact.

Pattern: `[thing] [action] [reason]. [next step].`

Not: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

No filler/hedging. Keep articles + full sentences. Professional but tight
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
