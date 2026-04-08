---
description: Statically review a pi extension and inventory every behavior change it introduces vs plain pi defaults
---

Review the pi extension at: $@

If no target path was provided, ask for the extension path and stop.

Interpret the input path/value like this:
- If the input is a GitHub repository URL or git URL, clone it into `/tmp/` and review the extension from the cloned copy.
- If the input is a local file path, inspect that file.
- If the input is a local directory path, read that directory and inspect the extension files inside it.
- If the input is ambiguous, state the ambiguity briefly and choose the narrowest reasonable extension scope.

Your job is not to give a generic code review. Your job is to produce an exhaustive static inventory of every behavior change introduced by the extension relative to plain pi defaults.

Scope:
- Perform static detection only.
- Inspect only the target extension code.
- If the target is a directory, inspect files inside that extension directory.
- Follow local imports inside that extension only when needed to understand behavior.
- You may inspect config or resource files inside the same extension directory only if the extension code directly reads or uses them.
- Do not inspect unrelated project code, repo docs, AGENTS.md, SYSTEM.md, settings.json, packages, prompts, or skills outside the extension unless the extension code directly references them and they are part of the extension's own behavior.
- Do not modify files, except cloning a remote repository into `/tmp/` when the input is a GitHub or git URL.

Baseline:
- Compare against plain pi defaults.
- Do not compare against current project behavior.
- Do not assume project-local settings are part of the extension unless the extension code itself loads them.

Find every behavior change you can statically detect, including but not limited to:
- system prompt changes
- available tool changes
- active tool set changes
- built-in tool overrides
- tool-call interception or argument mutation
- tool-result interception or mutation
- skills, prompt templates, or themes exposed through resource discovery
- CLI flags
- slash commands
- keyboard shortcuts
- input rewriting
- message injection or follow-up/steering behavior
- model/provider/thinking changes
- context changes before model calls
- provider payload changes
- session lifecycle changes
- compaction, tree, fork, resume, or shutdown behavior changes
- user bash handling changes
- header, footer, widget, status, editor, or overlay UI changes
- any other user-visible or agent-visible behavior difference from plain pi

Pay special attention to these pi extension mechanisms:
- pi.registerTool(...)
- pi.setActiveTools(...)
- pi.registerCommand(...)
- pi.registerShortcut(...)
- pi.registerFlag(...)
- pi.sendMessage(...)
- pi.sendUserMessage(...)
- pi.setModel(...)
- pi.setThinkingLevel(...)
- pi.registerProvider(...)
- pi.unregisterProvider(...)
- pi.on("before_agent_start")
- pi.on("input")
- pi.on("context")
- pi.on("before_provider_request")
- pi.on("tool_call")
- pi.on("tool_result")
- pi.on("user_bash")
- pi.on("resources_discover")
- pi.on("session_start")
- pi.on("session_before_switch")
- pi.on("session_before_fork")
- pi.on("session_before_compact")
- pi.on("session_before_tree")
- pi.on("session_shutdown")
- extension code that reads local files or config to alter behavior

Output requirements:
- Use categorized sections.
- Show only categories where changes were found.
- Within each category, list every distinct change as a numbered item.
- Do not merge unrelated changes into one item.
- If a change is dynamic or conditional, state the condition explicitly.
- Prefer precise evidence over speculation.
- If a capability is merely registered but not automatically activated, say so clearly.

For each item, use exactly this structure:

1. Change: ...
   - Mechanism: ...
   - Evidence: <file path and relevant hook/API/symbol>
   - Trigger: always | startup | per prompt | per tool call | command | shortcut | flag | conditional:<condition>
   - Effect vs plain pi: ...
   - How to find: explain how a human can locate this in the extension code
   - Confidence: confirmed | likely

Use these category names when applicable:

## System prompt changes
## Tool changes
## Resource discovery changes (skills, prompt templates, themes)
## Flag changes
## Command and shortcut changes
## Input and message flow changes
## Tool execution behavior changes
## Model/provider/thinking/context changes
## Session/compaction/tree/shutdown changes
## UI/runtime behavior changes
## Other behavior changes

Important:
- Compare against plain pi defaults only.
- Focus on extension-introduced behavior.
- Do not include empty categories.
- Do not end with a generic summary paragraph; the categorized inventory is the final output.
