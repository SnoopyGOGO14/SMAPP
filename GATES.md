# GATES — run to review (Blocks A to P)

Written before the run per the unlazy discipline. One observable outcome per
gate. Audit all of them before Block P claims completion.

## Run of 25 November (09-AUDIT-AND-NEXT.md)

G9 preflight-passes
	tools/preflight.sh exits zero on main.
	CHECK: bash tools/preflight.sh
	EXPECT: PREFLIGHT OK
G10 probe-verdict-recorded
	T0's outcome (cloud answered or silent, with time) is recorded in PROGRESS.md, and Track A or Track B was followed accordingly.
	CHECK: grep -q "T0" PROGRESS.md && grep -qE "answered|silent" PROGRESS.md
	EXPECT: (exit 0)
G11 unbuilt-review-complete
	Every Swift file changed since 337203d appears in docs/unbuilt-review.md.
	CHECK: bash -c 'missing=0; for f in $(git diff --name-only 337203d HEAD -- "*.swift"); do grep -q "$f" docs/unbuilt-review.md || missing=1; done; [ $missing -eq 0 ] && echo COVERED'
	EXPECT: COVERED
G12 review-honest
	REVIEW.md contains no "screenshot" level for R5, R11, R15; R16 describes Summary; a dated audit section exists.
	CHECK: bash -c 'level=$(grep -A2 "R5\b\|R11\b\|R15\b" REVIEW.md | grep -c screenshot); [ "$level" -eq 0 ] && grep -q "Summary" REVIEW.md && grep -q "Audit of 25 November" REVIEW.md && echo HONEST'
	EXPECT: HONEST
G13 tracka-or-silent
	Either ci-logs shows BUILD SUCCEEDED for a current commit, or PROGRESS.md top says the cloud is silent and since when.
	CHECK: bash -c 'git fetch -q origin "+refs/heads/ci-logs:refs/remotes/origin/ci-logs"; sha=$(git rev-parse HEAD); if git show origin/ci-logs:SUMMARY.txt 2>/dev/null | grep "commit: $sha" | grep -q "BUILD SUCCEEDED"; then echo GREEN; elif head -30 PROGRESS.md | grep -q "silent"; then echo SILENT-LOGGED; fi'
	EXPECT: GREEN
	(or SILENT-LOGGED; manual override allowed with a matching Skipped entry)
G14 close-complete
	Part 4 done: handoff updated, tree clean, main pushed.
	CHECK: bash -c 'git diff --quiet && git diff --cached --quiet && [ "$(git rev-parse main)" = "$(git rev-parse origin/main)" ] && grep -q "25 November" SESSION-HANDOFF.md && echo CLOSED'
	EXPECT: CLOSED

## Run of 18 November (historical)

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
