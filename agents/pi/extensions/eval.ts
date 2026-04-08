import { createRequire, stripTypeScriptTypes } from "node:module";
import { resolve } from "node:path";
import { inspect as utilInspect } from "node:util";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@mariozechner/pi-coding-agent";
import {
  Key,
  matchesKey,
  Text,
  truncateToWidth,
  visibleWidth,
} from "@mariozechner/pi-tui";

type EvalResult = {
  script: string;
  logs: string[];
  result: unknown;
};

const AsyncFunction = Object.getPrototypeOf(async () => {}).constructor as new (
  ...args: string[]
) => (...callArgs: unknown[]) => Promise<unknown>;

function formatValue(value: unknown): string {
  if (typeof value === "string") return value;
  return utilInspect(value, {
    depth: 8,
    colors: false,
    compact: false,
    breakLength: 100,
    maxArrayLength: 200,
    maxStringLength: 20_000,
  });
}

function stripSourceUrl(code: string): string {
  return code.replace(/\n*\/\/# sourceURL=.*$/s, "").trim();
}

function stripTrailingSemicolon(code: string): string {
  return code.replace(/;\s*$/, "");
}

function transpileTypeScript(code: string, sourceUrl: string): string {
  const originalEmitWarning = process.emitWarning;

  process.emitWarning = function emitWarning(warning, ...args) {
    if (String(warning).includes("stripTypeScriptTypes")) return;
    return originalEmitWarning.call(this, warning, ...args);
  };

  try {
    return stripTrailingSemicolon(
      stripSourceUrl(
        stripTypeScriptTypes(code, {
          mode: "transform",
          sourceUrl,
        }),
      ),
    );
  } finally {
    process.emitWarning = originalEmitWarning;
  }
}

function createCapturedConsole(logs: string[]) {
  const push = (level: string, values: unknown[]) => {
    logs.push(
      `[${level}] ${values.map((value) => formatValue(value)).join(" ")}`,
    );
  };

  return {
    log: (...values: unknown[]) => push("log", values),
    info: (...values: unknown[]) => push("info", values),
    warn: (...values: unknown[]) => push("warn", values),
    error: (...values: unknown[]) => push("error", values),
    debug: (...values: unknown[]) => push("debug", values),
    dir: (value: unknown) => push("dir", [value]),
    table: (value: unknown) => push("table", [value]),
    assert: (condition: unknown, ...values: unknown[]) => {
      if (condition) return;
      push("assert", values.length > 0 ? values : ["Assertion failed"]);
    },
  } satisfies Partial<Console>;
}

async function runEvalScript(
  script: string,
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
): Promise<EvalResult> {
  const logs: string[] = [];
  const capturedConsole = createCapturedConsole(logs);
  const require = createRequire(resolve(ctx.cwd, "__pi_eval__.cjs"));

  const runExpression = async () => {
    const expressionJs = transpileTypeScript(
      `(${script})`,
      "pi-eval-expression.ts",
    );
    const fn = new AsyncFunction(
      "pi",
      "ctx",
      "console",
      "inspect",
      "require",
      `return (${expressionJs});`,
    );
    return fn(pi, ctx, capturedConsole, formatValue, require);
  };

  const runBody = async () => {
    const wrappedScript = `(async function __pi_eval__() {\n${script}\n})()`;
    const bodyJs = transpileTypeScript(wrappedScript, "pi-eval-script.ts");
    const fn = new AsyncFunction(
      "pi",
      "ctx",
      "console",
      "inspect",
      "require",
      `return await (${bodyJs});`,
    );
    return fn(pi, ctx, capturedConsole, formatValue, require);
  };

  let result: unknown;

  try {
    result = await runExpression();
  } catch {
    result = await runBody();
  }

  return { script, logs, result };
}

function buildSuccessOutput({ script, logs, result }: EvalResult): string {
  const sections = [
    "Script",
    "------",
    script,
    "",
    "Result",
    "------",
    formatValue(result),
    "",
    "Console",
    "-------",
    logs.length > 0 ? logs.join("\n") : "(no console output)",
  ];

  if (result === undefined) {
    sections.push(
      "",
      "Tip",
      "---",
      "For multi-statement scripts, use `return ...` if you want a result value to be shown.",
    );
  }

  return sections.join("\n");
}

function formatError(error: unknown): string {
  if (error instanceof Error) {
    return error.stack || `${error.name}: ${error.message}`;
  }
  return formatValue(error);
}

async function showOutputOverlay(
  ctx: ExtensionCommandContext,
  title: string,
  content: string,
  kind: "info" | "error",
): Promise<void> {
  if (!ctx.hasUI) {
    process.stdout.write(`${title}\n${content}\n`);
    return;
  }

  await ctx.ui.custom<void>(
    (tui, theme, _kb, done) => {
      let scrollOffset = 0;
      let contentLines: string[] = [];
      let lastWidth = 0;

      const border = (text: string) =>
        theme.fg(kind === "error" ? "error" : "accent", text);

      const padLine = (line: string, width: number): string => {
        const currentWidth = visibleWidth(line);
        if (currentWidth >= width) return truncateToWidth(line, width);
        return line + " ".repeat(width - currentWidth);
      };

      const buildLines = (innerWidth: number): string[] => {
        const header = new Text(
          theme.fg(kind === "error" ? "error" : "accent", theme.bold(title)),
          1,
          0,
        );
        const help = new Text(
          theme.fg(
            "dim",
            "Read-only • ↑↓/j k/PgUp PgDn to scroll • Esc or Enter to close",
          ),
          1,
          0,
        );
        const body = new Text(content, 1, 1);

        return [
          ...header.render(innerWidth),
          ...help.render(innerWidth),
          ...body.render(innerWidth),
        ];
      };

      return {
        render: (width: number) => {
          const innerWidth = Math.max(1, width - 4);

          if (lastWidth !== width) {
            contentLines = buildLines(innerWidth);
            lastWidth = width;
          }

          const termRows = process.stdout.rows || 24;
          const visibleHeight = Math.max(1, Math.floor(termRows * 0.85) - 4);
          const maxScroll = Math.max(0, contentLines.length - visibleHeight);
          scrollOffset = Math.min(scrollOffset, maxScroll);

          const result: string[] = [];
          const titleText = ` ${title} `;
          const titleWidth = visibleWidth(titleText);
          const sideWidth = Math.max(0, width - 2 - titleWidth);
          const left = Math.floor(sideWidth / 2);
          const right = sideWidth - left;

          result.push(
            border(`┌${"─".repeat(left)}${titleText}${"─".repeat(right)}┐`),
          );

          const visible = contentLines.slice(
            scrollOffset,
            scrollOffset + visibleHeight,
          );
          for (const line of visible) {
            result.push(
              `${border("│")} ${padLine(line, innerWidth)} ${border("│")}`,
            );
          }

          for (let i = visible.length; i < visibleHeight; i++) {
            result.push(border("│") + " ".repeat(width - 2) + border("│"));
          }

          if (contentLines.length > visibleHeight) {
            const info = ` ${scrollOffset + 1}-${Math.min(scrollOffset + visibleHeight, contentLines.length)}/${contentLines.length} `;
            const infoWidth = visibleWidth(info);
            const bottomSide = Math.max(0, width - 2 - infoWidth);
            const bottomLeft = Math.floor(bottomSide / 2);
            const bottomRight = bottomSide - bottomLeft;
            result.push(
              border(
                "└" +
                  "─".repeat(bottomLeft) +
                  info +
                  "─".repeat(bottomRight) +
                  "┘",
              ),
            );
          } else {
            result.push(border(`└${"─".repeat(width - 2)}┘`));
          }

          return result;
        },
        invalidate: () => {
          lastWidth = 0;
          contentLines = [];
        },
        handleInput: (data: string) => {
          if (matchesKey(data, Key.escape) || matchesKey(data, Key.enter)) {
            done();
            return;
          }

          const termRows = process.stdout.rows || 24;
          const visibleHeight = Math.max(1, Math.floor(termRows * 0.85) - 4);
          const maxScroll = Math.max(0, contentLines.length - visibleHeight);

          if (matchesKey(data, Key.up) || matchesKey(data, "k")) {
            scrollOffset = Math.max(0, scrollOffset - 1);
          } else if (matchesKey(data, Key.down) || matchesKey(data, "j")) {
            scrollOffset = Math.min(maxScroll, scrollOffset + 1);
          } else if (matchesKey(data, Key.pageUp)) {
            scrollOffset = Math.max(0, scrollOffset - visibleHeight);
          } else if (matchesKey(data, Key.pageDown)) {
            scrollOffset = Math.min(maxScroll, scrollOffset + visibleHeight);
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

export default function evalExtension(pi: ExtensionAPI) {
  pi.registerCommand("eval", {
    description:
      "Evaluate a TypeScript expression or script. With no args, opens an editor.",
    handler: async (args, ctx) => {
      let script = args.trim();

      if (!script) {
        if (!ctx.hasUI) return;
        const edited = await ctx.ui.editor(
          "TypeScript to evaluate",
          'pi.getAllTools().filter((t) => t.sourceInfo.source === "builtin")',
        );
        if (edited === undefined) return;
        script = edited.trim();
      }

      if (!script) {
        ctx.ui.notify("Nothing to evaluate", "error");
        return;
      }

      try {
        const evaluation = await runEvalScript(script, pi, ctx);
        await showOutputOverlay(
          ctx,
          "Eval Result",
          buildSuccessOutput(evaluation),
          "info",
        );
      } catch (error) {
        await showOutputOverlay(ctx, "Eval Error", formatError(error), "error");
      }
    },
  });
}
