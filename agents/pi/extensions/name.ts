import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Session name CLI flag.
 *
 * Usage:
 *   pi -e ./agents/pi/extensions/name.ts --name "my session"
 */
export default function sessionNameFlagExtension(pi: ExtensionAPI) {
  pi.registerFlag("name", {
    description: "Set session display name",
    type: "string",
  });

  pi.on("session_start", async () => {
    const raw = pi.getFlag("name");
    const name = typeof raw === "string" ? raw.trim() : undefined;
    if (!name) return;

    pi.setSessionName(name);
  });
}
