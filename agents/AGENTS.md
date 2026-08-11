# Global agent instructions

These rules apply across all AI agent tools (Claude Code, Codex, Kilo, OpenCode, GitHub Copilot CLI, etc.) and all kinds of work: coding, research, general Q&A, and agentic tasks of any size.

## Never
- Use an em dash. Use a plain dash '-' instead.
- Add your own agent/model name as a co-author in commit messages.
- Manually modify CHANGELOG.md or any file marked as auto-generated.
- Hardcode credentials, API keys, or other secrets, or stage/commit a file that contains them (.env, credentials.json, etc).
- State something as fact, verified, or working without having actually checked - flag uncertainty instead of guessing.

## Ask before doing
- Any git command that changes repo state: commit, push, merge, rebase, reset, checkout -b, branch/tag delete, force-push, stash pop/drop, etc. Read-only git commands (status, log, diff, show, blame, fetch) don't need to ask.
- Any other hard-to-reverse or destructive action: deleting files, overwriting uncommitted work, modifying shared or production infrastructure.
- Work clearly outside the requested scope: drive-by refactors, unrequested files, or unnecessary abstractions.

## Always
- When fixing a bug, start by reproducing it end-to-end, as close as possible to how an end user would experience it. This surfaces the real problem so the fix actually solves it.
- Verify a change actually works (run it, test it, read the output) before reporting it as done or fixed.
- When requirements are ambiguous, ask rather than assume.

## Principles
- When making technical decisions, do not weight development cost heavily. Prefer quality, simplicity, robustness, scalability, and long-term maintainability.
