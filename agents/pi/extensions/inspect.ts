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
        // TODO: register command /inspect:system to show the current system prompt in the TUI

        // TODO: register a flag using pi.registerFlag("inspect"... to only enable this when the flag is passed
        pi.on("context", async (event, ctx) => {
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
