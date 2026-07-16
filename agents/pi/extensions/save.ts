import { mkdir, readFile, writeFile } from "node:fs/promises";
import { basename, dirname, join } from "node:path";
import type { ExtensionAPI, SessionEntry } from "@mariozechner/pi-coding-agent";
import { DynamicBorder, getAgentDir } from "@mariozechner/pi-coding-agent";
import {
  Container,
  Key,
  matchesKey,
  type SelectItem,
  SelectList,
  Text,
} from "@mariozechner/pi-tui";

const SAVE_FILE = join(getAgentDir(), "saved-sessions.json");

interface SavedSession {
  id: string;
  name: string;
  path: string;
  cwd: string;
  savedAt: string;
}

interface SaveStore {
  sessions: SavedSession[];
}

function nowId(date = new Date()): string {
  return `${date.toISOString()}-${Math.random().toString(16).slice(2, 10)}`;
}

function textFromContent(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";

  return content
    .filter((block): block is { type: string; text: string } => {
      return (
        typeof block === "object" &&
        block !== null &&
        (block as { type?: unknown }).type === "text" &&
        typeof (block as { text?: unknown }).text === "string"
      );
    })
    .map((block) => block.text)
    .join(" ");
}

function firstUserMessage(entries: SessionEntry[]): string | undefined {
  for (const entry of entries) {
    if (entry.type !== "message") continue;
    if (entry.message.role !== "user") continue;

    const text = textFromContent(entry.message.content).trim();
    if (text) return text;
  }
}

function defaultName(
  entries: SessionEntry[],
  sessionFile: string,
  date = new Date(),
): string {
  const firstMessage = firstUserMessage(entries);
  if (firstMessage) return firstMessage.slice(0, 80);

  return `${basename(sessionFile)} ${date.toLocaleString()}`;
}

function parseStore(raw: string): SaveStore {
  const parsed = JSON.parse(raw) as Partial<SaveStore>;
  return { sessions: Array.isArray(parsed.sessions) ? parsed.sessions : [] };
}

async function loadStore(saveFile = SAVE_FILE): Promise<SaveStore> {
  try {
    return parseStore(await readFile(saveFile, "utf8"));
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT")
      return { sessions: [] };
    throw error;
  }
}

async function saveStore(
  store: SaveStore,
  saveFile = SAVE_FILE,
): Promise<void> {
  await mkdir(dirname(saveFile), { recursive: true });
  await writeFile(saveFile, `${JSON.stringify(store, null, 2)}\n`);
}

function saveCurrentSession(
  store: SaveStore,
  savedSession: SavedSession,
): SaveStore {
  return {
    sessions: [
      savedSession,
      ...store.sessions.filter((session) => session.path !== savedSession.path),
    ],
  };
}

function removeSavedSession(store: SaveStore, id: string): SaveStore {
  return { sessions: store.sessions.filter((session) => session.id !== id) };
}

function sessionLabel(session: SavedSession): string {
  const savedAt = new Date(session.savedAt)
    .toISOString()
    .slice(0, 16)
    .replace("T", " ");
  return `${savedAt}  ${session.name}`;
}

function sessionDescription(session: SavedSession): string {
  return `${session.cwd} • ${session.path}`;
}

function selectTheme(theme: any) {
  return {
    selectedPrefix: (text: string) => theme.fg("accent", text),
    selectedText: (text: string) => theme.fg("accent", text),
    description: (text: string) => theme.fg("muted", text),
    scrollInfo: (text: string) => theme.fg("dim", text),
    noMatch: (text: string) => theme.fg("warning", text),
  };
}

async function showSavedSessions(ctx: any): Promise<SavedSession | undefined> {
  let store = await loadStore();
  let items: SelectItem[] = store.sessions.map((session) => ({
    value: session.id,
    label: sessionLabel(session),
    description: sessionDescription(session),
  }));

  if (items.length === 0) {
    ctx.ui.notify("No saved sessions", "info");
    return;
  }

  const selectedId = await ctx.ui.custom<string | undefined>(
    (tui: any, theme: any, keybindings: any, done: any) => {
      void keybindings;
      let selectList: SelectList;

      function buildContainer(): Container {
        const container = new Container();
        container.addChild(
          new DynamicBorder((text: string) => theme.fg("accent", text)),
        );
        container.addChild(
          new Text(theme.fg("accent", theme.bold("Saved Sessions")), 1, 0),
        );

        selectList = new SelectList(
          items,
          Math.min(items.length, 15),
          selectTheme(theme),
          {
            minPrimaryColumnWidth: 32,
            maxPrimaryColumnWidth: 50,
          },
        );
        selectList.onSelect = (item) => done(item.value);
        selectList.onCancel = () => done(undefined);
        container.addChild(selectList);
        container.addChild(
          new Text(
            theme.fg(
              "dim",
              "↑↓ navigate • enter open • ctrl+d remove from list • esc cancel",
            ),
            1,
            0,
          ),
        );
        container.addChild(
          new DynamicBorder((text: string) => theme.fg("accent", text)),
        );

        return container;
      }

      let container = buildContainer();

      async function removeSelected() {
        const item = selectList.getSelectedItem();
        if (!item) return;
        const session = store.sessions.find(
          (savedSession) => savedSession.id === item.value,
        );
        if (!session) return;

        const ok = await ctx.ui.confirm("Remove saved session?", session.name);
        if (!ok) return;

        store = removeSavedSession(store, session.id);
        await saveStore(store);
        items = store.sessions.map((savedSession) => ({
          value: savedSession.id,
          label: sessionLabel(savedSession),
          description: sessionDescription(savedSession),
        }));

        if (items.length === 0) {
          done(undefined);
          return;
        }

        container = buildContainer();
        tui.requestRender();
      }

      return {
        render(width: number) {
          return container.render(width);
        },
        invalidate() {
          container.invalidate();
        },
        handleInput(data: string) {
          if (matchesKey(data, Key.ctrl("d"))) {
            void removeSelected();
            return;
          }
          selectList.handleInput(data);
          tui.requestRender();
        },
      };
    },
    { overlay: true },
  );

  if (!selectedId) return;
  return store.sessions.find((session) => session.id === selectedId);
}

export default function saveExtension(pi: ExtensionAPI) {
  pi.registerCommand("save", {
    description: "Save current session to /save:list",
    handler: async (args, ctx) => {
      const sessionFile = ctx.sessionManager.getSessionFile();
      if (!sessionFile) {
        ctx.ui.notify("Current session is not persisted", "error");
        return;
      }

      const store = await loadStore();
      const name =
        args.trim() ||
        pi.getSessionName() ||
        defaultName(ctx.sessionManager.getBranch(), sessionFile);
      const savedSession: SavedSession = {
        id: nowId(),
        name,
        path: sessionFile,
        cwd: ctx.cwd,
        savedAt: new Date().toISOString(),
      };

      await saveStore(saveCurrentSession(store, savedSession));
      ctx.ui.notify(`Saved session: ${name}`, "success");
    },
  });

  pi.registerCommand("save:list", {
    description: "List saved sessions",
    handler: async (args, ctx) => {
      void args;
      const selected = await showSavedSessions(ctx);
      if (!selected) return;

      const result = await ctx.switchSession(selected.path);
      if (result.cancelled) {
        ctx.ui.notify("Switch cancelled", "info");
      }
    },
  });
}
