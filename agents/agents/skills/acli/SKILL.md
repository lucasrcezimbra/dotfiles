---
name: acli
description: Use the Atlassian CLI (acli) to interact with Jira Cloud. Auto-use when the user wants to use Jira.
---

# Atlassian CLI (acli) Skill

## Authentication
This skill assumes the acli is already authenticated. STOP everything and ask the user to authenticate if you encounter an authentication error when running acli commands.

## Creating a New Ticket

Use `acli jira workitem create` to create tickets.

Don't use Markdown for descriptions. Use ADF (Attlassian Document Format) for rich descriptions. See [ADF.md](./ADF.md) for the full reference with all block types and inline marks.

### Inline (flags only)

```bash
acli jira workitem create \
  --summary "Fix login bug" \
  --project "PROJ" \
  --type "Task" \
  --assignee "user@company.com" \
  --description "Plain text description" \
  --label "bug,urgent"
```

| Flag | Short | Required | Description |
|------|-------|----------|-------------|
| `--summary` | `-s` | Yes | Ticket title |
| `--project` | `-p` | Yes | Project key (e.g. `PROJ`) |
| `--type` | `-t` | Yes | `Epic`, `Story`, `Task`, `Bug` |
| `--assignee` | `-a` | No | Email, account ID, `@me`, or `default` |
| `--description` | `-d` | No | Plain text or ADF JSON string |
| `--description-file` | | No | Read description from a file |
| `--label` | `-l` | No | Comma-separated labels |
| `--parent` | | No | Parent work item ID (for sub-tasks) |
| `--editor` | `-e` | No | Open editor for summary & description |
| `--json` | | No | Output result as JSON |

### From JSON file

Best for rich descriptions ([ADF](./ADF.md)), custom fields, or scripted creation.

1. Write a JSON file (e.g. `ticket.json`):

```json
{
  "summary": "Fix login bug",
  "projectKey": "PROJ",
  "type": "Bug",
  "assignee": "user@company.com",
  "labels": ["bug", "urgent"],
  "parentIssueId": "PROJ-100",
  "description": {
    "type": "doc",
    "version": 1,
    "content": [
      { "type": "paragraph", "content": [{ "type": "text", "text": "Login returns 500 on invalid credentials." }] }
    ]
  },
  "additionalAttributes": {
    "customfield_10000": { "value": "Custom value" }
  }
}
```

2. Create the ticket:

```bash
acli jira workitem create --from-json ticket.json
```
