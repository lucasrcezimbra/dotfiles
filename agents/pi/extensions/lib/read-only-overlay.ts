import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import {
  type Component,
  Key,
  matchesKey,
  truncateToWidth,
  visibleWidth,
} from "@mariozechner/pi-tui";

type OverlayTheme = ExtensionContext["ui"]["theme"];

type OverlayTone = "accent" | "error";

interface ShowReadOnlyOverlayOptions {
  title: string;
  tone?: OverlayTone;
  helpText?: string;
  fallbackContent?: string;
  createContent: (theme: OverlayTheme) => Component;
}

const DEFAULT_HELP_TEXT =
  "Read-only • ↑↓/j k/PgUp PgDn to scroll • Esc or Enter to close";

function padLine(line: string, width: number): string {
  const currentWidth = visibleWidth(line);
  if (currentWidth >= width) return truncateToWidth(line, width);
  return line + " ".repeat(width - currentWidth);
}

function getVisibleHeight(): number {
  const termRows = process.stdout.rows || 24;
  return Math.max(1, Math.floor(termRows * 0.85) - 4);
}

export async function showReadOnlyOverlay(
  ctx: ExtensionContext,
  {
    title,
    tone = "accent",
    helpText = DEFAULT_HELP_TEXT,
    fallbackContent,
    createContent,
  }: ShowReadOnlyOverlayOptions,
): Promise<void> {
  if (!ctx.hasUI) {
    if (fallbackContent !== undefined) {
      process.stdout.write(`${title}\n${fallbackContent}\n`);
    }
    return;
  }

  await ctx.ui.custom<void>(
    (tui, theme, _kb, done) => {
      let scrollOffset = 0;
      let content = createContent(theme);
      let contentLines: string[] = [];
      let lastInnerWidth = 0;

      const border = (text: string) =>
        theme.fg(tone === "error" ? "error" : "accent", text);

      const renderTopBorder = (width: number): string => {
        const titleText = ` ${title} `;
        const titleWidth = visibleWidth(titleText);
        const sideWidth = Math.max(0, width - 2 - titleWidth);
        const left = Math.floor(sideWidth / 2);
        const right = sideWidth - left;
        return border(`┌${"─".repeat(left)}${titleText}${"─".repeat(right)}┐`);
      };

      const renderBottomBorder = (
        width: number,
        visibleHeight: number,
        totalLines: number,
      ): string => {
        if (totalLines <= visibleHeight) {
          return border(`└${"─".repeat(width - 2)}┘`);
        }

        const end = Math.min(scrollOffset + visibleHeight, totalLines);
        const pct = Math.min(Math.round((end / totalLines) * 100), 100);
        const info = ` ${pct}% (${scrollOffset + 1}-${end}/${totalLines}) `;
        const infoWidth = visibleWidth(info);
        const sideWidth = Math.max(0, width - 2 - infoWidth);
        const left = Math.floor(sideWidth / 2);
        const right = sideWidth - left;
        return border(`└${"─".repeat(left)}${info}${"─".repeat(right)}┘`);
      };

      const updateScroll = (delta: number, maxScroll: number) => {
        scrollOffset = Math.max(0, Math.min(maxScroll, scrollOffset + delta));
      };

      return {
        render: (width: number) => {
          const innerWidth = Math.max(1, width - 4);
          if (lastInnerWidth !== innerWidth || contentLines.length === 0) {
            contentLines = content.render(innerWidth);
            lastInnerWidth = innerWidth;
          }

          const visibleHeight = getVisibleHeight();
          const maxScroll = Math.max(0, contentLines.length - visibleHeight);
          scrollOffset = Math.min(scrollOffset, maxScroll);

          const result: string[] = [];
          result.push(renderTopBorder(width));
          result.push(
            border("│") +
              " " +
              padLine(theme.fg("dim", helpText), innerWidth) +
              " " +
              border("│"),
          );
          result.push(border(`├${"─".repeat(width - 2)}┤`));

          const visibleLines = contentLines.slice(
            scrollOffset,
            scrollOffset + visibleHeight,
          );
          for (const line of visibleLines) {
            result.push(
              border("│") + " " + padLine(line, innerWidth) + " " + border("│"),
            );
          }

          for (let i = visibleLines.length; i < visibleHeight; i++) {
            result.push(border("│") + " ".repeat(width - 2) + border("│"));
          }

          result.push(
            renderBottomBorder(width, visibleHeight, contentLines.length),
          );
          return result;
        },
        invalidate: () => {
          content = createContent(theme);
          contentLines = [];
          lastInnerWidth = 0;
        },
        handleInput: (data: string) => {
          if (matchesKey(data, Key.escape) || matchesKey(data, Key.enter)) {
            done();
            return;
          }

          if (contentLines.length === 0) {
            const innerWidth = Math.max(1, lastInnerWidth || 1);
            contentLines = content.render(innerWidth);
            lastInnerWidth = innerWidth;
          }

          const visibleHeight = getVisibleHeight();
          const maxScroll = Math.max(0, contentLines.length - visibleHeight);

          if (matchesKey(data, Key.up) || matchesKey(data, "k")) {
            updateScroll(-1, maxScroll);
          } else if (matchesKey(data, Key.down) || matchesKey(data, "j")) {
            updateScroll(1, maxScroll);
          } else if (matchesKey(data, Key.pageUp)) {
            updateScroll(-visibleHeight, maxScroll);
          } else if (matchesKey(data, Key.pageDown)) {
            updateScroll(visibleHeight, maxScroll);
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
}
