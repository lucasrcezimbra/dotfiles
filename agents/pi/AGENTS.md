## General
- Do NOT use the tools to edit or read+write to copy and/or move files around. Always use Bash `mv` or `git mv` to move and Bash `cp` to copy files.

## Python
### Pytest
- When running pytest, always include `--maxfail=5` to fail fast.

### Django
- Do not write Django migrations manually (e.g. using the Write tool). Always use Django's CLI to generate migrations instead.
- Never make database operations (obj.save, Model.objects.whatever, etc.) inside loops
