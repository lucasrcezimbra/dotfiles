/**
 * Inspect the full provider payload being sent to the LLM.
 *
 * - Every request: saves the provider payload to
 *   ~/.pi/agent/inspects/<encoded-cwd>/<sessionId>-request-N.json
 */

import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  type ExtensionAPI,
  getAgentDir,
  getMarkdownTheme,
} from "@mariozechner/pi-coding-agent";
import { Markdown } from "@mariozechner/pi-tui";
import { showReadOnlyOverlay } from "./lib/read-only-overlay";

export default function (pi: ExtensionAPI) {
  let requestCount = 0;

  pi.registerFlag("inspect", {
    description:
      "Save the full provider payload for each request to ~/.pi/agent/inspects/<encoded-cwd>/<sessionId>-request-N.json",
    type: "boolean",
    default: false,
  });

  let inspectEnabled: boolean | undefined;

  pi.registerCommand("inspect:on", {
    description: "Enable provider payload inspection for subsequent requests",
    handler: async (_args, ctx) => {
      inspectEnabled = true;
      ctx.ui.notify("Provider payload inspection enabled", "info");
    },
  });

  pi.registerCommand("inspect:off", {
    description: "Disable provider payload inspection for subsequent requests",
    handler: async (_args, ctx) => {
      inspectEnabled = false;
      ctx.ui.notify("Provider payload inspection disabled", "info");
    },
  });

  pi.registerCommand("inspect:system", {
    description: "Show the current system prompt in a read-only overlay",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) return;

      const systemPrompt = ctx.getSystemPrompt();
      await showReadOnlyOverlay(ctx, {
        title: "Current system prompt",
        createContent: () =>
          new Markdown(systemPrompt, 0, 0, getMarkdownTheme()),
      });
    },
  });

  pi.on("before_provider_request", async (event, ctx) => {
    if ((inspectEnabled ?? pi.getFlag("inspect")) !== true) return;

    requestCount++;
    const encodedCwd = `--${ctx.cwd.replace(/^[/\\]/, "").replace(/[/\\:]/g, "-")}--`;
    const inspectDir = join(getAgentDir(), "inspects", encodedCwd);

    const payload = {
      request: requestCount,
      timestamp: new Date().toISOString(),
      providerPayload: event.payload,
    };

    mkdirSync(inspectDir, { recursive: true });
    const sessionId = ctx.sessionManager.getSessionId();
    const file = join(inspectDir, `${sessionId}-request-${requestCount}.json`);
    writeFileSync(file, JSON.stringify(payload, null, 2));

    ctx.ui.notify(
      `Provider payload inspect: request ${requestCount} -> ${file}`,
      "info",
    );
  });
}
