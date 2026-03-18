/**
 * Pytest Max Fail Extension
 *
 * Enforces that every pytest invocation includes --maxfail=5.
 *
 * 1. Injects a rule into the system prompt so the LLM knows upfront.
 * 2. Blocks any bash tool call that runs pytest without --maxfail as a safety net.
 *
 * Catches: pytest, python -m pytest, uv run pytest, hatch run pytest, and similar variants.
 * If --maxfail is already present (any value), the command is left alone.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const MAXFAIL_VALUE = 5;

/** Matches a pytest invocation: bare `pytest`, `python -m pytest`, `uv run pytest`, etc. */
const PYTEST_PATTERNS = [
  // bare pytest as the command
  /(?:^|&&|\|\||;|\|)\s*pytest\b/,
  // python -m pytest
  /(?:^|&&|\|\||;|\|)\s*python[23]?\s+-m\s+pytest\b/,
  // common runners: uv run, hatch run, poetry run, pipx run, pdm run
  /(?:^|&&|\|\||;|\|)\s*(?:uv|hatch|poetry|pipx|pdm)\s+run\s+pytest\b/,
];

/** Matches --maxfail in any form: --maxfail=N, --maxfail N, -x (which is --maxfail=1) */
const HAS_MAXFAIL = /--maxfail\b/;

function isPytestWithoutMaxfail(command: string): boolean {
  if (!PYTEST_PATTERNS.some((p) => p.test(command))) return false;
  if (HAS_MAXFAIL.test(command)) return false;
  return true;
}

export default function (pi: ExtensionAPI) {
  // Preventive: inject instruction into system prompt
  pi.on("before_agent_start", async (event) => {
    return {
      systemPrompt:
        event.systemPrompt +
        `\n\nIMPORTANT: When running pytest, ALWAYS include --maxfail=${MAXFAIL_VALUE}. For example: pytest --maxfail=${MAXFAIL_VALUE}`,
    };
  });

  // Reactive: block pytest calls that are missing --maxfail
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return undefined;

    const command = (event.input as { command: string }).command;

    if (isPytestWithoutMaxfail(command)) {
      return {
        block: true,
        reason: `pytest must include --maxfail=${MAXFAIL_VALUE}. Retry the command with --maxfail=${MAXFAIL_VALUE}.`,
      };
    }

    return undefined;
  });
}
