/**
 * Inspect the full prompt being sent to the LLM.
 *
 * - Every turn: saves system prompt + messages to .pi/inspects/turn-N.json
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// TODO: format
export default function (pi: ExtensionAPI) {
        let turnCount = 0;
        // TODO: register command /inspect:on to turn the inspection on even if the flags wasn't passed at startup, and /inspect:off to turn it off again
        // TODO: register command /inspect:system to show the current system prompt in the TUI

        pi.registerFlag("inspect", {
                description: "Save the full prompt context for each turn to .pi/inspects/turn-N.json",
                type: "boolean",
                default: false,
        });

        pi.on("context", async (event, ctx) => {
                if (pi.getFlag("inspect") !== true) return;

                turnCount++;
                const systemPrompt = ctx.getSystemPrompt();
                const inspectDir = join(ctx.cwd, ".pi", "inspects");

                const payload = {
                        turn: turnCount,
                        timestamp: new Date().toISOString(),
                        systemPrompt,
                        messageCount: event.messages.length,
                        messages: event.messages,
                };

                mkdirSync(inspectDir, { recursive: true });
                // TODO: improve the filename by adding the session as prefix (similar to ~/.pi/agent/sessions/*)
                const file = join(inspectDir, `turn-${turnCount}.json`);
                writeFileSync(file, JSON.stringify(payload, null, 2));

                ctx.ui.notify(`Prompt inspect: turn ${turnCount}, ${event.messages.length} messages -> ${file}`, "info");
        });
}
