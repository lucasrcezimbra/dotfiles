/**
 * Provider status extension
 *
 * Always shows the active provider in the footer status area,
 * even when only one provider is available.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

function updateProviderStatus(ctx: ExtensionContext) {
  const theme = ctx.ui.theme;
  const provider = ctx.model?.provider;

  if (!provider) {
    ctx.ui.setStatus("00-provider", theme.fg("dim", "provider: none"));
    return;
  }

  const text = theme.fg("dim", "provider: ") + theme.fg("accent", provider);

  ctx.ui.setStatus("00-provider", text);
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    updateProviderStatus(ctx);
  });

  pi.on("model_select", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    updateProviderStatus(ctx);
  });

  pi.on("session_switch", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    updateProviderStatus(ctx);
  });
}
