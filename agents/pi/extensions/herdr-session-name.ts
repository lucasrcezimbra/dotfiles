import { createConnection } from "node:net";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const HERDR_SOURCE = "pi-session-name";

type HerdrPaneInfo = {
  pane?: {
    workspace_id?: string;
  };
};

type HerdrResponse<T> = {
  result?: T;
  error?: {
    message?: string;
  };
};

function normalizeName(name: string | undefined): string | undefined {
  const normalized = name?.replace(/\s+/g, " ").trim();
  return normalized ? normalized : undefined;
}

function herdrSocketPath(): string | undefined {
  if (process.env.HERDR_ENV !== "1") return undefined;
  return process.env.HERDR_SOCKET_PATH || undefined;
}

function sendHerdrRequest<T>(
  method: string,
  params: Record<string, unknown>,
): Promise<T | undefined> {
  const socketPath = herdrSocketPath();
  if (!socketPath) return Promise.resolve(undefined);

  return new Promise((resolve) => {
    let done = false;
    let buffer = "";
    const socket = createConnection(socketPath);
    const timeout = setTimeout(() => finish(), 500);

    function finish(result?: T) {
      if (done) return;
      done = true;
      clearTimeout(timeout);
      socket.destroy();
      resolve(result);
    }

    socket.on("error", () => finish());
    socket.on("end", () => finish());
    socket.on("data", (chunk) => {
      buffer += chunk.toString("utf8");
      const line = buffer.split("\n", 1)[0];
      if (!line) return;

      try {
        const response = JSON.parse(line) as HerdrResponse<T>;
        finish(response.result);
      } catch {
        finish();
      }
    });
    socket.on("connect", () => {
      socket.write(
        `${JSON.stringify({
          id: `${HERDR_SOURCE}:${Date.now()}:${Math.random().toString(36).slice(2)}`,
          method,
          params,
        })}\n`,
      );
    });
    timeout.unref?.();
  });
}

async function currentWorkspaceId(): Promise<string | undefined> {
  const paneId = process.env.HERDR_PANE_ID;
  const paneInfo = paneId
    ? await sendHerdrRequest<HerdrPaneInfo>("pane.get", { pane_id: paneId })
    : await sendHerdrRequest<HerdrPaneInfo>("pane.current", {});

  return paneInfo?.pane?.workspace_id;
}

async function renameCurrentWorkspace(name: string): Promise<boolean> {
  const workspaceId = await currentWorkspaceId();
  if (!workspaceId) return false;

  await sendHerdrRequest("workspace.rename", {
    workspace_id: workspaceId,
    label: name,
  });
  return true;
}

export default function herdrSessionName(pi: ExtensionAPI) {
  let lastSyncedName: string | undefined;
  let pendingName: string | undefined;
  let watcher: ReturnType<typeof setInterval> | undefined;

  function syncName() {
    const name = normalizeName(pi.getSessionName());
    if (!name || name === pendingName || name === lastSyncedName) return;

    pendingName = name;
    void renameCurrentWorkspace(name).then((renamed) => {
      if (renamed) {
        lastSyncedName = name;
      }
      if (pendingName === name) {
        pendingName = undefined;
      }
      if (normalizeName(pi.getSessionName()) !== lastSyncedName) {
        syncName();
      }
    });
  }

  function startWatcher() {
    if (watcher || !herdrSocketPath()) return;
    watcher = setInterval(syncName, 500);
    watcher.unref?.();
  }

  function stopWatcher() {
    if (!watcher) return;
    clearInterval(watcher);
    watcher = undefined;
  }

  pi.on("session_start", () => {
    syncName();
    startWatcher();
  });

  pi.on("session_shutdown", () => {
    stopWatcher();
  });
}
