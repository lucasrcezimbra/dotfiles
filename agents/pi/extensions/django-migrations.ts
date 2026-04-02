/**
 * Django Migration Guard Extension
 *
 * Prevents hand-written Django migrations via the write tool.
 *
 * 1. Injects a rule into the system prompt so the LLM knows upfront.
 * 2. Blocks any write tool call targeting Django migration files like
 *    any path ending in /migrations/0001_*.py, /migrations/0068_*.py, etc.
 *
 * The agent should use Django's CLI instead, e.g.:
 *   python manage.py makemigrations
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const DJANGO_MIGRATION_WRITE_BLOCK_REASON =
  "Do not write Django migration files by hand. Use makemigrations from the Django CLI instead (for example: python manage.py makemigrations).";

const DJANGO_MIGRATION_PATH = /(?:^|\/)migrations\/\d{4}_[^/]+\.py$/;

function normalizePath(path: string): string {
  return path.replace(/^@/, "").replace(/\\/g, "/");
}

function isBlockedDjangoMigrationPath(path: string): boolean {
  return DJANGO_MIGRATION_PATH.test(normalizePath(path));
}

export default function (pi: ExtensionAPI) {
  // Preventive: inject instruction into system prompt
  pi.on("before_agent_start", async (event) => {
    return {
      systemPrompt:
        event.systemPrompt +
        "\n\nIMPORTANT: Do not write Django migrations using the Write tool. Never create files matching **/migrations/[0-9][0-9][0-9][0-9]_*.py by hand. Use Django's CLI to generate migrations instead (for example: python manage.py makemigrations).",
    };
  });

  // Reactive: block writes to hand-written Django migration files
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "write") return undefined;

    const path = (event.input as { path: string }).path;

    if (isBlockedDjangoMigrationPath(path)) {
      if (ctx.hasUI) {
        ctx.ui.notify(
          `Blocked hand-written Django migration: ${path}`,
          "warning",
        );
      }

      return {
        block: true,
        reason: DJANGO_MIGRATION_WRITE_BLOCK_REASON,
      };
    }

    return undefined;
  });
}
