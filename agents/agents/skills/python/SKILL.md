---
name: python
description: Python coding rules. Always use when working with Python, including editing, reviewing, or writing Python code, imports, code style, dependency injection, Pydantic, or Pytest.
---

# Python

## Imports

### Never re-export for backwards compatibility

When moving code to a new module, do not keep compatibility imports in the old module.
Update every caller to import from the new location instead. Re-exporting hides stale
boundaries, keeps dead paths alive, and makes future refactors harder.

```python
# Yes — callers import from the new home
from app.domain.items import Item

# No — old module re-exports the moved symbol
from app.domain.items import Item
```

### Don't patch import paths

Don't fix broken imports by changing `PYTHONPATH` or mutating `sys.path`. That hides a
bad package boundary and makes runtime behavior depend on execution location. Fix the
imports, package layout, or test invocation instead.

```python
# Yes — import from the real package path
from data_pipeline.processing.jobs import run_job
from data_pipeline.config import Settings

# No — mutating sys.path to make local imports work
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
for path in [PROJECT_ROOT / "processing", PROJECT_ROOT]:
    sys.path.insert(0, str(path))
```

## Code Style

### No underscore prefixes

Don't use `_` to signal "private." In Python everything is accessible regardless, so
the prefix is noise that conveys nothing the code structure doesn't already show. A
function only called by one other function in the same module is obviously a helper —
you can see that from usage. If it's in the module, it's part of the module.

The real "private" boundary is what you choose to test, not a naming convention. Test
through the public-facing functions; helpers get coverage indirectly. If you refactor
a helper away, no tests break.

### Functions over methods

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

### Inline trivial calls

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

### Inline pure object construction

Don't create functions whose only purpose is to instantiate one object from another
object. Inline the constructor at the call site so field mapping stays visible. If the
conversion is reused, owns domain meaning, or belongs with the target model, use a
`<Class>.from_<obj>` classmethod instead.

```python
# Yes — inline when used once
invoice = Invoice(
    customer_id=normalize_customer_id(order.customer_id),
    order_id=order.id,
    total_cents=order.total_cents,
    issued_at=clock.now(),
)

# Yes — classmethod when conversion is reusable or domain-owned
invoice = Invoice.from_order(order, issued_at=clock.now())

# No — free function only wraps constructor

def invoice_from_order(order, issued_at) -> Invoice:
    return Invoice(
        customer_id=normalize_customer_id(order.customer_id),
        order_id=order.id,
        total_cents=order.total_cents,
        issued_at=issued_at,
    )
```

### Inline single-use comprehensions

Don't extract a list, dict, or set comprehension into a helper only to give it a name.
Keep simple data shaping inline at the call site so readers can see the transformation
without jumping to another function.

Extract only when the logic is reused, has meaningful branching, performs I/O, or names
a real domain operation that hides more than one obvious comprehension.

```python
# Yes — transformation visible where result is used
user_ids_by_account_id = {
    account.id: [user.id for user in account.users]
    for account in accounts
}

# No — shallow single-use helper hides simple data shaping

def account_user_ids(accounts) -> dict[int, list[int]]:
    return {
        account.id: [user.id for user in account.users]
        for account in accounts
    }

user_ids_by_account_id = account_user_ids(accounts)
```

### Default arguments for configurability

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

### `**kwargs` over dict for named fields

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

### Constants for magic values

```python
ID_BYTES = 4
```

### Unpack return values instead of indexing

When a function returns multiple values, unpack them at the call site. Use `_` for values
you don't need. This makes the expected shape obvious and avoids temporary variables.

```python
# Yes
_, elapsed_ms = measure_request()

# No
request_stats = measure_request()
elapsed_ms = request_stats[1]
```

Use starred unpacking when you only need the last value from a variable-length return.

```python
# Yes
*_, checksum = parse_packet()

# No
checksum = parse_packet()[-1]
```

### Never silently skip exceptions

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

## Dependency Injection

### Inject, don't construct

Classes take their dependencies as arguments, not paths or config. Factory classmethods
handle construction. This enables testing with in-memory or fake backends.

```python
# Production
store = MyStore.from_path("data.db")

# Testing
store = MyStore(sqlite3.connect(":memory:"))
```

## Pydantic

- Don't manually convert what Pydantic validates and coerces automatically. For example,
Pydantic coerces ISO strings to datetime — don't call `fromisoformat()` yourself.

## Pytest

- When running pytest, always include `-q --maxfail=5` for concise fail-fast output.
