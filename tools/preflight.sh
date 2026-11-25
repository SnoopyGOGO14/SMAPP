#!/bin/bash
# preflight.sh — run before every push (09-AUDIT-AND-NEXT.md B1).
# Catches, without a full Xcode build, the failure classes this project
# has actually met. Exit non-zero on any failure.
#
# Sections:
#   1  swift test (Packages/Core)
#   2  syntax parse of every Swift file (this Mac's compiler)
#   3  structural static checks (brackets, imports, size, force-unwrap)
#   4  project.yml sources <-> file tree cross-check
#   5  Color("...") / Image("...") names exist in an asset catalogue
#   6  screens.yml launch arguments handled by DemoMode, markers match
#
# Usage: bash tools/preflight.sh [--skip-tests]

set -u
cd "$(dirname "$0")/.."
FAILURES=0
fail() { echo "FAIL $*"; FAILURES=$((FAILURES+1)); }
pass() { echo "PASS $*"; }

# ---------------------------------------------------------------- 1
if [ "${1:-}" = "--skip-tests" ]; then
    echo "SKIP 1 core tests (requested)"
else
    if swift test --package-path Packages/Core >/tmp/preflight-core.log 2>&1; then
        pass "1 core tests ($(grep -cE 'passed|failed' /tmp/preflight-core.log >/dev/null; tail -1 /tmp/preflight-core.log | grep -oE 'Executed [0-9]+ tests' || true))"
    else
        fail "1 core tests — see /tmp/preflight-core.log"
        tail -5 /tmp/preflight-core.log
    fi
fi

# ---------------------------------------------------------------- 2
echo "--- section 2: syntax parse (xcrun swiftc -frontend -parse)"
PARSE_FAILED=0
PARSE_LOG=/tmp/preflight-parse.log
: > "$PARSE_LOG"
while IFS= read -r -d '' f; do
    if ! xcrun swiftc -frontend -parse "$f" >>"$PARSE_LOG" 2>&1; then
        echo "  cannot parse: $f" | tee -a "$PARSE_LOG"
        PARSE_FAILED=$((PARSE_FAILED+1))
    fi
done < <(find App Shared SharedUI UsageReport UsageMonitor Packages -name '*.swift' -print0 2>/dev/null)
if [ "$PARSE_FAILED" -eq 0 ]; then
    pass "2 all Swift files parse with this Mac's compiler ($(find App Shared SharedUI UsageReport UsageMonitor Packages -name '*.swift' | wc -l | tr -d ' ') files)"
else
    # Separate genuine syntax errors from newer-Swift syntax this 5.7
    # compiler does not know: a file whose errors are all on lines that
    # use post-5.7 syntax is a NEW-SYNTAX-SUSPECT, not a broken file.
    echo "--- parse errors (triage):"
    grep -B0 -A0 "error:" "$PARSE_LOG" | head -30
    fail "2 $PARSE_FAILED file(s) failed to parse (log: $PARSE_LOG)"
fi

# ------------------------------------------------- sections 3-6 (python)
echo "--- sections 3-6"
python3 - <<'PYEOF'
import re, subprocess, sys, pathlib

root = pathlib.Path(".")
failures = []

def swift_files():
    out = []
    for d in ["App", "Shared", "SharedUI", "UsageReport", "UsageMonitor"]:
        out += [p for p in (root / d).rglob("*.swift")]
    return out

def strip_strings_comments(text):
    # remove /* */ comments, // comments, string and char literals
    text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)
    text = re.sub(r'//[^\n]*', ' ', text)
    text = re.sub(r'\\.', ' ', text)          # escapes first
    text = re.sub(r'"[^"\n]*"', ' "" ', text)
    text = re.sub(r"'[^'\n]*'", " '' ", text)
    return text

# ---- 3a bracket balance
for f in swift_files():
    t = strip_strings_comments(f.read_text())
    for o, c in [("{", "}"), ("(", ")"), ("[", "]")]:
        if t.count(o) != t.count(c):
            failures.append(f"3 brackets {f.name}: {o}={t.count(o)} {c}={t.count(c)}")
print("PASS 3a bracket balance" if not [x for x in failures if x.startswith("3 bracket")] else "")

# ---- 3b import rules
MON_ALLOWED = {"Foundation", "DeviceActivity", "UserNotifications", "Core", "os"}
for f in swift_files():
    t = f.read_text()
    if re.search(r"import\s+SharedUI", t):
        failures.append(f"3 phantom import SharedUI in {f}")
    needs_ms = "ApplicationToken" in strip_strings_comments(t)
    has_ms = re.search(r"import\s+ManagedSettings", t)
    if needs_ms and not has_ms:
        failures.append(f"3 ApplicationToken without import ManagedSettings in {f}")
    needs_swiftui = "DeviceActivityReport" in strip_strings_comments(t)
    has_swiftui = re.search(r"import\s+SwiftUI", t)
    if needs_swiftui and not has_swiftui:
        failures.append(f"3 DeviceActivityReport without import SwiftUI in {f}")
    if f.parts[0] == "UsageMonitor":
        imports = set(re.findall(r"import\s+(\w+)", t))
        bad = imports - MON_ALLOWED
        if bad:
            failures.append(f"3 UsageMonitor disallowed imports {sorted(bad)} in {f}")

# ---- 3c size + force unwraps
for f in swift_files():
    n = len(f.read_text().splitlines())
    if n > 250:
        failures.append(f"3 size {f}: {n} lines (>250)")
for f in swift_files():
    for pat in (r"\btry!\s", r"\bas!\s", r"\bprint\("):
        if re.search(pat, f.read_text()):
            failures.append(f"3 force/print {pat} in {f}")

# ---- 4 project.yml sources <-> tree
yml = (root / "project.yml").read_text()
# collect sources blocks: lines like "- App" / "- Shared/SharedSettings.swift"
sources = re.findall(r"^\s+-\s+((?:App|Shared|SharedUI|UsageReport|UsageMonitor)[/\w.]*)$", yml, re.M)
for s in sources:
    if not (root / s).exists():
        failures.append(f"4 project.yml source missing: {s}")
listed_dirs = [tuple(s.split("/")) for s in sources if "." not in s]
listed_files = {s for s in sources if "." in s}
for f in swift_files():
    covered = str(f) in listed_files or any(f.parts[:len(d)] == d for d in listed_dirs)
    if not covered:
        failures.append(f"4 Swift file outside project.yml sources: {f}")

# ---- 5 asset names
colors, images = set(), set()
for cat in root.rglob("*.xcassets"):
    for child in cat.iterdir():
        if child.suffix == ".colorset":
            colors.add(child.stem)
        elif child.suffix in (".imageset", ".appiconset"):
            images.add(child.stem)
for f in swift_files():
    for name in re.findall(r'Color\("([^"]+)"\)', f.read_text()):
        if "\\(" in name:
            continue  # dynamic (interpolated) name — cannot verify statically
        if name not in colors:
            failures.append(f'5 Color("{name}") not in any catalogue (in {f})')
    for name in re.findall(r'(?<!system)Image\("([^"]+)"\)', f.read_text()):
        if "\\(" in name:
            continue  # dynamic (interpolated) name — cannot verify statically
        if name not in images:
            failures.append(f'5 Image("{name}") not in any catalogue (in {f})')

# ---- 5b SF Symbol names (W3): every systemImage:/systemName: must be
# on the allow-list in tools/sf-symbols.txt (verified for iOS 17.4).
sf_allowed = set()
sf_path = root / "tools" / "sf-symbols.txt"
if sf_path.exists():
    for line in sf_path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            sf_allowed.add(line)
else:
    failures.append("5b tools/sf-symbols.txt missing")
for f in swift_files():
    t = f.read_text()
    names = re.findall(r'systemImage:\s*"([^"]+)"', t)
    names += re.findall(r'Image\(systemName:\s*"([^"]+)"\)', t)
    for name in names:
        if name not in sf_allowed:
            failures.append(f"5b SF Symbol \"{name}\" not on the allow-list (in {f}) — check it against iOS 17.4")

# ---- 6 screens.yml launch args and markers, mirrored from DemoMode.swift
dm = (root / "App/Demo/DemoMode.swift").read_text()
def enum_cases(name):
    m = re.search(rf"enum\s+{name}[^{{]*\{{(.*?)\}}", dm, re.S)
    if not m:
        return set()
    # (?<![\w-]) keeps comments like "a 3-case enum" from matching.
    return set(re.findall(r"(?<![\w-])case\s+`?(\w+)`?", m.group(1)))
states = enum_cases("DemoState")
periods = enum_cases("DemoPeriod")
# B3: DemoMode's enums and Core.DemoArguments' legal sets must agree.
coreargs = (root / "Packages/Core/Sources/Core/DemoArguments.swift").read_text()
def core_list(name):
    m = re.search(rf"public static let {name}\s*=\s*\[(.*?)\]", coreargs, re.S)
    return set(re.findall(r'"([^"]+)"', m.group(1))) if m else set()
if enum_cases("DemoState") != core_list("states"):
    failures.append("6 DemoMode.DemoState cases and Core.DemoArguments.states drifted apart")
if enum_cases("DemoPeriod") != core_list("periods"):
    failures.append("6 DemoMode.DemoPeriod cases and Core.DemoArguments.periods drifted apart")
screens_wf = (root / ".github/workflows/screens.yml").read_text()
# routing table from SocialTimeMonitorApp.swift (switch DemoMode.screen)
app = (root / "App/SocialTimeMonitorApp.swift").read_text()
routed = set()
for line in app.splitlines():
    stripped = line.strip()
    if stripped.startswith("case "):
        routed |= set(re.findall(r'"(\w+)"', stripped))
routed |= {"home"}  # home = default tab
known_flags = {"-demo", "-screen", "-state", "-period", "-sheet", "-focus", "-card", "-day", "-scroll"}
for line in screens_wf.splitlines():
    # In the raw workflow the third argument is either the literal
    # $appearance (the light/dark loop) or an explicit appearance.
    m = re.search(r'capture\s+(\S+)\s+\S+\s+(?:\$appearance|light|dark)\s+(.*)$', line.strip())
    if not m:
        continue
    expected, argstr = m.groups()
    name = expected  # for messages
    args = argstr.split()
    i = 0
    state = "default"; period = None; focus = None; sheet = None; screen = None; day = None; scroll = None
    while i < len(args):
        flag = args[i]
        if flag not in known_flags:
            failures.append(f"6 screens.yml unknown flag {flag} in {name}")
            i += 1; continue
        val = args[i+1].strip('"') if i + 1 < len(args) else ""
        if flag == "-demo":
            i += 2; continue
        if flag == "-screen":
            screen = val
            if val not in routed:
                failures.append(f"6 screens.yml -screen {val} not routed in app ({name})")
        elif flag == "-state":
            state = val
            if val not in states:
                failures.append(f"6 screens.yml -state {val} not a DemoState case ({name})")
        elif flag == "-period":
            period = val
            if val not in periods:
                failures.append(f"6 screens.yml -period {val} not a DemoPeriod case ({name})")
        elif flag == "-focus":
            focus = val
            if not val.isdigit():
                failures.append(f"6 screens.yml -focus not a digit in {name}")
        elif flag == "-day":
            day = val
        elif flag == "-scroll":
            scroll = val
        elif flag == "-sheet":
            sheet = val
            if val != "target":
                failures.append(f"6 screens.yml -sheet {val} not handled in DemoDetailScreen ({name})")
        elif flag == "-card":
            if val not in {"1", "2", "3", "4", "$card"}:
                failures.append(f"6 screens.yml -card {val} out of range ({name})")
        elif flag == "-day":
            if not (val.isdigit() and 0 <= int(val) <= 6):
                failures.append(f"6 screens.yml -day {val} out of 0-6 ({name})")
        elif flag == "-scroll":
            if val != "end":
                failures.append(f"6 screens.yml -scroll {val} not handled in DemoMode ({name})")
        i += 2
    # markerFor mirror: screen[/state][/period][/day][/focus][/sheet][/scroll]
    parts = [screen or "?"]
    if state != "default":
        parts.append(state)
    if period:
        parts.append(period)
    if day:
        parts.append(f"day{day}")
    if focus:
        parts.append(f"focus{focus}")
    if sheet:
        parts.append("sheet")
    if scroll:
        parts.append(scroll)
    marker = "/".join(parts)
    if marker != expected:
        failures.append(f"6 marker mismatch {name}: workflow expects {expected}, DemoMode logic produces {marker}")

if failures:
    for x in failures:
        print("FAIL " + x)
    sys.exit(1)
print("PASS 3-6 structural checks, sources, assets, demo args/markers")
PYEOF
if [ $? -ne 0 ]; then FAILURES=$((FAILURES+1)); fi

echo "---"
if [ "$FAILURES" -eq 0 ]; then
    echo "PREFLIGHT OK"
    exit 0
else
    echo "PREFLIGHT FAILED ($FAILURES section(s))"
    exit 1
fi
