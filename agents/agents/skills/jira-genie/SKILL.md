---
name: jira-genie
description: Search, create, edit, and manage Jira issues via jira-genie CLI. Use when the user needs to interact with Jira — find tickets, create tasks, create tickets, add comments, update status, extract templates, or automate workflows.
---

# Jira Genie

Operate Jira Cloud through the `jira` CLI. All commands output JSON to stdout.

## Prerequisites

Check auth status before any operation:

```bash
jira auth status
```

If not logged in:

```bash
jira auth login
```

Check if schema is synced (needed for field resolution and completion):

```bash
jira fields list --filter summary
```

If empty or missing, sync:

```bash
jira fields sync                      # field list + discover projects
jira fields sync --project DEV        # also sync type schemas for a project
```

## Searching Issues

Use JQL queries. Always returns a JSON array of formatted issues.

```bash
# Open issues in a project
jira search "project = DEV AND status != Done"

# Current user's work
jira search "assignee = currentUser() AND status != Done"

# Children of an epic
jira search "parent = DEV-100"

# Current sprint
jira search "project = DEV AND sprint in openSprints()"

# With specific fields
jira search "project = DEV" --fields summary,status,assignee,parent
```

The output is an array of `{key, summary, status, assignee, priority, type}` objects.

**Pagination:** Search returns up to 50 results. For larger result sets, narrow
the JQL query (add date ranges, status filters, etc.) rather than expecting all
results at once.

## Reading Issues

```bash
# Formatted (clean JSON)
jira issue get DEV-123

# Specific fields only
jira issue get DEV-123 --fields summary,status,parent,components

# Raw API response (all fields, nested structure)
jira issue get DEV-123 --raw
```

Use `--raw` when you need fields not in the default format (description, comments,
custom fields, sprint info).

## Creating Issues

### From JSON with friendly names

```bash
jira issue create --json '{
  "project": "DEV",
  "issuetype": "Task",
  "summary": "Implement feature X",
  "parent": "DEV-100",
  "priority": "P2: Medium",
  "components": ["API"],
  "labels": ["backend"]
}'
```

Field names are resolved automatically: `story_points` → `customfield_10036`,
`team` → `customfield_10001`, etc.

Returns: `{"id": "12345", "key": "DEV-125", "self": "https://..."}`.

### Setting descriptions

Descriptions accept **Markdown** — it's auto-converted to Atlassian Document Format (ADF):

```bash
jira issue create --json '{
  "project": "DEV",
  "issuetype": "Task",
  "summary": "Fix the auth flow",
  "description": "## Problem\n\nUsers are getting **401 errors** after token refresh.\n\n## Steps to reproduce\n\n1. Login normally\n2. Wait for token expiry\n3. Try any API call\n\n## Notes\n\n- Affects `PaymentService`\n- See [docs](https://example.com/auth)"
}'
```

Supported Markdown elements:
- Headings (`#` through `######`)
- Bold (`**text**`), italic (`*text*`), inline code (`` `text` ``), strikethrough (`~~text~~`)
- Links (`[text](url)`)
- Bullet lists (`- item`) and ordered lists (`1. item`), including nested
- Code blocks (` ```language `)
- Blockquotes (`> text`)
- Horizontal rules (`---`)

Plain text works too — it becomes a single paragraph.

For pre-built ADF (rare), pass a dict — it goes through untouched:

```bash
jira issue create --json '{
  "description": {"type": "doc", "version": 1, "content": [...]}
}'
```

The same applies to the `environment` field.

### With a template

Templates provide defaults. Only specify what varies:

```bash
jira issue create --template backend --summary "Fix the race condition"
```

Override template fields:

```bash
jira issue create --template backend --json '{"parent": "DEV-200"}' --summary "Different epic"
```

Composition order (later overrides earlier):

```
template → --json → --set/--summary → resolved → API
```

### With --set flags

```bash
jira issue create --json '{"project": "DEV", "issuetype": "Task"}' \
  --summary "Quick task" \
  --set parent=DEV-100 \
  --set priority="P1: High"
```

### With --body-file (long description)

```bash
jira issue create --json '{"project": "DEV", "issuetype": "Task"}' \
  --summary "Fix the bug" \
  --body-file /tmp/description.md
```

### Raw payload (bypass resolution)

```bash
jira issue create --raw-payload '{"fields": {"project": {"key": "DEV"}, "issuetype": {"name": "Task"}, "summary": "Raw"}}'
```

## Extracting Templates from Existing Tickets

When the user wants a template based on how they already create tickets:

### Step 1: Find representative tickets

```bash
jira search "reporter = currentUser() AND type = Task ORDER BY created DESC" --fields summary,parent,components,labels,priority
```

### Step 2: Inspect fields and schema

```bash
# Look at a real ticket's fields
jira issue get DEV-123 --raw

# Check all available fields for that type (required fields, allowed values)
jira fields schema --project DEV --type Task
```

Look at the fields that are consistent across tickets (project, issuetype, parent,
components, labels) — these become the template. Ignore fields that vary per ticket
(summary, description).

### Step 3: Create the template

Extract the common fields into a template:

```bash
jira template create my-template --json '{
  "project": "DEV",
  "issuetype": "Task",
  "parent": "DEV-100",
  "components": ["API"]
}'
```

### Step 4: Verify

```bash
jira template show my-template
```

## Managing Templates

```bash
jira template list                    # all templates
jira template show backend            # view one
jira template create NAME --json '{}'  # create
jira template delete NAME             # remove

jira template default backend         # set as default
jira template default                 # show current default
jira template default --clear         # remove default
```

When a default is set, `jira issue create --summary "..."` uses it automatically.

## Editing Issues

```bash
# Set individual fields
jira issue edit DEV-123 --set priority="P1: High" --set story_points=5

# JSON override
jira issue edit DEV-123 --json '{"team": "Backend", "labels": ["urgent"]}'

# Set description directly (accepts Markdown)
jira issue edit DEV-123 --description "## Updated\n\nNew description"

# Read description from file (avoids shell escaping)
jira issue edit DEV-123 --body-file /tmp/description.md

# Raw payload
jira issue edit DEV-123 --raw-payload '{"fields": {"summary": "Updated title"}}'
```

## Workflow Operations

```bash
# Transition status
jira issue transition DEV-123 "In Progress"
jira issue transition DEV-123 "Done"

# Assign
jira issue assign DEV-123 alice@example.com

# Comment
jira issue comment DEV-123 "Fixed in commit abc1234"

# Link issues (--type values: "blocks", "is blocked by", "relates to", "duplicates", "is duplicated by", "clones", "is cloned by")
jira issue link DEV-123 DEV-456 --type blocks
```

## Bulk Operations

Only bulk edit is supported. Use it to update the same field(s) across multiple issues:

```bash
jira bulk edit DEV-1 DEV-2 DEV-3 --set parent=DEV-100
jira bulk edit DEV-1 DEV-2 --set priority="P1: High"
jira bulk edit DEV-1 DEV-2 --json '{"team": "Backend"}'
```

For bulk creation or transitions, loop over individual commands.

## Schema Inspection

Use these to discover what fields and values are available:

```bash
# All fields with their IDs and types
jira fields list

# Search for a field by name
jira fields list --filter story

# Full schema for a project + issue type (required fields, allowed values)
jira fields schema --project DEV --type Task
```

The schema output tells you exactly what to pass when creating or editing issues.

## Sprints and Boards

Discover the board ID first, then use it for sprint operations:

```bash
# Find the board for a project
jira board list --project DEV

# Sprint operations (use the board ID from above)
jira sprint current --board 42
jira sprint list --board 42 --state active,future
jira sprint issues 123 --fields summary,status,assignee

# Backlog
jira board backlog 42
```

## Users

```bash
jira user me                # current user
jira user search "alice"    # find users
```

## Error Handling

All errors output structured JSON to stderr:

```json
{"error": "404 Client Error: Not Found for url: ...", "type": "HTTPError"}
```

Parse the `error` and `type` fields to decide how to recover:

When a command fails, read the error message and recover:

- **Field validation error** on create/edit → check required fields and allowed values:
  ```bash
  jira fields schema --project DEV --type Task
  ```
- **Unknown field name** → list available fields and find the correct name:
  ```bash
  jira fields list --filter <keyword>
  ```
- **Invalid transition** → the issue's current status may not allow that transition.
  Check the issue's current status with `jira issue get DEV-123` and try the
  appropriate intermediate transition.
- **Permission denied / 403** → the authenticated user lacks permission for that
  project or operation. Verify with `jira auth status` and `jira user me`.
- **Invalid JQL** → simplify the query, check field names and function syntax.

## Field Resolution Reference

When using `--json` or `--set`, field names and values are resolved automatically:

| You write | API receives |
|-----------|-------------|
| `"project": "DEV"` | `"project": {"key": "DEV"}` |
| `"issuetype": "Task"` | `"issuetype": {"name": "Task"}` |
| `"parent": "DEV-100"` | `"parent": {"key": "DEV-100"}` |
| `"priority": "P1: High"` | `"priority": {"name": "P1: High"}` |
| `"team": "Backend"` | `"customfield_10001": {"value": "Backend"}` |
| `"components": ["API"]` | `"components": [{"name": "API"}]` |
| `"story_points": 5` | `"customfield_10036": 5` |
| `"description": "**Markdown** text"` | parsed as Markdown, converted to ADF |
| `"description": {ADF doc}` | passed through as-is (dicts are never wrapped) |

Use `--raw-payload` to bypass all resolution and send exact JSON to the API.

## Common Agent Patterns

### Gather context before working

```bash
jira issue get DEV-123
jira search "parent = DEV-123" --fields summary,status
```

### Update a ticket's description

```bash
# Short description inline
jira issue edit DEV-123 --description "## Updated analysis\n\nThe root cause is..."

# Long description from file (avoids shell escaping issues)
jira issue edit DEV-123 --body-file /tmp/description.md

# Or via --json
jira issue edit DEV-123 --json '{"description": "Markdown text here"}'
```

### Add a comment

```bash
# Short comment
jira issue comment DEV-123 "Fixed in commit abc1234"

# Long comment from file
jira issue comment DEV-123 --body-file /tmp/analysis.md
```

Comments accept Markdown — it's auto-converted to Atlassian Document Format.

### Create task, do work, close

```bash
jira issue create --template backend --summary "Fix the bug"
# ... do the work ...
jira issue transition DEV-124 "In Progress"
jira issue comment DEV-124 "Working on it"
# ... finish ...
jira issue transition DEV-124 "Done"
jira issue comment DEV-124 "Fixed in commit abc1234"
```

### Discover and report

```bash
jira search "project = DEV AND sprint in openSprints() AND status = 'To Do'" --fields summary,assignee,priority
```
