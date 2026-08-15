# Woutalma Keur — agent contract

## Mission

Build a calm, low-data Flutter app that lets a client find and contact a nearby verified broker or
agency in at most three screens. Low literacy, entry-level Android phones, weak networks,
French, accessibility and direct contact are product constraints, not later polish.

## Knowledge base

Every specification lives under `docs/`. This file and its symlinks stay at the root; nothing else
does.

```text
AGENTS.md                          this contract — the only entry point
CLAUDE.md                          symlink → AGENTS.md
docs/
├── PRODUCT.md                     scope, roles, business rules, entities, MVP exclusions
├── UX-FLOWS.md                    screen registry, routes, overlays, back behavior, states
├── UX-FLOW-MAP.html               rendered navigation map, generated from UX-FLOWS.md
├── INTERACTION-FEEDBACK.md        validation, motion, haptic, sound, speech, repetition
├── DESIGN.md                      visual identity and tokens only (google-labs-code/design.md format)
├── WOUTALMA-UI.md                 Flutter UI, components, accessibility, localization, tests
├── QA-PASS.md                     recette manuelle : parcours testables, blocages, faux positifs
└── screen-contracts/
    ├── README.md                  when a screen earns its own contract, approval procedure
    ├── client-discovery.md        C01
    ├── broker-detail.md           C02
    └── property-editor.md         B03
```

Read only the sources relevant to the change, in this order of authority:

1. `docs/PRODUCT.md` — what the product is and is not.
2. `docs/UX-FLOWS.md` — where every function lives and how the user leaves it.
3. `docs/screen-contracts/` — the approved reference flows.
4. `docs/INTERACTION-FEEDBACK.md` — how the app answers.
5. `docs/DESIGN.md` — token values.
6. `docs/WOUTALMA-UI.md` — Flutter rules and component catalogue.
7. Current code and tests — implementation truth.

`docs/DESIGN.md` is authoritative on values; `docs/WOUTALMA-UI.md` is authoritative on usage rules.

Do not duplicate those documents here or edit a specification to justify existing code. If sources
conflict, report the exact conflict before changing product scope, navigation or destructive data
behavior. When a conflict is resolved, record the resolution and its reason in the file that keeps
the winning value.

Adding a root-level specification file is a regression: extend an existing document under `docs/`,
or add one there and to this tree in the same change.

## Locked choices

- Flutter cross-platform; entry-level Android is the first acceptance target.
- `provider` for dependency injection and observable view state. No Riverpod, GetX, service locator
  or global mutable singleton.
- `go_router` for routes and deep links; use Navigator only for project-owned sheets/overlays.
- Isar Community for app data, settings, deterministic demo seed and migrations. No second database.
- Generated ARB localization for every visible string.
- System typography only; no downloaded or bundled font.
- Repository contracts separate Isar from product logic so a remote implementation can replace it.

Do not replace a locked choice without a recorded decision approved by the user.

## Working method

For non-trivial work:

1. Read the relevant contract, route, components, tests and current package API.
2. State the user-visible behavior and affected states.
3. Implement one bounded vertical slice.
4. Format, analyze and run the narrowest relevant tests.
5. Inspect the running UI or screenshots for UI work.
6. Review the diff against the contract and acceptance criteria.

Never call a screen visually complete from source code alone. If no emulator, device, screenshot or
visual test is available, report that visual verification was not performed.

## Architecture and UI

- Widgets render state and emit intent. They do not query Isar, rank results, decide review
  eligibility or launch contact channels directly.
- View models coordinate one screen/flow and expose immutable view state. Repositories own data;
  services own ranking, validation, seeding, permissions, media, voice and contact behavior.
- Add a shared abstraction only when two features reuse it or it is a design-system primitive.
- Search for an existing `Wk*` component first. Feature screens contain no arbitrary colors, text
  styles, spacing, radii, shadows or durations.
- Visible UI goes through `Wk*` components; follow the Material restrictions in `docs/WOUTALMA-UI.md`.
- Preserve SafeArea, keyboard insets, platform back, text scaling and one-handed reach at 320–390 dp.
- One dominant action per screen. No nested cards, decorative gradients, dense dashboards or hidden
  essential gestures.
- Critical actions use a visible label, familiar pictogram and semantic label; never color/icon alone.
- Every meaningful action follows `docs/INTERACTION-FEEDBACK.md`; feedback must be deduplicated and
  respect sound, haptic, screen-reader and reduced-motion preferences.
- French must survive ×1.3 text scale without clipping or inaccessible actions. A second locale is a new ARB file, never a screen rewrite.

## Screen gate

Before implementing a screen, its contract must define route, entry, role/goal, data, permissions,
primary/secondary actions, overlays, exits/back behavior, loading/empty/error/offline/permission
states, demo/real behavior, feedback events and acceptance criteria. Add or correct the contract
first if missing.

The three reference screens require approved screenshots/goldens before their components are copied
widely: client discovery, broker detail and broker property creation.

## Packages and tests

Use the Flutter SDK or an existing maintained package for platform-heavy capabilities such as phone,
OTP, maps, geolocation, media, audio, TTS, recording and image compression. Verify maintenance,
license, supported platforms, accessibility and current APIs before adding a dependency. Wrap only
the behavior the app owns; do not test package internals.

Changed behavior requires focused unit tests for pure logic/repositories/view models and widget tests
for state, interaction, semantics, localization and routing. Goldens cover the three reference
screens and structural components, not every small widget.

Once the Flutter app exists, run from its root:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

At that point add `tool/agent_check.sh` and CI checks for forbidden state-management/font imports,
feature-level hardcoded styling, localization generation, formatting, analysis and tests. Do not
create a checker before there is code and analyzer configuration for it to inspect.

Report behavior, routes/states covered, checks run, screenshots inspected and unresolved risks.

## Execution discipline

Applies to every agent. `CLAUDE.md` is a symlink to this file, so there is one contract to keep
current instead of two that drift apart.

- Deliver a reviewable vertical slice with explicit acceptance criteria, not a broad sweep.
- Before UI work, read the relevant screen contract plus **only** the relevant sections of
  `docs/DESIGN.md`, `docs/WOUTALMA-UI.md`, `docs/UX-FLOWS.md` and `docs/INTERACTION-FEEDBACK.md`.
  Do not load the whole knowledge base for a bounded change.
- After UI changes, inspect the running app or screenshots, then run a separate review pass for
  routes, tokens, overflow, semantics, localization and states.
- Prefer official Flutter/Dart and current package documentation over remembered APIs.
- Do not add, replace or upgrade a package unless the current task needs it.
- Do not report done while generated code, analyzer, tests or visual verification are outstanding.
- Keep machine paths and personal preferences out of repository instructions.
