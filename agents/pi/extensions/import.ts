import { mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, extname, join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface ExportedSessionData {
  header?: Record<string, unknown>;
  entries?: unknown[];
}

function extractSessionDataBase64(html: string): string {
  const match = html.match(
    /<script\b(?=[^>]*\bid=["']session-data["'])(?=[^>]*\btype=["']application\/json["'])[^>]*>([\s\S]*?)<\/script>/i,
  );

  if (!match?.[1]) {
    throw new Error(
      'No <script id="session-data" type="application/json"> block found',
    );
  }

  return match[1].replace(/\s+/g, "");
}

function parseExportedSessionData(base64: string): ExportedSessionData {
  const json = Buffer.from(base64, "base64").toString("utf8");
  const data = JSON.parse(json) as ExportedSessionData;

  if (!data || typeof data !== "object") {
    throw new Error("Session data is not a JSON object");
  }
  if (!data.header || typeof data.header !== "object") {
    throw new Error("Session data missing header");
  }
  if (!Array.isArray(data.entries)) {
    throw new Error("Session data missing entries array");
  }

  return data;
}

function jsonlFromExportedSessionData(data: ExportedSessionData): string {
  const lines = [];

  if (data.header) {
    lines.push(JSON.stringify({ type: "header", ...data.header }));
  }

  for (const entry of data.entries ?? []) {
    lines.push(JSON.stringify(entry));
  }

  return `${lines.join("\n")}\n`;
}

function outputPathForHtml(htmlPath: string): string {
  const fileName = basename(htmlPath, extname(htmlPath));
  return join(tmpdir(), `${fileName}.jsonl`);
}

export async function extractPiSessionHtml(
  htmlPath: string,
  outputPath = outputPathForHtml(htmlPath),
): Promise<string> {
  const html = await readFile(htmlPath, "utf8");
  const data = parseExportedSessionData(extractSessionDataBase64(html));
  const jsonl = jsonlFromExportedSessionData(data);

  await mkdir(tmpdir(), { recursive: true });
  await writeFile(outputPath, jsonl, "utf8");
  return outputPath;
}

export default function importHtmlSessionExtension(pi: ExtensionAPI) {
  pi.registerFlag("import", {
    description:
      "Extract a Pi HTML export to /tmp/*.jsonl and open it as --session",
    type: "string",
  });

  let handled = false;
  pi.on("session_start", async (_event, ctx) => {
    if (handled) return;

    const raw = pi.getFlag("import");
    const htmlPath = typeof raw === "string" ? raw.trim() : undefined;
    if (!htmlPath) return;

    handled = true;
    const jsonlPath = await extractPiSessionHtml(htmlPath);

    const sessionManager = ctx.sessionManager as unknown as {
      setSessionFile?: (path: string) => void;
    };
    if (typeof sessionManager.setSessionFile !== "function") {
      throw new Error(
        "Current Pi version does not expose SessionManager.setSessionFile()",
      );
    }

    sessionManager.setSessionFile(jsonlPath);
    ctx.ui.notify(`Imported ${htmlPath} → ${jsonlPath}`, "success");
  });
}
