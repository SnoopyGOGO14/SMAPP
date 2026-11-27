# Ponytail — adoption record (Part 1.1)

**Decision: the ruleset path is in use; no lifecycle hooks are installed.**

Evidence:

- The harness here is OpenCode. Ponytail's own install instructions
  for OpenCode are "install `skills/ponytail/SKILL.md` as a skill" —
  the instruction-only route.
- The local install is exactly that:
  `~/.config/opencode/skills/ponytail/` contains **one file,
  `SKILL.md`** — the ruleset text. No scripts, no Node hooks, no
  package.json, nothing that runs at agent start. Verified by listing
  the directory this session.
- The upstream repo's `hooks/` and lifecycle machinery target Claude
  Code and Codex, not this harness. None of it is present locally, so
  there is no hook to read beyond rule injection — the task list's
  caution is satisfied by construction.

What is now in force (from `SKILL.md`): the ladder — *does it need to
exist → already in this codebase → standard library → native Apple API
→ existing dependency → one line → the minimum* — applied before every
change, with the chosen rung recorded in the commit message; one small
test for new non-trivial logic; `shortcut:` comments for known limits;
never cut validation, error handling, security, accessibility.

Part 1.2 compliance: every commit from here carries its ladder rung.
