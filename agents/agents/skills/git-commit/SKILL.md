---
name: git-commit
description: git add and commit
---
You need to stage and commit the current changes. Follow these steps carefully:

1.  **Review Changes:** Run `git status` and `git diff` to understand what files have been modified.
2.  **Stage Changes:** Run `git add` for the files that have been changed.
3.  **Commit:** Create a commit.
    *   Analyze the changes to draft a clear, concise commit message.
    *   If the user provided specific instructions in User input, incorporate them into the commit message.
    *   Follow conventional commit style when appropriate (e.g., `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
    *   NEVER use `git commit --amend`.
