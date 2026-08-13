import { randomUUID } from "node:crypto";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

type Mode = "fire" | "boomerang";

type RpcReply =
  | { success: true; data: { details?: { runId?: string; asyncId?: string } } }
  | { success: false; error: { message: string } };

type FireState = {
  runId?: unknown;
  mode?: unknown;
  tag?: unknown;
  completed?: unknown;
};

const RPC_VERSION = 1;
const RPC_REQUEST_EVENT = "subagents:rpc:v1:request";
const RPC_REPLY_PREFIX = "subagents:rpc:v1:reply:";
const COMPLETED_EVENT = "subagent:async-complete";
const STATE_ENTRY = "fire-boomerang";

function spawnRunner(
  pi: ExtensionAPI,
  task: string,
  fireTag?: string,
): Promise<string> {
  const requestId = randomUUID();
  const replyEvent = `${RPC_REPLY_PREFIX}${requestId}`;

  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      unsubscribe?.();
      reject(new Error("pi-subagents did not answer the spawn request."));
    }, 10_000);

    const unsubscribe = pi.events.on(replyEvent, (value: unknown) => {
      clearTimeout(timeout);
      unsubscribe?.();

      const reply = value as RpcReply;
      if (!reply.success) {
        reject(new Error(reply.error.message));
        return;
      }

      const runId = reply.data.details?.runId ?? reply.data.details?.asyncId;
      if (!runId) {
        reject(
          new Error(
            "pi-subagents started the task without returning a run ID.",
          ),
        );
        return;
      }

      resolve(runId);
    });

    pi.events.emit(RPC_REQUEST_EVENT, {
      version: RPC_VERSION,
      requestId,
      method: "spawn",
      source: { extension: "fire-boomerang" },
      params: {
        agent: "runner",
        task: fireTag
          ? `${task}\n\nWhen you finish, begin the final response with ${fireTag}.`
          : task,
        context: "fork",
        async: true,
      },
    });
  });
}

function restoreFires(ctx: ExtensionContext): Map<string, string> {
  const pending = new Map<string, string>();

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "custom" || entry.customType !== STATE_ENTRY) continue;

    const state = entry.data as FireState | undefined;
    if (
      typeof state?.runId !== "string" ||
      typeof state.tag !== "string" ||
      state.mode !== "fire"
    )
      continue;
    if (state.completed === true) pending.delete(state.runId);
    else pending.set(state.runId, state.tag);
  }

  return pending;
}

function completedRunId(value: unknown): string | undefined {
  if (!value || typeof value !== "object") return undefined;
  const result = value as { runId?: unknown; id?: unknown };
  return typeof result.runId === "string"
    ? result.runId
    : typeof result.id === "string"
      ? result.id
      : undefined;
}

export default function fireBoomerangExtension(pi: ExtensionAPI) {
  let fires = new Map<string, string>();

  // pi-subagents has no per-run completion-notification setting. Fire results
  // carry an unguessable tag, so only their own notifications are suppressed.
  type SendMessage = ExtensionAPI["sendMessage"];
  const mutablePi = pi as unknown as { sendMessage: SendMessage };
  const sendMessage = pi.sendMessage.bind(pi) as SendMessage;
  const interceptedSendMessage = ((...args: Parameters<SendMessage>) => {
    const [message] = args;
    const customType = (message as { customType?: unknown }).customType;
    const content = (message as { content?: unknown }).content;

    if (
      customType === "subagent-notify" &&
      typeof content === "string" &&
      !content.startsWith("Background tasks completed (")
    ) {
      for (const [runId, tag] of fires) {
        if (!content.includes(tag)) continue;
        fires.delete(runId);
        return;
      }
    }

    return sendMessage(...args);
  }) as SendMessage;
  mutablePi.sendMessage = interceptedSendMessage;

  pi.on("session_start", (_event, ctx) => {
    fires = restoreFires(ctx);
  });

  const unsubscribe = pi.events.on(COMPLETED_EVENT, (result: unknown) => {
    const runId = completedRunId(result);
    const tag = runId ? fires.get(runId) : undefined;
    if (!runId || !tag) return;

    pi.appendEntry(STATE_ENTRY, { runId, mode: "fire", tag, completed: true });
  });

  pi.on("session_shutdown", () => {
    unsubscribe?.();
    if (mutablePi.sendMessage === interceptedSendMessage) {
      mutablePi.sendMessage = sendMessage;
    }
  });

  function registerCommand(name: Mode) {
    pi.registerCommand(name, {
      description:
        name === "fire"
          ? "Start runner in the background without waiting for its result"
          : "Start runner in the background and return its result to the conversation",
      handler: async (args, ctx) => {
        const task = args.trim();
        if (!task) {
          ctx.ui.notify(`Usage: /${name} <task>`, "warning");
          return;
        }
        if (!ctx.isIdle()) {
          ctx.ui.notify(
            `/${name} requires the current turn to finish so runner receives the complete context.`,
            "warning",
          );
          return;
        }

        try {
          const fireTag =
            name === "fire" ? `[[fire:${randomUUID()}]]` : undefined;
          const runId = await spawnRunner(pi, task, fireTag);

          if (fireTag) {
            fires.set(runId, fireTag);
            pi.appendEntry(STATE_ENTRY, {
              runId,
              mode: name,
              tag: fireTag,
              completed: false,
            });
          }

          ctx.ui.notify(
            `${name === "fire" ? "Fired" : "Boomerang launched"}: runner [${runId}]`,
            "info",
          );
        } catch (error) {
          ctx.ui.notify(
            error instanceof Error ? error.message : String(error),
            "error",
          );
        }
      },
    });
  }

  registerCommand("fire");
  registerCommand("boomerang");
}
