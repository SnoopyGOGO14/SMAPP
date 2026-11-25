# Failure classes — every compile failure met on this project

One line each. When reading unbuilt code, hunt for these patterns first.
Sources: the 18 November failure→fix log in `PROGRESS.md`, the 07 visual
review, and the 25 November audit.

1. **Bundle ID prefix** — extension bundle IDs must be prefixed by the
   app's ID; XcodeGen does not infer it (`PRODUCT_BUNDLE_IDENTIFIER` set
   explicitly per target).
2. **`Equatable` with tuple members** — Swift cannot synthesize
   conformance when a property is a tuple; drop the conformance or
   flatten the tuple (`TokenCleanup.Result`).
3. **`import SharedUI`** — SharedUI is a source group compiled into each
   target, not a module; the import does not exist. Slipped in three
   times.
4. **XcodeGen type names** — `extensionkit-extension` is one word;
   monitor extensions are `app-extension`.
5. **FamilyControls in the monitor extension** — `UsageMonitor` cannot
   import FamilyControls/ManagedSettings (memory ceiling + linking):
   token-typed settings live in `SharedSettings+Tokens.swift`, compiled
   into app and report only.
6. **DeviceActivity SwiftUI overlay types** — in explicit-module builds,
   `DeviceActivityResults` and friends are only visible with **both**
   `import SwiftUI` and `import DeviceActivity`.
7. **`.weekly` on `DeviceActivityName` unresolved in the monitor** —
   extension modules do not see app types; share names via
   `Shared/ActivityNames.swift`.
8. **Deferred `let` in ViewBuilder** — `buildExpression` rejects a
   `let` declared inside a view-builder closure (TargetScreen:133, run
   21). Use a helper function or compute before the builder.
9. **Shadowed locals** — a local named `interval` shadows a function
   `interval(for:)`; the call then fails to compile. Prefer distinct
   names (`range`).
10. **`DateComponents` argument order** — positional memberwise-style
    initialisation is easy to get wrong; use labels (`hour:minute:`)
    and check the argument is the right type.
11. **Modifier on the wrong type** — e.g. `.navigationTitle` /
    toolbar content on a non-view, or a `Toggle` modifier applied where
    the builder expects `View`; re-check what the expression returns.
12. **New-API drift** — code written against memory instead of the
    page: verify every Screen Time / Charts / SwiftUI signature against
    Apple's docs before trusting it (docs-before-code rule).
13. **Non-ViewBuilder `if` in a `some View` property** (run 26): a
    computed property without `@ViewBuilder` whose body is `if/else`
    becomes a Swift 5.9 *if-expression* — both branches must have the
    same type ("branches have mismatching types"). Annotate with
    `@ViewBuilder`.
14. **Non-exhaustive switch over a widened enum** (run 27): when a
    mapping property returns the *same* enum it narrows (e.g.
    `dataSet: DemoPeriod`), downstream switches silently stop being
    exhaustive. Return a narrow dedicated enum instead.
15. **Type-checker timeout on untyped literal chains** (run 34): an
    expression like `(((d + 2) % 7) * 9 + (d % 5) * 8 + 16) % 74 + 8`
    inside a closure can time out ("unable to type-check this
    expression in reasonable time") — even when near-identical code
    compiled before. Break the arithmetic into explicitly typed
    sub-expressions (`let step: Int = …`).

Also caught by `tools/preflight.sh` (static, no compiler):

13. **Demo marker drift** — `screens.yml` args and `DemoMode`'s enums
    drift apart (`-period weekly` with no `weekly` case); the workflow
    then records MISMATCH for every affected capture.
