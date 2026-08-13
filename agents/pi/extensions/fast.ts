import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

const ENTRY_TYPE = "fast-mode";

function setStatus(ctx: ExtensionContext, enabled: boolean) {
  ctx.ui.setStatus("fast-mode", enabled ? "FAST" : undefined);
}

export default function (pi: ExtensionAPI) {
  let enabled = false;

  pi.on("session_start", (_event, ctx) => {
    enabled = false;

    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type === "custom" && entry.customType === ENTRY_TYPE) {
        const data = entry.data as { enabled?: unknown } | undefined;
        if (typeof data?.enabled === "boolean") enabled = data.enabled;
      }
    }

    setStatus(ctx, enabled);
  });

  pi.registerCommand("fast", {
    description: "Toggle OpenAI Codex Fast mode for this session",
    handler: async (_args, ctx) => {
      enabled = !enabled;
      pi.appendEntry(ENTRY_TYPE, { enabled });
      setStatus(ctx, enabled);
      ctx.ui.notify(
        `Codex Fast mode ${enabled ? "enabled" : "disabled"}.`,
        "info",
      );
    },
  });

  pi.on("before_provider_request", (event, ctx) => {
    if (!enabled || ctx.model?.provider !== "openai-codex") return;
    return { ...(event.payload as object), service_tier: "priority" };
  });
}
