import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const blockedSubstrings = ["aws", "heroku", "ssh"];

type BashToolInput = {
  command?: unknown;
};

type GuardDecision = "allow-once" | "block" | "allow-substring" | "allow-all";

const decisionLabels: Record<GuardDecision, string> = {
  "allow-once": "Allow this command once",
  block: "Block this command",
  "allow-substring": "Always allow this substring this session",
  "allow-all": "Bypass all command blocks this session",
};

function findBlockedSubstrings(
  command: string,
  allowedSubstrings: Set<string>,
): string[] {
  const normalizedCommand = command.toLowerCase();

  return blockedSubstrings.filter((substring) => {
    const normalizedSubstring = substring.toLowerCase();
    return (
      !allowedSubstrings.has(normalizedSubstring) &&
      normalizedCommand.includes(normalizedSubstring)
    );
  });
}

function formatCommand(command: string): string {
  const maxLength = 4000;
  if (command.length <= maxLength) {
    return command;
  }

  return `${command.slice(0, maxLength)}\n… [truncated ${command.length - maxLength} chars]`;
}

function permissionLabel(matches: string[]): string {
  return `bash permission: ${matches.join(", ")}`;
}

function reportHerdrBlocked(
  pi: ExtensionAPI,
  active: boolean,
  label: string,
): void {
  pi.events.emit("herdr:blocked", { active, label });
}

export default function bashCommandGuard(pi: ExtensionAPI) {
  const allowedSubstrings = new Set<string>();
  let allowAllBlockedCommands = false;

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash" || allowAllBlockedCommands) {
      return undefined;
    }

    const input = event.input as BashToolInput;
    if (typeof input.command !== "string") {
      return undefined;
    }

    const command = input.command;
    let matches = findBlockedSubstrings(command, allowedSubstrings);
    if (matches.length === 0) {
      return undefined;
    }

    if (!ctx.hasUI) {
      return {
        block: true,
        reason: `Blocked bash command containing: ${matches.join(", ")} (no UI available for confirmation)`,
      };
    }

    const label = permissionLabel(matches);
    reportHerdrBlocked(pi, true, label);
    ctx.ui.setStatus("bash-command-guard", "waiting for bash permission");
    ctx.ui.setWorkingMessage("Waiting for bash permission...");

    try {
      while (matches.length > 0) {
        const substring = matches[0];
        const choice = await ctx.ui.select(
          [
            `Bash command contains blocked substring: ${substring}`,
            "",
            formatCommand(command),
            "",
            "What should pi do?",
          ].join("\n"),
          [
            decisionLabels["allow-once"],
            decisionLabels.block,
            `${decisionLabels["allow-substring"]}: ${substring}`,
            decisionLabels["allow-all"],
          ],
        );

        if (choice === decisionLabels["allow-once"]) {
          return undefined;
        }

        if (choice === `${decisionLabels["allow-substring"]}: ${substring}`) {
          allowedSubstrings.add(substring.toLowerCase());
          matches = findBlockedSubstrings(command, allowedSubstrings);
          continue;
        }

        if (choice === decisionLabels["allow-all"]) {
          allowAllBlockedCommands = true;
          return undefined;
        }

        return {
          block: true,
          reason: `Blocked bash command containing: ${substring}`,
        };
      }

      return undefined;
    } finally {
      ctx.ui.setStatus("bash-command-guard", undefined);
      ctx.ui.setWorkingMessage();
      reportHerdrBlocked(pi, false, label);
    }
  });
}
