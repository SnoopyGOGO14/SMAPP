#!/bin/bash
# apply-org.sh (Part 4.3) — replaces the placeholder organisation id in
# one pass from a single value: Config/org.txt (or the ORG_ID
# environment variable). Rung 2: reuse sed; nothing new to install.
# Run before `xcodegen generate` whenever org.txt changes.
set -u
cd "$(dirname "$0")/.."

ORG="${ORG_ID:-$(head -1 Config/org.txt | tr -d '[:space:]')}"
if [ -z "$ORG" ] || [ "$ORG" = "YOURORG" ]; then
    echo "org is still the placeholder (Config/org.txt) — leaving files untouched."
    exit 0
fi

for f in project.yml Shared/SharedSettings.swift \
         Config/SocialTimeMonitor.entitlements Config/UsageReport.entitlements Config/UsageMonitor.entitlements; do
    sed -i '' "s/YOURORG/$ORG/g" "$f"
    # idempotent: also handle a previously applied org (com.X.socialtimemonitor)
    sed -i '' "s/group\.com\.[A-Za-z0-9.-]*\.socialtimemonitor/group.com.$ORG.socialtimemonitor/g" "$f"
    sed -i '' "s/com\.[A-Za-z0-9.-]*\.socialtimemonitor/com.$ORG.socialtimemonitor/g" "$f"
done
echo "org applied: $ORG (rerun xcodegen generate)"
