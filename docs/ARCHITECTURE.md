# ARCHITECTURE.md — the folder map and the laws

> Single source for how this repo's code is organized and where new code goes.
> Where another doc disagrees with this file about *code organization*, this file
> wins; UI law stays in [DESIGN.md](DESIGN.md), product truth in
> [NORTH_STAR.mdx](NORTH_STAR.mdx) / [PRODUCT.md](../PRODUCT.md), decision
> records in [decisions/](decisions/).

The governing idea, adopted from the reference pattern (the owner's Feb-2025
article *stage-2 structure* in
`~/xs/articles/articles/2025_feb_flutter_app_architecture`, instantiated by
`~/xs/car_vs_walk_game` — whose `docs/ARCHITECTURE.md` is the template this file
follows): **the file system must speak the domain**. A reader understands the
app from the folder tree alone — not from generic `widgets/` + `services/`
buckets, and not from one mega-folder that accumulates whatever has no home.
The prefix on a folder is the layer law: `data_*` folders live beneath the UI
and never import it; `ui_*` folders are experience domains; unprefixed folders
inside a data layer are shared facilities, not domains.

## 1. Layer stack (imports point DOWN only)

```
packages/headless_core →  packages/core, la_world, la_locale, la_ui →  ui_* domains →  entries/bootstrap
      (pure domain)        (Flutter services, the World,       (shell, settings,     (main.dart,
                            localization, the kit)               automations, …)       router.dart)
```

- **`packages/headless_core` is the data_models layer** — pure Dart, no Flutter
  (ADR 0002). 31 lib files already honor it; everything domain-shaped and
  Flutter-free belongs there or beneath it.
- **`la_world/` is the data_local_api analog** — the realm's local backend: the
  ONE ecsly `World` assembly point, fed by the realm journal fold; its
  components/resources are the state layer; its fixed-step systems animate the
  creature layer. Systems are business logic, components the schema, actions
  the use cases (same reading as car_vs_walk_game's sim).
- **`packages/la_ui` is the component kit** — the ONE source of interactive
  chrome (DESIGN v6, CI-enforced by `just ui-gates`).
- **`shell/` is chrome, never a domain.** Features reach it through the
  surface registry (`lib/shell/surfaces.dart`); the registry is the manifest.

Verified invariants (re-check after any move):

- `headless_core` imports nothing from `lib/`, `packages/core`, or any `ui_*`.
- `la_world` imports no `ui_*` folder and no widget code.
- Features never import `shell/` — shell reaches features through the registry
  only, never the reverse. (Today 8 statements in `coding_agent` violate this —
  `world_chat_surface`, `actor_brain`, `brain_health_dot`, `channel_members_ui`,
  `agent_mcp_tools` — named violations, fix scheduled before the shell rename.)
- `la_world` never imports feature folders. (Today `la_world_feed` and
  `la_world_components` import `realm_chat/world_state_service.dart` — the
  projection imports the feature that feeds it. Fix: realm publishes the state
  interface; the fold consumes the interface, not the folder.)

## 2. Folder map (target grammar; as-built status marked)

```
lib/
├── main.dart / main_prod.dart / headless_main.dart   # entries (debug, prod, headless CLI)
├── bootstrap.dart / router.dart / app_scaffold.dart /
│   common_imports.dart                               # ui_root role lives in root files
├── core/                       # (PENDING gather) crash/, entitlement/, shared scaffolds:
│                               #   framework-side, not tied to any domain
├── la_world/                   # data_local_api analog (name kept — it speaks the domain)
│   │                           #   la_world.dart, la_world_components, la_world_feed, creatures
│   └── realm_*  (PENDING)      # realm domains move in over time (see migration notes)
├── coding_agent/               # the agents domain (as-built mega-folder; split PENDING)
│   │                           #   the coding_agent.dart barrel is the compressed reader
│   │                           #   path and stays stable while the split lands
│   ├── realm_chat/             # → la_world (PENDING) — world chat, actors, brains, spaces
│   ├── world_inspector/        # inspector domain (PENDING own folder)
│   ├── acp_bridge/             # external ACP agents as actors (as-built)
│   ├── boards                  # mesh board replicas + bridge (→ la_world PENDING)
│   ├── chatgpt_*/ grok_*       # subscription gateways (dedup PENDING → one shared gateway,
│   │                           #   provider configs per ADR 0031)
│   ├── meaning_*, product_*    # experiment flow; product operations (as-built)
│   └── project_operations/     # LIVE files only: entry/session/widget (tombstones deleted)
├── automations/                # (as-built 2026-11-19) supervisor + declared automations
├── shell/                      # ui_shell (rename PENDING): rail, rooms column, strips,
│   │                           #   palette, surfaces.dart = THE surface registry, status edge
│   └── models/                 # ui_models (move PENDING): the Models surface (DESIGN v5)
├── doc/                        # ui_documents (rename PENDING): editor + inference ports
├── browser/                    # ui_browser (rename PENDING)
├── settings/                   # ui_settings (rename PENDING): section registry
│                               #   (settings_sections.dart), one-scroll + TOC (as-built)
├── mcp/                        # ui_debug analog (keeps name — it speaks the domain):
│                               #   agent-facing MCP tools, debug-build only
├── workbench/                  # ui_workbench (rename PENDING): 3D workbench scene
├── workspaces/                 # workspace registry domain (ADR 0026)
├── home/ idea/ note/           # LEGACY (quarantine → lib/legacy/ PENDING): frozen, do not grow
└── widgets/legacy_kit/         # legacy kit (same quarantine): live refs only from legacy surfaces
```

Workspace packages (not under `lib/`, same law): `packages/headless_core`
(pure domain), `packages/core` (Flutter services/theming — slims toward
headless_core per ADR 0002), `packages/la_locale` (localization facility: the
three `intl_{en,it,ru}.arb` sources + the `flutter gen-l10n` output — the
generated `S` classes are never hand-edited, `just gen-l10n` regenerates;
intl_utils is retired), `packages/la_ui` (component kit). `packages/`
also hosts non-app deployables (`server/`, `tg_last_answer_bot/`, `landing/`)
that share no code path with the app — placement decision pending owner call.

## 3. The laws

**Prefix grammar.** New folders follow the `data_*` / `ui_*` grammar:
`data_*` = layers beneath the UI (data models, local API), `ui_*` = experience
domains, `ui_root` = start-up assembly. Inside a data layer, `city_*`-style
domain prefixes mark domains that own a manifest row; unprefixed folders are
shared facilities. Existing folders keep their names until their staged rename
lands — the map above is the contract, not yet the tree.

**Barrels are the public API.** Every top-level folder (and workspace package)
has one barrel; cross-folder imports go through the barrel; deep imports are
legal only within the same folder. A file move inside a folder must never
break another domain. `common_imports.dart` is the optional root barrel
(article vocabulary — kept).

**`{DOMAIN}_KNOWLEDGE.md` per domain.** Named after and aligned with its
folder (`REALM_CHAT_KNOWLEDGE.md` in `realm_chat/`). One short section: what
the domain owns, its key types, how to extend it. Name-aligned so file search
and agent context-fetch find it fast.

**Birth law.** New surface = new folder + `{DOMAIN}_KNOWLEDGE.md` + one row in
the surface registry (`lib/shell/surfaces.dart`). New realm domain = new folder
+ knowledge file + wiring added ONLY at the layer root (the world assembly /
plugin manifest — the `simulation_plugin.dart` pattern: a manifest, not a
bundle; cross-domain orchestration lives at the layer root, never inside a
domain folder).

**State placement — there is no `data_states/` folder, by owner law
(2026-11-19).** With ecsly + ecsly_flutter in the stack, resources / commands
ARE the state layer. World state = ecsly resources and components in
`la_world/` (or harness-side equivalents); app-global runtime state = providers
owned by their domain folder and exposed through that domain's barrel; state
two domains need moves to the data layer (`la_world`, `headless_core`), never
into another UI domain. This is why `settings/features/` holding the mesh
relay host and supervisor services was drift — they are domains, and they now
live in `lib/automations/`.

**ecsly funneling.** `package:ecsly` (the kernel) is imported only where a
World is assembled: `la_world/` plus declared bridges (`mesh_board_bridge`,
`workbench_scene` — pending funnel). `ecsly_flutter` selector reads
(`EcsWorldSelector`, `selectEcsComponent`) are legal in any widget code. ECS
plugins are installed at the assembly point, never lazily inside a widget
build.

**Shell is chrome.** Features never import `shell/`. The rail, rooms column,
tab strips, palette and status edge are presentation of registry-registered
surfaces; a feature that needs a shell affordance registers a surface, it does
not reach into chrome.

**Flutter-free domain.** `headless_core` stays Flutter-widget-free so the
domain runs headless (tests, CLI, tooling). `dart:ui` geometry types are
acceptable; `package:flutter/` widgets are not.

**Legacy quarantine.** `home/`, `idea/`, `note/`, `widgets/legacy_kit/` are
frozen: no new code, no new imports from outside the quarantine, retirement
only through the explicit user-visible migration ADR 0002 requires (ideas and
notes hold real user data — read old format until migration runs; never delete
storage on open). Quarantine entries today: `router.dart`, `shell/view_documents.dart`,
`settings` exports (projects_export_import_buttons).

**Gates carry the mechanical laws.** The UI law is CI-enforced (`just ui-gates`,
the Material allowlist). The import-direction laws above are procedural until
promoted into a matching gate alongside it — promotion is earned by repetition,
per the generational ladder (re-check after any move until then).

## 4. Where new code goes (decision list)

| New thing | Home |
| --- | --- |
| A realm/actor/chat behavior over the world | its realm domain folder (→ `la_world/`): systems/components + wiring at the layer root |
| A UI experience (screen, flow, surface) | `ui_<name>/` domain folder: `{flow}/` + `{flow}_screen.dart` + `{feature_name}/` anatomy, `{DOMAIN}_KNOWLEDGE.md`, one registry row |
| A reusable interactive component | `packages/la_ui` (the only chrome carrier) |
| A serializable domain value type | `packages/headless_core` (pure Dart) |
| An agent-facing tool | `lib/mcp/` (+ fmtk registration) |
| An app-wide runtime provider owned by a domain | that domain's folder, exposed via its barrel (never a `data_states/` folder) |
| Flutter-side service theming/l10n glue | `packages/core` |
| App start-up/bootstrap | root files (`bootstrap.dart`, `router.dart`) — the ui_root role |
| A debug panel / agent surface | its owning domain's debug contribution, registered where the owner registers |

## 5. Deleted drift, do not resurrect

- `lib/firebase_options.dart` (fully commented; Firebase re-enable starts from
  git history, not from an empty file).
- `lib/coding_agent/project_operations/{project_operations, project_operation_controller,
  project_operation_profile, project_operation_profiles, project_browser_session}.dart`
  — tombstone re-exports of `package:oka_core/project_operations.dart`
  (ADR 0050 moved shared project execution to Oka); import `oka_core` directly.
- `packages/move_to/` — unreferenced purchases/ads staging package; ADR 0050
  made it dead. Recoverable from git history.
- `tool/*.dill` build artifacts; `.DS_Store` files.

Pending cleanup (needs owner/lane coordination, not executed here):
`lib/other/feedback.dart` (Wiredash body commented out; still referenced by
`settings_screen.dart` and `last_answer_app.dart`), `packages/shared_models`
off the `common_imports.dart` barrel (near-legacy, 2 app refs).

## 6. History

2026-11-19 — law written from the architecture-cleanup analysis. References:
the owner's Feb-2025 article (stage-2 structure — the source of the prefix
grammar, cited by name in car_vs_walk_game's recovered `ECSLY_MIGRATION.md`),
`car_vs_walk_game/docs/ARCHITECTURE.md` (the template), the
generational-architecture ladder (moves and falsifiers). Physical migration
status is marked inline (PENDING) and ordered: (1) this hygiene pass +
contract, (2) `coding_agent` split behind its barrel, (3) surface realignment
(renames + `lib/automations` pattern applied), (4) inversion fixes, (5)
legacy quarantine + ADR 0002 data-policy finish, (6) gateway dedup +
satellite-package decisions.

Falsifiers: if the split domain folders go un-entered because agents only
use the barrel, the split over-shotted — compress back. If this file drifts
doc-ahead-of-tree beyond one release cycle (the reference repo's known
failure mode), the import-direction gate gets promoted from prose to CI
sooner.
