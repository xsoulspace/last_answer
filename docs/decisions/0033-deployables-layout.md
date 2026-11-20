# ADR 0033: Deployables layout

Date: 2026-11-20
Status: accepted
Deciders: owner (requested the move), steward-executed

## Context

`packages/` mixed two kinds of members: app-support packages consumed by the
Flutter app (`core`, `headless_core`, `la_locale`, `la_ui_kit`, `shared_models`,
`core_server_client`) and independently deployable products that only share the
workspace for resolution convenience (`server` — Serverpod backend,
`tg_last_answer_bot` — Dart Frog + Televerse Telegram bot, `landing` — Jaspr
client-side site). ARCHITECTURE.md carried this as an open placement decision
("placement decision pending owner call"). The owner called it: move the three
deployables to a top-level `deployables/` folder.

## Decision

1. New top-level `deployables/` folder. `packages/` is reserved for
   app-support packages — everything in `packages/` is on the app's import
   graph; everything in `deployables/` is a shippable product.
2. The three keep their Dart package names (`server`, `tg_last_answer_bot`,
   `landing`) — only the folder moved.
3. Workspace membership is kept: root `pubspec.yaml` workspace list gains
   `- deployables/*` next to `- packages/*`. One resolution pass for
   `shared_models` (server's model contract) and consistent SDK constraints
   across the repo.
4. Parent-relative paths re-pointed: `deployables/server/pubspec.yaml`
   (`shared_models` → `../../packages/shared_models`),
   `deployables/server/config/generator.yaml` (`client_package_path` →
   `../../packages/core_server_client`).
5. Root justfile server recipes re-pointed to `deployables/server` (they were
   stale, pointing at the long-gone `apps/core_server_server`); the
   commented GCP deploy scaffold under `.github/wip/` uses the new path.

## Consequences

- Adding a future deployable = one folder under `deployables/`, no pubspec
  list edits (glob).
- `packages/` gains a crisp invariant that the import gates can eventually
  enforce: nothing under `lib/` may import a `deployables/` package.
- The headless CLI (ADR 0035, bin/) is NOT a deployable — it is repo tooling
  like `tool/`, run from source; it becomes a deployable only if it ships.
- No CI changes were needed (no workflow referenced the old paths).

## Alternatives rejected

- Keep them in `packages/`: preserves the mixed-vocabulary status quo the
  owner explicitly rejected.
- Detach from the workspace: `shared_models` would resolve twice; no benefit
  since all three build with the same SDK.
