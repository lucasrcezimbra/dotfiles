// TODO: Caching/indexing — build an index (file → sessions) that updates
//       incrementally instead of brute-force scanning all JSONL files on every
//       /blame invocation.
// TODO: Read tracking — optional track `read` operations, not just `edit`/`write`.
// TODO: Richer output — show how many times a session touched the file, snippets
//       of what changed (diffs from EditToolDetails), and support summary vs
//       detailed view.
// TODO: Smarter path matching — symlink resolution (realpath), glob/pattern
//       matching (`/blame src/*.ts`), fuzzy/partial matching.
// TODO: Scope filtering — add option to limit to current project only
//       (e.g., `/blame --local <file>`) instead of always scanning all projects.
// TODO: Support other harnesses — Claude Code, Codex, Amp, etc. Parse their
//       session/history formats to find file mutations across tools.

import { readFile } from "node:fs/promises";
import { isAbsolute, resolve } from "node:path";
import type { ExtensionAPI, SessionInfo } from "@mariozechner/pi-coding-agent";
import { SessionManager } from "@mariozechner/pi-coding-agent";

interface MatchedSession {
  info: SessionInfo;
  tools: string[];
}

async function findSessionsThatTouchedFile(
  targetPath: string,
  sessions: SessionInfo[],
): Promise<MatchedSession[]> {
  const matches: MatchedSession[] = [];

  for (const session of sessions) {
    try {
      const content = await readFile(session.path, "utf8");
      const lines = content.trim().split("\n");
      const toolsUsed = new Set<string>();

      for (const line of lines) {
        if (!line.trim()) continue;
        let entry: Record<string, unknown>;
        try {
          entry = JSON.parse(line) as Record<string, unknown>;
        } catch {
          continue;
        }
        if (entry.type !== "message") continue;
        const msg = entry.message as Record<string, unknown> | undefined;
        if (msg?.role !== "assistant" || !Array.isArray(msg.content)) continue;

        for (const block of msg.content as Array<Record<string, unknown>>) {
          if (block.type !== "toolCall") continue;
          if (block.name !== "edit" && block.name !== "write") continue;
          const args = block.arguments as Record<string, unknown> | undefined;
          const callPath = args?.path;
          if (typeof callPath !== "string") continue;

          const resolvedCallPath = isAbsolute(callPath)
            ? callPath
            : resolve(session.cwd || "/", callPath);

          if (resolvedCallPath === targetPath) {
            toolsUsed.add(block.name as string);
          }
        }
      }

      if (toolsUsed.size > 0) {
        matches.push({ info: session, tools: [...toolsUsed] });
      }
    } catch {
      // Skip unreadable sessions
    }
  }

  return matches;
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("blame", {
    description: "List pi sessions that modified a file",
    handler: async (args, ctx) => {
      const filePath = args.trim();
      if (!filePath) {
        ctx.ui.notify("Usage: /blame <file>", "error");
        return;
      }

      const targetPath = isAbsolute(filePath)
        ? filePath
        : resolve(ctx.cwd, filePath);

      ctx.ui.notify("Scanning sessions...", "info");

      const sessions = await SessionManager.listAll();
      const matches = await findSessionsThatTouchedFile(targetPath, sessions);

      if (matches.length === 0) {
        ctx.ui.notify(`No sessions found that modified ${filePath}`, "info");
        return;
      }

      const items = matches.map((m) => {
        const date = m.info.modified
          .toISOString()
          .slice(0, 16)
          .replace("T", " ");
        const tools = m.tools.join(", ");
        const label =
          m.info.name || m.info.firstMessage.slice(0, 60) || m.info.id;
        return `[${date}] [${tools}] ${label}`;
      });

      const choice = await ctx.ui.select(
        `Sessions that modified ${filePath} (${matches.length}):`,
        items,
      );

      if (choice === undefined) return;

      const selected = matches[items.indexOf(choice)];
      if (selected) {
        await ctx.switchSession(selected.info.path);
      }
    },
  });
}
