# GATES — run to review (Blocks A to P)

Written before the run per the unlazy discipline. One observable outcome per
gate. Audit all of them before Block P claims completion.

G1 core-tests-pass
	Core package tests pass on this Mac.
	CHECK: swift test --package-path Packages/Core
	EXPECT: with 0 failures

G2 checklist-complete
	Every box in 05-RUN-TO-REVIEW.md is ticked, or PROGRESS.md has a Skipped section.
	CHECK: bash -c 'open=$(grep -c "^- \[ \]" 05-RUN-TO-REVIEW.md); skipped=$(grep -c "^## Skipped" PROGRESS.md); if [ "$open" -eq 0 ] && [ "$skipped" -ge 1 ]; then echo LIST-COMPLETE; fi'
	EXPECT: LIST-COMPLETE

G3 cloud-build-green
	The ci-logs SUMMARY for the final main commit shows BUILD SUCCEEDED.
	CHECK: bash -c 'git fetch -q origin "+refs/heads/ci-logs:refs/remotes/origin/ci-logs"; sha=$(git rev-parse origin/main); s=$(git show origin/ci-logs:SUMMARY.txt 2>/dev/null); case "$s" in *"commit: $sha"*) grep -q "BUILD SUCCEEDED" <<<"$s" && echo GREEN ;; *) echo STALE ;; esac'
	EXPECT: GREEN

G4 screenshots-or-skipped
	ci-logs holds screenshots/, or PROGRESS.md Skipped covers Block L5.
	CHECK: bash -c 'git fetch -q origin "+refs/heads/ci-logs:refs/remotes/origin/ci-logs"; if git ls-tree --name-only origin/ci-logs screenshots >/dev/null 2>&1; then echo SHOTS; elif grep -q "L5" PROGRESS.md; then echo SKIPPED; fi'
	EXPECT: SHOTS
	(manual override allowed: SKIPPED counts only with a matching Skipped entry)

G5 review-pack-exists
	REVIEW.md exists at the repo root and covers R1 to R16.
	CHECK: bash -c 'n=$(grep -cE "R(1[0-6]|[1-9])" REVIEW.md 2>/dev/null); if [ "${n:-0}" -ge 16 ]; then echo PACK; fi'
	EXPECT: PACK

G6 no-force-decode
	No force unwraps or try! in App, Shared, SharedUI, UsageReport, UsageMonitor.
	CHECK: bash -c 'if grep -rnE "as! |try! " App Shared SharedUI UsageReport UsageMonitor 2>/dev/null; then echo FOUND; else echo CLEAN; fi'
	EXPECT: CLEAN

G7 no-print-in-extensions
	No print( in the two extensions.
	CHECK: bash -c 'if grep -rn "print(" UsageReport UsageMonitor 2>/dev/null; then echo FOUND; else echo CLEAN; fi'
	EXPECT: CLEAN

G8 tree-pushed
	Working tree clean and main pushed.
	CHECK: bash -c 'git diff --quiet && git diff --cached --quiet && [ "$(git rev-parse main)" = "$(git rev-parse origin/main)" ] && echo PUSHED'
	EXPECT: PUSHED
