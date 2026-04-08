import path from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

const ICON_BUSY = "⚙️";
const ICON_IDLE = "💤";

function setTitle(pi: ExtensionAPI, ctx: ExtensionContext, icon?: string) {
  if (!ctx.hasUI) return;
  const cwdName = path.basename(ctx.cwd);
  const purpose = pi.getSessionName();
  const prefix = icon ? `${icon} ` : "";
  const title = purpose
    ? `${prefix}π - ${cwdName} - ${purpose}`
    : `${prefix}π - ${cwdName}`;
  ctx.ui.setTitle(title);
}

export default function sessionStatusExtension(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    setTitle(pi, ctx);
  });

  pi.on("agent_start", async (_event, ctx) => {
    setTitle(pi, ctx, ICON_BUSY);
  });

  pi.on("agent_end", async (_event, ctx) => {
    setTitle(pi, ctx, ICON_IDLE);
  });
}
