from easyhooks import Events, DenyTool, hook


@hook(Events.PreToolUse.Bash)
def block_commit_no_verify(input):
    cmd = input["tool_input"]["command"]

    if cmd.startswith('cd'):
        raise DenyTool("Use '\\cd' to avoid zoxide alias")
