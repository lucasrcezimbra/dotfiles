import { createRequire, stripTypeScriptTypes } from "node:module";
import { resolve } from "node:path";
import { inspect as utilInspect } from "node:util";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { showReadOnlyOverlay } from "./lib/read-only-overlay";

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
  await showReadOnlyOverlay(ctx, {
    title,
    tone: kind === "error" ? "error" : "accent",
    fallbackContent: content,
    createContent: () => new Text(content, 0, 0),
  });
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
