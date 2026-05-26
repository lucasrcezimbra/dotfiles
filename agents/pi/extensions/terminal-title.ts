import path from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

const ICON_BUSY = "⚙️";
const ICON_IDLE = "💤";

function titleFor(pi: ExtensionAPI, ctx: ExtensionContext, icon?: string) {
  const cwdName = path.basename(ctx.cwd);
  const name = pi.getSessionName();
  const prefix = icon ? `${icon} ` : "";
  return name ? `${prefix}π - ${cwdName} - ${name}` : `${prefix}π - ${cwdName}`;
}

function setTitle(pi: ExtensionAPI, ctx: ExtensionContext, icon?: string) {
  if (!ctx.hasUI) return;
  const title = titleFor(pi, ctx, icon);
  ctx.ui.setTitle(title);
  return title;
}

export default function sessionStatusExtension(pi: ExtensionAPI) {
  let currentIcon: string | undefined;
  let lastTitle: string | undefined;
  let titleWatcher: ReturnType<typeof setInterval> | undefined;

  function syncTitle(ctx: ExtensionContext) {
    const title = titleFor(pi, ctx, currentIcon);
    if (title === lastTitle) return;
    lastTitle = setTitle(pi, ctx, currentIcon);
  }

  function startTitleWatcher(ctx: ExtensionContext) {
    if (!ctx.hasUI || titleWatcher) return;
    titleWatcher = setInterval(() => {
      syncTitle(ctx);
    }, 250);
  }

  function stopTitleWatcher() {
    if (!titleWatcher) return;
    clearInterval(titleWatcher);
    titleWatcher = undefined;
  }

  pi.on("session_start", async (_event, ctx) => {
    currentIcon = undefined;
    lastTitle = setTitle(pi, ctx, currentIcon);
    startTitleWatcher(ctx);
  });

  pi.on("agent_start", async (_event, ctx) => {
    currentIcon = ICON_BUSY;
    lastTitle = setTitle(pi, ctx, currentIcon);
  });

  pi.on("agent_end", async (_event, ctx) => {
    currentIcon = ICON_IDLE;
    lastTitle = setTitle(pi, ctx, currentIcon);
  });

  pi.on("session_shutdown", async () => {
    stopTitleWatcher();
  });
}
