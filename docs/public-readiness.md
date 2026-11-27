# Public readiness — can the repo be made public?

Scanned 27 November 2026: the full history (`git log -p --all`), every
committed file, the author metadata, and the `ci-logs` branch's logs.

## Secrets: none found

- `zai.rtf` (the credential note): **never committed** — gitignored
  from day one; `git log --all -- zai.rtf` is empty.
- Key/token patterns across every added line in history
  (`sk-`, `BEGIN PRIVATE`, api_key/secret/password/token assignments):
  one hit, the string constant `"detailToken"` — an App Group key
  name, not a credential.
- The workflows' tokens: `${{ secrets.GITHUB_TOKEN }}` references only
  (never the value); the `ci-logs` logs contain runner paths and no
  token material (pattern scan: zero hits).

## Personal details: three, all mild

| What | Where | Risk | Fix |
| --- | --- | --- | --- |
| Author name "Larry MACBOOK PRO i7" and emails `larrysmacbookproi7@…lan/.local` | 52 commits' metadata | Mild (machine username + local hostnames — not an internet address) | Future commits: set git user to a GitHub noreply address. History rewrite only with instruction; not required for safety |
| `Larry <larryfield@me.com>` | one commit's author (the initial import) | Mild (a personal email in metadata) | Same as above |
| `/Users/larrysmacbookproi7/…` and `com.larryfield` | two documentation lines (the start-here table; a portal example) | Trivial (a local path; a suggested bundle-ID example) | Replaceable now if wanted — both are documentation, not credentials |

## What going public exposes

The full source, the design documents, the research, and the honesty
records (PROGRESS/REVIEW). The screenshots on `ci-logs` are simulator
demo captures — sample figures, no personal data. No customer data
exists anywhere (nothing has run on a device).

## Licence

`DECISIONS.md` row added: default **all rights reserved, no LICENCE
file** — anyone may view (a public repo without a licence grants no
reuse rights).

## Verdict

**SAFE TO MAKE PUBLIC.** No secrets anywhere in history; the only
personal traces are commit-author metadata and two documentation
lines, neither of which needs fixing first. GitHub's default branch
protection stays as is; if the owner wants the metadata cleaned too,
that is a separate, history-rewriting task (instruction required).
