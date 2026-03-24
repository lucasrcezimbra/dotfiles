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
import {
  Container,
  Key,
  Markdown,
  matchesKey,
  Text,
  truncateToWidth,
  visibleWidth,
} from "@mariozechner/pi-tui";

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
      await ctx.ui.custom<void>(
        (tui, theme, _kb, done) => {
          let scrollOffset = 0;
          let contentLines: string[] = [];
          let lastWidth = 0;

          const border = (s: string) => theme.fg("accent", s);

          const header = new Container();
          header.addChild(
            new Text(
              theme.fg("accent", theme.bold("Current system prompt")),
              1,
              0,
            ),
          );
          header.addChild(
            new Text(
              theme.fg(
                "dim",
                "Read-only • ↑↓/j k/PgUp PgDn to scroll • Esc or Enter to close",
              ),
              1,
              0,
            ),
          );

          const content = new Markdown(systemPrompt, 1, 1, getMarkdownTheme());

          // Pad or truncate a line to exactly `w` visible chars, preserving ANSI
          function padLine(line: string, w: number): string {
            const vw = visibleWidth(line);
            if (vw >= w) return truncateToWidth(line, w);
            return line + " ".repeat(w - vw);
          }

          function buildContentLines(innerWidth: number): string[] {
            return [
              ...header.render(innerWidth),
              ...content.render(innerWidth),
            ];
          }

          return {
            render: (width: number) => {
              // Inner width: total width minus "│ " and " │" (4 chars)
              const innerWidth = Math.max(1, width - 4);

              if (lastWidth !== width) {
                header.invalidate();
                content.invalidate();
                lastWidth = width;
              }
              contentLines = buildContentLines(innerWidth);

              const termRows = process.stdout.rows || 24;
              // 85% of terminal height, minus margin, minus top/bottom border lines
              const visibleHeight = Math.max(
                1,
                Math.floor(termRows * 0.85) - 4,
              );
              const maxScroll = Math.max(
                0,
                contentLines.length - visibleHeight,
              );
              scrollOffset = Math.min(scrollOffset, maxScroll);

              const result: string[] = [];

              // Top border: ┌─── title ───┐
              const title = " Current system prompt ";
              const titleLen = visibleWidth(title);
              const sideLen = Math.max(0, width - 2 - titleLen);
              const leftDash = Math.floor(sideLen / 2);
              const rightDash = sideLen - leftDash;
              result.push(
                border(
                  "┌" +
                    "─".repeat(leftDash) +
                    title +
                    "─".repeat(rightDash) +
                    "┐",
                ),
              );

              // Help text line inside the box
              const helpText = theme.fg(
                "dim",
                "↑↓/j k/PgUp PgDn to scroll • Esc or Enter to close",
              );
              result.push(
                border("│") +
                  " " +
                  padLine(helpText, innerWidth) +
                  " " +
                  border("│"),
              );

              // Separator after help
              result.push(border("├" + "─".repeat(width - 2) + "┤"));

              // Visible content lines with side borders
              const visible = contentLines.slice(
                scrollOffset,
                scrollOffset + visibleHeight,
              );
              for (const line of visible) {
                result.push(
                  border("│") +
                    " " +
                    padLine(line, innerWidth) +
                    " " +
                    border("│"),
                );
              }

              // Pad remaining space if content is shorter than visibleHeight
              for (let i = visible.length; i < visibleHeight; i++) {
                result.push(border("│") + " ".repeat(width - 2) + border("│"));
              }

              // Bottom border with scroll indicator
              if (contentLines.length > visibleHeight) {
                const pct = Math.round(
                  ((scrollOffset + visibleHeight) / contentLines.length) * 100,
                );
                const info = ` ${Math.min(pct, 100)}% (${scrollOffset + 1}-${Math.min(scrollOffset + visibleHeight, contentLines.length)}/${contentLines.length}) `;
                const infoLen = visibleWidth(info);
                const bSideLen = Math.max(0, width - 2 - infoLen);
                const bLeft = Math.floor(bSideLen / 2);
                const bRight = bSideLen - bLeft;
                result.push(
                  border(
                    "└" + "─".repeat(bLeft) + info + "─".repeat(bRight) + "┘",
                  ),
                );
              } else {
                result.push(border("└" + "─".repeat(width - 2) + "┘"));
              }

              return result;
            },
            invalidate: () => {
              header.invalidate();
              content.invalidate();
              lastWidth = 0;
            },
            handleInput: (data: string) => {
              if (matchesKey(data, Key.escape) || matchesKey(data, Key.enter)) {
                done();
                return;
              }

              const termRows = process.stdout.rows || 24;
              const visibleHeight = Math.max(
                1,
                Math.floor(termRows * 0.85) - 4,
              );
              const maxScroll = Math.max(
                0,
                contentLines.length - visibleHeight,
              );

              if (matchesKey(data, Key.up) || matchesKey(data, "k")) {
                scrollOffset = Math.max(0, scrollOffset - 1);
              } else if (matchesKey(data, Key.down) || matchesKey(data, "j")) {
                scrollOffset = Math.min(maxScroll, scrollOffset + 1);
              } else if (matchesKey(data, Key.pageUp)) {
                scrollOffset = Math.max(0, scrollOffset - visibleHeight);
              } else if (matchesKey(data, Key.pageDown)) {
                scrollOffset = Math.min(
                  maxScroll,
                  scrollOffset + visibleHeight,
                );
              } else if (matchesKey(data, Key.home) || matchesKey(data, "g")) {
                scrollOffset = 0;
              } else if (
                matchesKey(data, Key.end) ||
                matchesKey(data, Key.shift("g"))
              ) {
                scrollOffset = maxScroll;
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
