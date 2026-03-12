/**
 * Inspect the full prompt being sent to the LLM.
 *
 * - Every turn: saves system prompt + messages to ~/.pi/agent/inspects/<encoded-cwd>/<sessionId>-turn-N.json
 */

import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  type ExtensionAPI,
  getAgentDir,
  getMarkdownTheme,
} from "@mariozechner/pi-coding-agent";
import {
  Container,
  Key,
  Markdown,
  matchesKey,
  Text,
} from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  let turnCount = 0;

  pi.registerFlag("inspect", {
    description:
      "Save the full prompt context for each turn to ~/.pi/agent/inspects/<encoded-cwd>/<sessionId>-turn-N.json",
    type: "boolean",
    default: false,
  });

  let inspectEnabled: boolean | undefined;

  pi.registerCommand("inspect:on", {
    description: "Enable prompt inspection for subsequent turns",
    handler: async (_args, ctx) => {
      inspectEnabled = true;
      ctx.ui.notify("Prompt inspection enabled", "info");
    },
  });

  pi.registerCommand("inspect:off", {
    description: "Disable prompt inspection for subsequent turns",
    handler: async (_args, ctx) => {
      inspectEnabled = false;
      ctx.ui.notify("Prompt inspection disabled", "info");
    },
  });

  pi.registerCommand("inspect:system", {
    description: "Show the current system prompt in a read-only overlay",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) return;

      const systemPrompt = ctx.getSystemPrompt();
      await ctx.ui.custom<void>(
        (tui, theme, _kb, done) => {
          const container = new Container();
          container.addChild(
            new Text(
              theme.fg("accent", theme.bold("Current system prompt")),
              1,
              0,
            ),
          );
          container.addChild(
            new Text(
              theme.fg("dim", "Read-only • Esc or Enter to close"),
              1,
              0,
            ),
          );
          container.addChild(
            new Markdown(systemPrompt, 1, 1, getMarkdownTheme()),
          );

          return {
            render: (width: number) => container.render(width),
            invalidate: () => container.invalidate(),
            handleInput: (data: string) => {
              if (matchesKey(data, Key.escape) || matchesKey(data, Key.enter)) {
                done();
                return;
              }
              tui.requestRender();
            },
          };
        },
        {
          overlay: true,
          overlayOptions: {
            width: "85%",
            maxHeight: "85%",
            anchor: "center",
            margin: 1,
          },
        },
      );
    },
  });

  pi.on("context", async (event, ctx) => {
    if ((inspectEnabled ?? pi.getFlag("inspect")) !== true) return;

    turnCount++;
    const systemPrompt = ctx.getSystemPrompt();
    const encodedCwd = `--${ctx.cwd.replace(/^[/\\]/, "").replace(/[/\\:]/g, "-")}--`;
    const inspectDir = join(getAgentDir(), "inspects", encodedCwd);

    const payload = {
      turn: turnCount,
      timestamp: new Date().toISOString(),
      systemPrompt,
      messageCount: event.messages.length,
      messages: event.messages,
    };

    mkdirSync(inspectDir, { recursive: true });
    const sessionId = ctx.sessionManager.getSessionId();
    const file = join(inspectDir, `${sessionId}-turn-${turnCount}.json`);
    writeFileSync(file, JSON.stringify(payload, null, 2));

    ctx.ui.notify(
      `Prompt inspect: turn ${turnCount}, ${event.messages.length} messages -> ${file}`,
      "info",
    );
  });
}
