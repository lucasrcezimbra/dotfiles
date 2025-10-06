from easyhooks import Events, DenyTool, hook


@hook(Events.PreToolUse.Bash)
def block_commit_no_verify(input):
    cmd = input["tool_input"]["command"]

    if 'git' in cmd and 'commit' in cmd and '--no-verify' in cmd:
        raise DenyTool("Blocking 'git commit --no-verify' to enforce commit hooks.")
