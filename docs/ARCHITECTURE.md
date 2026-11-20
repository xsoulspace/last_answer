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
app from the folder tree alone. The prefix on a folder is the layer law:
`ui_*` folders are experience domains (imports point down toward data);
`data_agents/` is the remote-API layer; the realm backend subjects —
`data_journal/`, `ecs_world/`, `ui_chat/`, `ecs_plugins/` — sit at lib ROOT, unwrapped,
so they stay easy to reach and to scale (owner law 2026-11-19: "journal, world,
chat, ecs_plugins at root — that's the whole point of the article: easy
access, easy to understand and scale").

## 1. Layer stack (imports point DOWN only)

```
bin/ + headless_core  →  foundation, la_locale, la_ui_kit  →  data_* backend    →  realm backend      →  ui_* domains  →  ui_root
(pure Dart CLI,         (Flutter-free utils, l10n, kit)     (projects, user,     (journal, world,      (shell, settings,  (bootstrap,
 pure domain, ADR 0002)                                     monetization,        chat, ecs_plugins,    automations,       router,
                                                            notifications,       data_agents)          documents, …)      common_imports)
                                                            emoji, agents)
```

- **`packages/headless_core` is the pure-Dart domain** (ADR 0002, consolidated
  per ADR 0034) — no Flutter, organized by concern with the same grammar as
  the app: `data_models/`, `data_replication/`, `data_storage/`,
  `data_agents/`, `services/`, `workbench/`, each with a folder barrel.
  Consumed by BOTH the app (root package) and `bin/doc_cli.dart` (the
  Flutter-free CLI — `just bin-gates` enforces that `bin/` never imports
  `package:lastanswer` or Flutter).
- **The app's `data_*` folders are the backend layer** (core dissolved here
  per ADR 0035): `data_projects/`, `data_user/`, `data_monetization/`,
  `data_notifications/`, `data_emoji/`, plus the existing `data_agents/`.
  Each has a barrel; providers and sources live beside their domain.
- **The realm backend is four ROOT folders** (no wrapper, owner law):
  - `data_journal/` — services over the append-only journal + the mesh durability
    lane (`mesh/`). The ONE authority's app-side API.
  - `ecs_world/` — the ONE in-process ecsly World: assembly, components, journal
    feed, creatures. Files carry the ecsly anatomy in their names.
  - `ui_chat/` — the chat experience domain (surface + actor widgets); its
    services live in `data_journal/`, its plugin shim in `ecs_plugins/conversation/`.
  - `ecs_plugins/` — one subfolder per consumed ecsly plugin (`boards/`,
    `conversation/`, `scene/`, `world_sync/`).
  - `data_agents/` — the agent APIs (the data_remote_api analog): harness,
    acp, subscriptions, supervised, meaning, product, config.
- **`packages/la_ui_kit` is the component kit** — the ONE source of interactive
  chrome (DESIGN v6, CI-enforced by `just ui-gates`; material-free — the
  Material/Cupertino layer is the `material_ui`/`cupertino_ui` split packages).
- **`packages/la_locale`** — the localization facility (arbs + generated S).
- **`lib/foundation/`** — Flutter-free app utilities (extensions, file_service,
  generated flutter_gen output, path_utils).
- **`ui_shell/` is chrome, never a domain.** Features reach it through the
  surface registry (`lib/ui_shell/surfaces.dart`).

Verified invariants (re-check after any move):

- `headless_core` imports nothing from `lib/` or any `ui_*`.
- `ecs_world/` and `ecs_plugins/` are the ONLY homes of `package:ecsly` kernel
  imports; `ecsly_flutter` selector reads are legal in any widget code.
- UI domains never import each other's internals — cross-domain sharing goes
  through barrels, and data sharing goes to the backend folders (the article's
  rule: reuse only widgets, never share domain data).
- Features never import `ui_shell/` internals — the registry is the manifest.
  (`lib/coding_agent.dart` is a re-export barrel kept only so pre-split
  callers compile; new code never imports it.)

Former inversion, fixed 2026-11-20: `ecs_world/world_feed.dart` and
`world_components.dart` used to import `data_journal/world_state_service.dart`;
they now consume the extracted data contract
(`data_journal/journal_contracts.dart` — `ActorTelemetry`) instead — realm
publishes state; the fold folds the contract, never the service.

## 2. Folder map (as-built 2026-11-19)

```
lib/
├── main.dart / main_prod.dart / headless_main.dart   # entries (debug, prod, headless CLI)
├── bootstrap.dart / router.dart / app_scaffold.dart /
│   common_imports.dart / coding_agent.dart           # root files (the latter: legacy re-export barrel)
├── data_journal/               # realm journal backend + mesh/ durability lane
├── ecs_world/                  # the ecsly World: world.dart, world_components.dart,
│                               #   world_feed.dart, creatures.dart, creature_mark.dart
├── ui_chat/                    # the chat experience domain (surface + actor widgets)
├── ecs_plugins/                # boards/ · conversation/ · scene/ · world_sync/
├── data_agents/                # harness/ · acp/ · subscriptions/ · supervised/ ·
│                               #   meaning/ · product/ · config/ · project_operations/
├── data_projects/              # projects, saves, tags, idea questions (core's projects half)
├── data_user/                  # user + settings models, auth, locales (core's user half)
├── data_monetization/          # purchases, ads, entitlement sources (core's monetization)
├── data_notifications/         # notification model/source/repo/notifier
├── data_emoji/                 # emoji source/notifier/last-used
├── foundation/                 # Flutter-free app utils: extensions/, file_service/,
│                               #   generated/ (flutter_gen), path_utils.dart
├── ui_root/                    # app assembly (last_answer_app, loading, theme/ design tokens,
│                               #   global state providers/initializers — the composition root)
├── ui_shell/                   # chrome: rail, rooms column, strips, palette, registry
├── ui_models/                  # Models surface + agent_config/ document
├── ui_settings/                # section-registry settings experience
├── ui_automations/             # supervisor + declared automations surface
├── ui_documents/               # doc editor, inference ports, agent-doc surface + MCP
├── ui_browser/                 # embedded browser windows
├── ui_workbench/               # 3D workbench screen (scene binding in ecs_plugins/scene/)
├── ui_inspector/               # world inspector surfaces (page, tools, seats, bindings)
├── ui_boards/                  # planning board surface
├── ui_paywall/                 # paywall flow
├── ui_onboarding/              # first-run + intro
├── ui_workspaces/              # workspace registry domain (ADR 0026)
├── mcp/                        # agent-facing MCP tools, debug builds (ui_debug analog)
└── crash/ + entitlement/       # small unprefixed facilities
```

Workspace packages (same law): `packages/headless_core` (pure domain),
`packages/la_locale` (localization), `packages/la_ui_kit` (component kit),
`packages/shared_models` + `packages/core_server_client` (server contracts).
Independently deployable products live in **`deployables/`** (ADR 0033):
`deployables/server/`, `deployables/tg_last_answer_bot/`,
`deployables/landing/` — workspace members via the `- deployables/*` glob,
`packages/` is app-support packages only. The top-level **`bin/`** holds the
Flutter-free headless CLI (`doc_cli.dart`, ADR 0034).

## 3. The laws

**Prefix grammar.** `ui_*` = experience domains; the realm backend = the four
root subjects (`data_journal`, `ecs_world`, `ui_chat`, `ecs_plugins`) + `data_agents`;
unprefixed folders are facilities. Files inside backend folders carry the
ecscy anatomy in their names (`world_components.dart`, `world_feed.dart`,
`*_systems.dart`) — never generic `components/` + `systems/` buckets.

**Barrels are the public API.** Every top-level folder (and workspace package)
has one barrel; cross-folder imports go through the barrel; deep imports are
legal only within the same folder. `common_imports.dart` is the root barrel.

**`{DOMAIN}_KNOWLEDGE.md` per domain.** Named after and aligned with its
folder. One short section: what the domain owns, key files, how to extend.

**Birth law.** New surface = new `ui_<name>/` folder + knowledge file + one
row in the surface registry. New backend capability = a file in its root
subject (or a new root subject the owner names) + knowledge entry; cross-domain
orchestration lives at the layer root, never inside a domain folder.

**State placement — no `data_states/` folder, by owner law.** With ecsly +
ecsly_flutter, resources/commands ARE the state layer. World state = ecsly
resources/components in `ecs_world/`; app-global runtime state = providers owned
by their domain folder, exposed via that domain's barrel; state two domains
need moves to the backend folders, never into another UI domain.

**ecsly funneling.** `package:ecsly` (kernel) is imported only in `ecs_world/`
and `ecs_plugins/`. ECS plugins install at the assembly point, never lazily
inside a widget build.

**Shell is chrome.** Features never import `ui_shell/` internals; the surface
registry is the manifest.

**Flutter-free domain.** `headless_core` stays Flutter-widget-free.

**Legacy retirement (2026-11-19, applied).** `ui_legacy/` is deleted. The
ADR 0002 law held: zero data loss — the legacy rows, note-asset files and the
`DbSaveModel` replication payload were never touched. The note/idea EDITORS
are retired; opening a legacy row in the Documents grid converts it ON DEMAND
into a doc (`ui_documents/legacy_project_migration.dart` — deterministic id
`legacy-<type>-<id>`, idempotent, non-destructive, originals kept in every
backup). Known follow-ups: grid still lists original rows next to their
converted docs; note image files stay in the `note-assets/` plane
(`data_journal/note_asset_store.dart`).

**Gates carry the mechanical laws.** UI law is CI-enforced (`just ui-gates`).
The import-direction laws above are procedural until promoted into a matching
gate — promotion earned by repetition, per the generational ladder.

## 4. Where new code goes (decision list)

| New thing | Home |
| --- | --- |
| A realm/journal behavior (chat verbs, projections) | `data_journal/` |
| A UI experience (screen, flow, surface) | `ui_<name>/` domain folder + registry row |
| A chat-domain widget | `ui_chat/` |
| World/component/system for the ecsly World | `ecs_world/` (anatomy-named file) |
| A consumed ecsly plugin's integration | `ecs_plugins/<plugin>/` |
| An agent transport / API client | `data_agents/<concern>/` (pure logic → `packages/headless_core/lib/data_agents/`) |
| A reusable interactive component | `packages/la_ui_kit` |
| A serializable domain value type | `packages/headless_core/lib/data_models/` |
| App-domain data (sources, repos, providers) | its `data_<domain>/` folder + barrel |
| A Flutter-free app utility | `lib/foundation/` |
| A Flutter-free CLI entry | `bin/` (never imports `package:lastanswer` or Flutter — `just bin-gates`) |
| An agent-facing tool | `lib/mcp/` (+ fmtk registration) |
| App start-up/bootstrap | `ui_root/` + root files |
| Localization strings | `packages/la_locale/lib/src/l10n/` + `just gen-l10n` |

## 5. Deleted drift, do not resurrect

- `lib/coding_agent/` mega-folder (dissolved 2026-11-19 — `lib/coding_agent.dart`
  is a re-export barrel only; new code never imports it).
- `lib/other/`, `lib/ui/`, `lib/widgets/` (dissolved — ui_root/ui_onboarding/
  world/ui_root; the kit is `packages/la_ui_kit`).
- `lib/ui_legacy/` (retired 2026-11-19 — editors deleted, load-bearing pieces
  extracted: ScreenLayout/BottomSafeArea → `packages/la_ui_kit`, ProjectRoute/
  ProjectView/changelog → `ui_documents`, NoteAssetStore → `data_journal`,
  ProjectsDirectionSwitch → `ui_settings/widgets`; /home/n + /home/i routes
  dropped, /home/d + /home/changelog kept — MCP vocabulary depends on them).
- `lib/firebase_options.dart`; the `project_operations` tombstones;
  `packages/move_to/`; `tool/*.dill`; `.DS_Store`.
- `packages/core/lib/src/generated/intl/*` + the `flutter_intl:` config
  (localization moved to `packages/la_locale`; intl_utils retired).
- Pending cleanup (needs lane coordination): `ui_root/feedback.dart` (Wiredash
  body commented), `packages/shared_models` off the barrel.

## 6. History

2026-11-19 late — prefixes completed per owner: journal→data_journal,
world→ecs_world, chat→ui_chat; ecs_plugins + data_agents already prefixed.
2026-11-19 — law written from the architecture-cleanup analysis, then applied
physically in the same day's restructure: ui_ renames (shell, settings,
automations, doc, browser, workbench, workspaces, ui_pay→ui_paywall;
shell/models + agent_config → ui_models), other/ui dissolved, ui_legacy
quarantine, coding_agent dissolved into data_journal/ecs_world/ui_chat/ecs_plugins/
data_agents/ui_inspector/ui_boards behind the re-export barrel, world
flattened to the ecsly anatomy, workbench scene → ecs_plugins/scene.
References: the owner's Feb-2025 article (stage-2 grammar), the owner's
root-folder law ("journal, world, chat, ecs_plugins at root"),
`car_vs_walk_game/docs/ARCHITECTURE.md` (template), the generational-
architecture ladder (moves and falsifiers).

2026-11-20 — the five-wave layout update (ADRs 0033–0036): `deployables/`
(server, tg_last_answer_bot, landing moved out of `packages/`); la_ui renamed
`la_ui_kit`; headless_core restructured by the app's grammar
(data_models/data_replication/data_storage/data_agents/services/workbench
+ folder barrels + HEADLESS_CORE_KNOWLEDGE.md) and consolidated (pure pieces
of the app moved in; `bin/doc_cli.dart` added with the `just bin-gates`
Flutter-free law); `packages/core` DISSOLVED into the app's `data_projects/
data_user/data_monetization/data_notifications/data_emoji`, `foundation/`,
`ui_root/` (composition root + theme/) and `ui_settings/widgets/`; the
scheduled journal-interface inversion applied
(`journal_contracts.dart`); the material_ui/cupertino_ui split migrated via
the official `dart fix --code=migrate_design_widgets`.

Falsifiers: if the split domain folders go un-entered because agents only use
barrels, the split over-shotted — compress back. If this file drifts
doc-ahead-of-tree beyond one release cycle, the import-direction gate gets
promoted from prose to CI.
