/**
 * Read-Only Mode Extension
 *
 * Registers a `--read-only` CLI flag. When passed, restricts available tools
 * to read-only operations: read, grep, find, ls.
 *
 * Usage:
 *   pi --read-only
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function readOnlyExtension(pi: ExtensionAPI) {
  pi.registerFlag("read-only", {
    description:
      "Restrict tools to read-only operations (read, grep, find, ls)",
    type: "boolean",
    default: false,
  });

  pi.on("session_start", async (_event, ctx) => {
    if (pi.getFlag("read-only") === true) {
      pi.setActiveTools(["read", "grep", "find", "ls"]);
      ctx.ui.notify("Read-only mode enabled", "info");
      ctx.ui.setStatus("read-only", ctx.ui.theme.fg("warning", "READ-ONLY"));
    }
  });
}
