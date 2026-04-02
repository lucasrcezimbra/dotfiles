---
name: oss-contrib
---

My GitHub user: `lucasrcezimbra`

- Use gh (GitHub CLI)

0. Check if the repo has guidelines for contributions (e.g. `CONTRIBUTING.md`, `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md`, etc.) and follow them.
1. Check if you are in my fork. If yes, continue; if not, fork it.
2. Stage Changes: Run `git add` for the files that have been changed in the current session. Do NOT include files of other changes.
3. Branch: Create a new branch based on the changes being contributed.
4. Commit: Create a commit.
  * Analyze the changes to draft a clear commit message.
  * NEVER use `git commit --amend`.
6. Open a draft PR `gh pr create --draft --title "<title>"`
  * If the repo has a `.github/pull_request_template.md`, use it as the body.
