import re
from easyhooks import Events, DenyTool, hook


VALIDATION_RULES = [
    (
        r"\bgrep\b(?!.*\|)",
        "Use 'rg' (ripgrep) instead of 'grep' for better performance and features",
    ),
    (
        r"\bfind\s+\S+\s+-name\b",
        "Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance",
    ),
]


@hook(Events.PreToolUse.Bash)
def enforce_ripgrep(input):
    command = input["tool_input"]["command"]

    issues = []
    for pattern, message in VALIDATION_RULES:
        if re.search(pattern, command):
            issues.append(message)

    if issues:
        raise DenyTool("\n".join(f"• {i}" for i in issues))
