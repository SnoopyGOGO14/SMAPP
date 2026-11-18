# The cloud build loop

The 2016 build Mac cannot run Xcode, so every compile happens on GitHub's
hosted Macs. This page explains how the loop works and how to read results.

## How it works

- **`.github/workflows/build.yml`** runs on every push to `main` (unless the
  push touches only Markdown, `docs/`, `design/`, `archive/` or
  `Packages/Core` — those commits carry `[skip ci]`).
- On a `macos-26` runner it: installs XcodeGen, runs the Core package tests,
  generates the Xcode project, and builds all three targets for the iOS
  Simulator with signing disabled.
- Whatever happens, the logs are pushed to the **`ci-logs`** branch:
  - `SUMMARY.txt` — errors, warnings, test counts and the commit it belongs to
  - full logs for each step

## Reading results

- **Browser:** the repo's Actions tab shows each run end to end.
- **Command line:**
  ```bash
  git fetch origin ci-logs
  git show origin/ci-logs:SUMMARY.txt
  ```
  Always check the `commit:` line matches the commit you care about — the
  branch is force-pushed and holds only the latest run.

## Screenshots

- **`.github/workflows/screens.yml`** runs only when the head commit message
  contains `[screens]` (or via manual dispatch). It builds the app, boots a
  simulator, and captures Home, App detail, All apps, Target and Onboarding
  in light and dark appearance using demo mode. PNGs land in
  `screenshots/` on the `ci-logs` branch.

## Budget

- Private repos: macOS runners consume included minutes at 10× the Linux
  rate — the free 2,000 minutes ≈ 200 macOS minutes per month. The overnight
  run (18 November) was capped at 25 build runs + 3 screenshot runs; each
  build takes roughly 3–5 minutes of macOS time.
- **A public repo has no Actions minutes limit.** If the repo is made public,
  tell GLM the cap no longer applies.
