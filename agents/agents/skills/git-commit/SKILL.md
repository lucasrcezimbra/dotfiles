---
name: git-commit
description: git add and commit
---
You need to stage and commit the current changes. Follow these steps carefully:

1.  **Analyze Commit History:** Run `git log --oneline -n 10` to understand recent commit message patterns. Follow the same style for the new commit message.
2.  **Review Changes:** Run `git status` and `git diff` to understand what files have been modified.
3.  **Stage Changes:** Run `git add` for the files that have been changed.
4.  **Commit:** Create a commit.
    *   Analyze the changes to draft a clear, concise commit message.
    *   If the user provided specific instructions in User input, incorporate them into the commit message.
    *   Follow recent commit message patterns from history.
    *   Follow conventional commit style when appropriate (e.g., `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
    *   NEVER use `git commit --amend`.
