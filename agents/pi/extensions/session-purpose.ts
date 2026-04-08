import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

const PURPOSE_TYPE = "session-purpose";
const WIDGET_ID = "00-session-purpose";

interface SessionPurposeEntry {
  purpose: string;
  createdAt: number;
}

// TODO: add purpose to the system prompt

function getSessionPurpose(ctx: ExtensionContext): string | undefined {
  let purpose: string | undefined;

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "custom" || entry.customType !== PURPOSE_TYPE) continue;
    const data = entry.data as SessionPurposeEntry | undefined;
    const value = data?.purpose?.trim();
    if (value) purpose = value;
  }

  return purpose;
}

function applyPurposeUI(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  purpose?: string,
) {
  if (!ctx.hasUI) return;

  if (purpose) {
    const theme = ctx.ui.theme;
    const line =
      theme.fg("dim", "Session purpose: ") + theme.fg("accent", purpose);
    ctx.ui.setWidget(WIDGET_ID, [line]);
    pi.setSessionName(purpose);
  } else {
    ctx.ui.setWidget(WIDGET_ID, undefined);
  }
}

function persistPurpose(pi: ExtensionAPI, purpose: string) {
  pi.appendEntry<SessionPurposeEntry>(PURPOSE_TYPE, {
    purpose,
    createdAt: Date.now(),
  });
  pi.setSessionName(purpose);
}

export default function sessionPurposeExtension(pi: ExtensionAPI) {
  const promptedSessionIds = new Set<string>();

  async function ensurePurpose(ctx: ExtensionContext) {
    const existingPurpose = getSessionPurpose(ctx);
    if (existingPurpose) {
      applyPurposeUI(pi, ctx, existingPurpose);
      return;
    }

    applyPurposeUI(pi, ctx, undefined);

    if (!ctx.hasUI) return;

    const sessionId = ctx.sessionManager.getSessionId();
    if (promptedSessionIds.has(sessionId)) return;
    promptedSessionIds.add(sessionId);

    const input = await ctx.ui.input(
      "Session purpose",
      "What is this session for?",
    );

    const purpose = input?.trim();
    if (!purpose) return;
    if (getSessionPurpose(ctx)) return;

    persistPurpose(pi, purpose);
    applyPurposeUI(pi, ctx, purpose);
  }

  function refreshPurpose(ctx: ExtensionContext) {
    applyPurposeUI(pi, ctx, getSessionPurpose(ctx));
  }

  pi.on("session_start", async (_event, ctx) => {
    void ensurePurpose(ctx);
  });

  pi.on("session_tree", async (_event, ctx) => {
    refreshPurpose(ctx);
  });
}
