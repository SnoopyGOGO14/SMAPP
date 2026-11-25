#!/bin/bash
# first-run.sh — day one on the build Mac (09-AUDIT-AND-NEXT.md B6).
# Verifies the toolchain, generates the project, tests and builds.
# Exit non-zero on any failure; every step prints what it did.

set -u
cd "$(dirname "$0")/.."
step() { echo; echo "=== $* ==="; }
FAILED=0
fail() { echo "FAIL: $*"; FAILED=1; }

step "1. Xcode version (need 15+ to develop; 26+ to ship)"
if ! command -v xcodebuild >/dev/null; then
    fail "xcodebuild not found — install Xcode first"
else
    xcodebuild -version
    MAJOR=$(xcodebuild -version | head -1 | grep -oE '[0-9]+\.' | head -1 | tr -d .)
    if [ "${MAJOR:-0}" -lt 15 ]; then
        fail "Xcode $MAJOR is too old for the 17.4 deployment target"
    fi
fi

step "2. XcodeGen (installs via Homebrew if absent)"
if ! command -v xcodegen >/dev/null; then
    if command -v brew >/dev/null; then
        brew install xcodegen || fail "brew install xcodegen failed"
    else
        fail "xcodegen missing and Homebrew not found — see xcodegen install docs"
    fi
fi
command -v xcodegen >/dev/null && xcodegen --version

step "3. Generate the Xcode project"
xcodegen generate || fail "xcodegen generate failed"

step "4. Core tests (90 expected)"
swift test --package-path Packages/Core || fail "Core tests failed"

step "5. Build the app for the simulator"
if xcodebuild build -project SocialTimeMonitor.xcodeproj -scheme SocialTimeMonitor \
    -destination 'generic/platform=iOS Simulator' \
    CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO; then
    echo "BUILD SUCCEEDED"
else
    fail "simulator build failed"
fi

step "6. What you do next (manual)"
cat <<'EOF'
  a. Open SocialTimeMonitor.xcodeproj in Xcode.
  b. Set the signing team on the SocialTimeMonitor target (and the two
     extension targets inherit it). Replace YOURORG in project.yml, the
     three .entitlements files and Config/ once the organisation ID
     exists — then re-run `xcodegen generate`.
  c. Plug in the iPhone; select it as the run destination; Run.
  d. On the phone: allow Screen Time access, tick Social + YouTube,
     set a 1-hour target.
  e. Follow docs/gate-a-card.md (one sitting, about an hour) and tick
     results into docs/device-checks.md.
EOF

echo
if [ "$FAILED" -eq 0 ]; then
    echo "FIRST-RUN OK"
    exit 0
else
    echo "FIRST-RUN FAILED"
    exit 1
fi
