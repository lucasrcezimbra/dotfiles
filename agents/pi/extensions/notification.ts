import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Markdown, type MarkdownTheme } from "@mariozechner/pi-tui";

const plainTheme: MarkdownTheme = {
  heading: (t) => t,
  link: (t) => t,
  linkUrl: (t) => t,
  code: (t) => t,
  codeBlock: (t) => t,
  codeBlockBorder: (t) => t,
  quote: (t) => t,
  quoteBorder: (t) => t,
  hr: (t) => t,
  listBullet: (t) => t,
  bold: (t) => t,
  italic: (t) => t,
  strikethrough: (t) => t,
  underline: (t) => t,
};

function stripMarkdown(text: string): string {
  const md = new Markdown(text, 0, 0, plainTheme);
  return md.render(1000).join(" ").trim();
}

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async (event) => {
    const assistantMessages = event.messages.filter(
      (m) => m.role === "assistant",
    );
    const last = assistantMessages.at(-1);
    if (!last || last.role !== "assistant") return;

    const textParts = last.content
      .filter((c): c is { type: "text"; text: string } => c.type === "text")
      .map((c) => c.text);
    if (textParts.length === 0) return;

    const raw = textParts.join("\n");
    const plain = stripMarkdown(raw);
    const body = plain.length > 150 ? plain.slice(0, 150) + "…" : plain;

    process.stdout.write(`\x1b]777;notify;π;${body}\x07`);
  });
}
