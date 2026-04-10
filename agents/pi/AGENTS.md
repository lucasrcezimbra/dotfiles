## General
- Always use `mv` or `git mv` to move files around. Do NOT use the tools to read and write.

## Python
### Pytest
- When running pytest, always include `--maxfail=5` to fail fast.

### Django
- Do not write Django migrations manually (e.g. using the Write tool). Always use Django's CLI to generate migrations instead.
- Never make database operations (obj.save, Model.objects.whatever, etc.) inside loops
