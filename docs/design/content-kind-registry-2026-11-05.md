# Content-kind registry — making a new kind as cheap as registering a plugin (2026-11-05)

Status: **proposal** (owner-directed architecture analysis; read-only pass, no
code moved). Sibling of
[shell-redesign-rail-views-tabs-2026-11-05.md](shell-redesign-rail-views-tabs-2026-11-05.md)
(the rail+views+per-view-tabs rebuild) and
[unified-views.md](unified-views.md) (the ONE-registry law). Law frame:
[ADR 0003](../decisions/0003-agents-live-in-docs.md) (composition law — the
ACP vocabulary is the universe), [NORTH_STAR.mdx](../NORTH_STAR.mdx) non-goals
(:68-84), [DESIGN.md](../DESIGN.md) "Extension contract for future panes"
(:123-133).

Goal: adding a CONTENT KIND (text doc, code, image + image generation,
screenplay, video, audio, book, tutorial/marketing, harness beats/threads)
costs one registry entry on the Flutter side, optionally one ecsly plugin on
the data side, optionally one "tiny glade" scene view — never a new protocol,
never a new navigation taxonomy.

---

## 1. Inventory — how each layer registers today

### 1.1 ecsly plugin mechanics (data side)

- `Plugin` is a 3-member abstract class: `name`, `install(World)`,
  `uninstall(World)` — `~/xs/ecsly/core_packages/ecsly/lib/src/plugins/plugin.dart:26-43`.
- `World.addPlugin` / `addPluginIfAbsent` —
  `~/xs/ecsly/core_packages/ecsly/lib/src/world/world_extensions.dart:437,447`.
- `PluginRegistry.add` installs and indexes by name; a duplicate name throws
  `PluginInstallationException` —
  `~/xs/ecsly/core_packages/ecsly/lib/src/plugins/plugin_registry.dart:23-33`.
  Component registration inside `install` is idempotent per the kernel
  (already-registered types keep their ids).
- A plugin bundles: component registration (`registerObjectComponent<T>()`),
  resources (`world.upsertResource`), systems/schedules. It owns NO store and
  NO execution — hosts do (the boards precedent below).

### 1.2 Worked example: `ecsly_boards` (harness repo `pkgs/ecsly_boards`)

Four pieces, and the split is the pattern every content kind's data side
should copy:

1. **Ontology as components** —
   `pkgs/ecsly_boards/lib/src/board_ontology.dart:47-127`: `CardKey` (stable
   host-scoped STRING identity, never a runtime `Entity` handle — the identity
   law, :6-11), `CardBoard`, `CardTitle`, `CardStatus` (the ONE canonical
   vocabulary `BoardTaskStatus{requested,running,completed,failed,cancelled}`,
   :25-42), `CardCreatedAt`, `CardOrigin`, `CardVerdict`, `CardColumn`,
   `CardRank` (fractional rank, `rankBetween` :466-484), edges `ParentCard`
   :109 / `DependsOnCards` :115, provenance `TaskQueueRef` :124. Config
   resource `BoardsConfigResource` :130.
2. **`Plugin.install` registration** — `BoardsPlugin` :139-172: twelve
   `registerObjectComponent` calls + `upsertResource`; `uninstall` removes the
   resource. Read helpers (`spawnCard` :214, `cardsOf` :254, `moveCard` :300,
   `settleCard` :310, `decompose` :337, `placeCard` :421, `cardsOfColumn`
   :534) are plain functions over `World` queries — deterministic on every
   replica.
3. **Queue⇄card projection** —
   `pkgs/ecsly_boards/lib/src/task_card_mapping.dart`: the durable task queue
   (`package:ecsly_tasks`, harness `pkgs/ecsly_tasks/lib/src/durable_task_queue.dart`)
   is lifecycle TRUTH; the card RENDERS it (:1-14). `cardStatusOfQueue` :31-41
   is a total one-way map (`unknown` → `failed` — an unproven outcome is a
   visible failure). `projectQueueRecord` :66-115 is idempotent (re-projecting
   the same record changes nothing).
4. **`BoardHost` execution seam** —
   `pkgs/ecsly_boards/lib/src/board_host.dart:23-29`: the board never runs
   work; a host implements `Future<BoardRunOutcome> run(BoardWorkOrder)`.
   `runRequestedCards` :89-141 owns the ONE claim→run→settle loop (single
   writer, timeout = FAILED with named reason, `onClaimed`/`onSettled` hooks
   are where the host mirrors into its own durable store).

A second, lighter precedent: `ecsly_conversation` (harness
`pkgs/ecsly_conversation/lib/src/conversation_components.dart`) ships threads/
beats as COMPONENTS ONLY (no `Plugin` subclass) — fine when the host world
registers them itself; boards is the full-plugin shape.

### 1.3 How last_answer mounts plugin-driven UI today

The boards lane is the complete worked mount, and it is the template:

- **Frozen wire store**: `MeshTaskBoard` —
  `lib/coding_agent/mesh_task_board.dart:166`; ONE `WorldSync` replica per
  board (`ecsly_world_sync`, `~/xs/ecsly/plugins/ecsly_world_sync/lib/src/world_sync.dart:31`,
  LWW map, `applyDelta` one op per field), whole-file mesh exchange under
  `task_boards/<boardId>.json` (header :1-47, incl. the HLC watermark fix).
- **Bridge (non-widget discipline owner)**: `MeshBoardBridge` —
  `lib/coding_agent/mesh_board_bridge.dart:124-219`. It owns
  `World()..addPlugin(const BoardsPlugin())` (:133), projects replica rows
  into the canonical world idempotently (`_project` :193-218 — the wire
  vocabulary IS the canonical one, statuses map by name), runs ONE cycle
  (:163-189) through `runRequestedCards`, and writes the replica back at
  claim/settle through the loop's hooks. `MeshBoardHost implements BoardHost`
  (:71-103) adapts a `DocTurnRunner` (:28-37 — bound workspace + one
  delegated turn, the ONLY thing a widget owns). Instantiated lazily by the
  agent doc surface: `lib/coding_agent/agent_doc_surface.dart:961`.
- **Controller (view facade)**: `PlanningBoardController extends
  ChangeNotifier` — `lib/coding_agent/planning_board_controller.dart:25-120`
  — over `PlanningBoardReplica` (`lib/coding_agent/planning_board_replica.dart:131`,
  wire `planning_boards/<boardId>.json`). The mesh-wired instance hangs off
  `StorageBackendsNotifier.planningController` —
  `lib/settings/features/storage_backends_state.dart:630-635,750`.
- **View**: `BoardView` — `lib/coding_agent/board_view.dart:24`; widget-key
  contract `board`, `board.column.<c>`, `board.card.<id>`, `board.op.*`
  (:60,115,121,128,195-230).
- **Mount**: ONE `SurfaceSpec` entry — `lib/shell/surfaces.dart:275-289` —
  resolving the controller from the provider tree inside the builder.

Pattern in one line: **plugin (model) → replica (wire/authority) → bridge
(discipline) → ChangeNotifier controller (facade) → keyed widget → SurfaceSpec
(mount)**. Every step is optional except the last two.

### 1.4 The shell surface registry (UI side)

- `SurfaceSpec{id,title,builder,icon,leading}` — `lib/shell/surfaces.dart:64-84`;
  `SurfaceRegistry = Map<String, SurfaceSpec>` :87; `buildShellSurfaces`
  :205-293 registers 8 static surfaces; `AppShell` injects the 9th (`newtab`)
  and feeds a `ViewScope` — `lib/shell/app_shell.dart:545-551`. Layout
  persists as `shell.views.v2` (`app_shell.dart:71`, `lib/shell/view_layout.dart:42`).
- The registry is ONE (unified-views law): the same spec renders as tab, pin,
  or miniwindow; presentations multiply, the registry does not.
- The 9 surfaces: `conversations` (:209), `browser` (:218), `inspector`
  (:224), `filesystem` (:230), `people` (:246), `terminal` (:261, honest
  placeholder), `threads` (:268, honest placeholder), `boards` (:275),
  `newtab` (picker, `app_shell.dart:546-551`; `NewTabSurface` at
  `lib/shell/center_tabs.dart:669`).

### 1.5 `ecsly_flutter_scene` — what the "scene" actually is today

Package: `~/xs/ecsly/plugins/ecsly_flutter_scene` (path dep,
`pubspec.yaml:29-30,322-323`). A 3D scene ADAPTER over `flutter_scene`
(Flutter GPU / Impeller; `flutter_scene: ^0.24.3`, Flutter ≥3.47). ~930 lines
total. It is NOT a game engine; it is a diffed binder from ecsly queries to
five primitives.

What it exposes (all via `lib/ecsly_flutter_scene.dart:9-17`):

- **`VisualState`** (pure data, no Flutter) — `lib/src/visual_state.dart:31-76`:
  `shape` from the CLOSED vocabulary `SceneShape{sphere, cuboid, disc,
  billboard, polyline}` (:12-27), `argb` int color, uniform `size`, XYZ
  `position`, optional `label` (DATA for the consumer's 2D overlay — sinks
  render NO text, :56-58), optional `pickId` (pick targets must be spheres,
  :60-63), polyline `points`, and a cheap `signature` (:72-75) the binder
  diffs on.
- **`SceneMapping`** — declarative component→visual DSL,
  `lib/src/scene_mapping.dart:29-87`: `add<T extends Component>(visualOf,
  {skip})` (:41-56, type-safe, nothing dynamic per frame), `collect(World)` →
  `{key → VisualState}` (:66-86, stable keys `'T|e<entity>'`), and a `ground`
  closure for space-making decorations (floor rails, horizon — :33-36).
  **Layout is the consumer's job** — "the adapter never arranges a graph
  itself" (:7-9).
- **`EcsSceneBinder` + `SceneSink`** — `lib/src/ecs_scene_binder.dart:18-72`:
  collect→diff→apply (add/update/remove only), signature-gated so a static
  world costs one collection per pass.
- **`FlutterSceneSink`** — the ONLY file touching the real renderer
  (`lib/src/flutter_scene_sink.dart:21-116`): five geometries, PBR base color
  (billboard/polyline unlit). API drift costs one file (:5-8; note the doc
  says "pinned against flutter_scene 0.23.0" while the pubspec says `^0.24.3`
  — a live drift marker).
- **`SceneCameraRig`** — orbit/dolly/focus camera (:121-177, clamped
  pitch/distance).
- **`EcsSceneView`** — the embedding widget (`lib/src/ecs_scene_view.dart:26-260`):
  owns GPU init + honest error/loading states (:105-159, `loadingColor` so a
  light-paper host stays paper :78-81), a READ-ONLY 30 Hz binder sync (the
  app loop ticks the world, :119-126), orbit/scroll gestures, the pick
  grammar `onEntityTap`/`onEntityHold` (:57-64, ray-pick :232-253),
  consumer-claimable drag manipulation `onManipulationStart/Update/End`
  (:71-76), semantic-zoom hook `onDistanceChange` (:52-55), and
  `onCameraChanged` (:66-69) so the consumer projects 2D nameplates with the
  same basis (`lib/src/scene_camera_math.dart:29` `SceneCameraBasis`, :161
  `pickVisuals`).

What it does NOT provide: text rendering, layout, theming, textures/sprites
or asset meshes, animation, LOD (the hook exists, the tiers are the host's).

Current last_answer use: exactly ONE mount — `WorkbenchScene`
(`lib/workbench/workbench_scene.dart:13-80`: a private `World`, one
`_WorkLayer` component ×3, three pickable spheres, drag-the-layout-layer to
stage reading width), mounted behind the workbench's `spatial` projection
toggle at `lib/workbench/workbench_screen.dart:819`. `FLTEnableFlutterGPU` is
set for macOS (`macos/Runner/Info.plist:7-12`). The Info.plist comment
promises "the world inspector's 3D band", but no file under
`lib/coding_agent/world_inspector/` imports the package (grep: only
`workbench_scene.dart:2`) — the inspector 3D band is promise, not code.

### 1.6 Content model and storage adapters today

- `ProjectModel` is a sealed freezed union —
  `packages/core/lib/src/data_models/project.dart:115-251` — with variants
  `idea` (:138), `note` (:151), `changelog` (:165), `doc` (:176). `ProjectTypes
  {idea, note, systemChangelog, doc}` :12.
- **`formatId` on the doc variant is already the designed kind extension
  point**: `DocFormatIds{chat, agent}` :20-29, and the doc comment says "Any
  other value is a user-installed format template" (:19). `AgentDocModel`
  (agent-doc payload, ADR 0003) rides only `formatId:'agent'` (:60-81,198-199).
- Doc bodies: `DocBlockModel{heading,paragraph,list}` :89-101, persisted one
  file per node at `docs/{id}.json` in universal_storage
  (`packages/core/lib/src/data_sources/local/doc_body_storage.dart:5-8`), with
  a filesystem-backend checkbox model (`supportsFileStorage`,
  `packages/core/lib/src/data_repositories/projects_repository.dart:17-26`).
- Recursive node model (ADR 0001): `parentDocId`/`anchorSpan`/`spanSnapshot`
  :189-196, `getChildren` (`projects_repository.dart:43-45`).
- Storage backends: `StorageBackendId{localDb, filesystem, gitOffline, mesh,
  github}` — `lib/settings/features/storage_backends_state.dart:19`.
- Routes per legacy kind: `/home/n/:noteId`, `/home/d/:docId`, `/home/i/:ideaId`
  — `lib/router.dart:38-61` (no chrome reaches them per shell-redesign D4).
- Inference ports are text/ACP only: `AcpDocInferencePort`
  (`lib/doc/acp_doc_inference_port.dart:25`), `openrouter_doc_inference_port.dart`.
  No image-generation port exists.

---

## 2. A concrete ContentKind registry for last_answer

### 2.1 Laws it must obey

1. **No second protocol** (NORTH_STAR :70; ADR 0003). The registry is a
   Flutter-side composition map. It defines NO wire vocabulary; anything
   mesh-shared rides the EXISTING replicas (`WorldSync` LWW) and, when a kind
   needs typed shared state, an ecsly plugin on the boards pattern (§1.2).
2. **One registry** (unified-views). `ContentKindRegistry` does not compete
   with `SurfaceRegistry`: a kind PRODUCES `SurfaceSpec`s; views stay the one
   map of the session. The 9 existing surfaces are untouched chrome.
3. **DESIGN.md extension contract** (:123-133): every kind declares stable
   identity/title, pane behavior, states (empty/loading/denied/offline),
   keyboard + accessible alternative, and which state is shared meaning vs
   personal arrangement. The spec fields below ARE that checklist as data.
4. **Widget keys are the agent contract**: each kind owns a key prefix
   (`kind.<kindId>.*`), same discipline as `board.*` (`board_view.dart:60-230`)
   and the semantics plan (shell-redesign §2.3).

### 2.2 The spec (sketch — `lib/kinds/content_kind.dart`, new)

```dart
/// One content kind, as data. Mirrors ecsly's Plugin shape on the UI side:
/// a declaration the host composes — no execution, no store, no protocol.
final class ContentKindSpec {
  const ContentKindSpec({
    required this.kindId,            // stable id == widget-key prefix root
    required this.icon,              // the ONE outline icon family
    required this.titleOf,           // l10n: (context) => context.l10n.…
    required this.tabRenderer,       // produces the SurfaceSpec for a tab
    this.matches,                    // ProjectModel → bool (routing predicate)
    this.editor,                     // (context, ProjectModelId) → editor widget
    this.generator,                  // optional creation/generation hook
    this.storage = const DocStore(), // storage adapter REFERENCE (sealed)
    this.glade,                      // optional tiny-glade scene builder (§3)
    this.sceneSupported = false,     // honest platform gate (Flutter GPU)
    this.creatable = true,           // shows in the newtab picker
  });

  final String kindId;
  final IconData icon;
  final String Function(BuildContext) titleOf;
  final SurfaceSpec Function(BuildContext, ContentKindSpec) tabRenderer;
  final bool Function(ProjectModel)? matches;
  final Widget Function(BuildContext, ProjectModelId)? editor;
  final KindGenerator? generator;
  final KindStorage storage;
  final Widget Function(BuildContext, KindGladeData)? glade;
  final bool sceneSupported;
  final bool creatable;

  String get widgetKeyPrefix => 'kind.$kindId.';
}

/// Storage adapter references — the three seams that exist TODAY (§1.6):
sealed class KindStorage { const KindStorage(); }
final class DocStore   extends KindStorage { const DocStore(); }      // docs/{id}.json
final class FileBody   extends KindStorage { const FileBody(this.folder); final String folder; } // universal_storage binary
final class MeshReplica extends KindStorage { const MeshReplica(this.wireFolder); final String wireFolder; } // WorldSync replica

/// Generation hook (image-gen first; text ports already exist):
abstract interface class KindGenerator {
  Future<KindGenerationOutcome> generate(KindGenerationRequest request);
}
```

Registry + wiring (provider + map, the repo's existing idiom —
`StorageBackendsNotifier`, `RealmChatService` are all provider-fed
ChangeNotifiers):

```dart
final class ContentKindRegistry {
  const ContentKindRegistry(this.kinds);          // const list, no magic
  final Map<String, ContentKindSpec> kinds;
  ContentKindSpec? kindFor(ProjectModel m) =>     // ONE routing rule
      kinds.values.where((k) => k.matches?.call(m) ?? false).firstOrNull;
  static ContentKindRegistry of(BuildContext c) => c.read<ContentKindRegistry>();
}
```

`main`/`bootstrap.dart` provides `ContentKindRegistry(appContentKinds)` ABOVE
`AppShell`; `buildShellSurfaces` (`surfaces.dart:205`) and the shell-redesign's
Documents view + `⌘T`/newtab picker (`center_tabs.dart:669`) read it. The
picker lists `creatable` kinds; the Documents view opens `editor` per doc;
`ProjectRoute` (`router.dart:38-61`) resolves legacy routes through
`kindFor` so note/idea/doc routes stop being per-kind code.

**Data-side rule**: a kind whose state must be shared/typed across peers gets
an ecsly plugin + replica on the boards template (§1.3); a purely local kind
is `ProjectModel.doc(formatId: kindId)` and nothing more — `formatId` is
already "user-installed format template" (`project.dart:19`).

### 2.3 The existing 9 surfaces map onto it

| Surface (`surfaces.dart`) | Relation to the kind registry |
|---|---|
| `conversations` :209 | Chrome view. The **beats/threads kind** projects INTO it (`WorldChatSurface`, `realm_chat/world_chat_surface.dart:26`); no kind entry of its own. |
| `browser` :218 | Chrome view (`workspace_browser.dart:25`). Not a kind. |
| `inspector` :224 | Chrome view (`world_inspector_pane.dart:60`); the opt-in spatial projection — the same seam glades use (§3). |
| `filesystem` :230 | The `FileBody` store's browse face (`workspace_files_tab.dart:22`). Opening a file resolves a kind by extension via `kindFor`/registry lookup and mounts its `editor`. |
| `people` :246 | Chrome view (`view_people.dart:69`). Not a kind. |
| `terminal` :261 | Chrome view (placeholder). Not a kind. |
| `threads` :268 | Becomes the **beats/threads kind's** list projection (shell-redesign Phase 3) — first kind registered without a legacy widget. |
| `boards` :275 | The **board kind's** view face; data side is already the full plugin→replica→bridge→controller chain (§1.3). `storage: MeshReplica('task_boards/')`. |
| `newtab` (`app_shell.dart:546`) | The registry's CREATION face: picker entries come from `creatable` kinds. |

Note/idea/doc today are routes without chrome (shell-redesign D4); under the
registry they become Documents-view tabs: `kind.note`, `kind.idea`,
`kind.doc`, each `matches`-ing its `ProjectModel` variant
(`project.dart:138,151,176`).

### 2.4 Worked registration: image kind (<100 lines)

`lib/kinds/image_kind.dart` — model side needs NO new union variant: header =
`ProjectModel.doc(formatId:'image')`, binary body = `FileBody('images')`
(extending the `doc_body_storage.dart` one-file-per-node pattern to
`images/{id}.png` in universal_storage):

```dart
final class ImageKind {
  static ContentKindSpec spec() => ContentKindSpec(
    kindId: 'image',
    icon: Icons.image_outlined,
    titleOf: (c) => c.l10n.kindImageTitle,
    matches: (m) => m is ProjectModelDoc && m.formatId == 'image',
    storage: const FileBody('images'),
    tabRenderer: (c, k) => SurfaceSpec(
      id: 'kind.image',
      title: k.titleOf(c),
      icon: k.icon,
      builder: (tab) => ImageLibraryView(
        key: const ValueKey('kind.image.library'),
        store: tab.read<ImageStore>(),          // ChangeNotifier, provider-fed
      ),
    ),
    editor: (c, id) => ImageViewerPage(id: id, key: ValueKey('kind.image.$id')),
    generator: const ImageGenHook(),              // resolves its port lazily
    glade: ImageGrove.new,                        // §3 — one disc per image
    sceneSupported: kGladeOnThisPlatform,         // honest gate (macOS+GPU)
  );
}

/// The store: headers in the doc store, bytes in FileBody. Follows the
/// PlanningBoardController facade idiom (ChangeNotifier over a store).
final class ImageStore extends ChangeNotifier {
  ImageStore({required ProjectsRepository projects, required StorageService files});
  Future<ProjectModelId> import(Uint8List bytes, {String title = ''}) async { … }
  Future<Uint8List?> bytesOf(ProjectModelId id) => …; // images/{id}.png
}

/// The generator hook: a PORT, not a vendor — the DocInferencePort pattern
/// (acp_doc_inference_port.dart:25). Null port = the create button offers
/// import only; the registry never lies about capability.
final class ImageGenHook implements KindGenerator {
  const ImageGenHook();
  @override
  Future<KindGenerationOutcome> generate(KindGenerationRequest r) async {
    final port = r.context.read<ImageGenerationPort?>();  // resolved lazily
    if (port == null) return KindGenerationOutcome.unavailable();
    final bytes = await port.generate(prompt: r.prompt);  // a long job may
    return KindGenerationOutcome.file(bytes);             // ride a BoardHost
  }                                                       // card instead
}
```

New code: the spec (~25 lines), `ImageStore` (~60), a viewer/library widget
pair, `ImageGenerationPort` (interface + one provider impl), 3 arb keys
(EN/IT/RU). Long-running generation can ride the EXISTING board seam instead
of a new queue: an image-gen job is a `BoardWorkOrder` (`board_host.dart:33`)
whose host calls the port — claim/run/settle/verdict for free.

### 2.5 Worked registration: screenplay kind (<100 lines)

Pure doc-store kind — zero new storage, zero plugin:

```dart
final class ScreenplayKind {
  static ContentKindSpec spec() => ContentKindSpec(
    kindId: 'screenplay',
    icon: Icons.movie_outlined,
    titleOf: (c) => c.l10n.kindScreenplayTitle,
    matches: (m) => m is ProjectModelDoc && m.formatId == 'screenplay',
    storage: const DocStore(),                   // docs/{id}.json blocks
    tabRenderer: (c, k) => SurfaceSpec(
      id: 'kind.screenplay',
      title: k.titleOf(c),
      icon: k.icon,
      builder: (tab) => ScreenplayListView(key: const ValueKey('kind.screenplay.list')),
    ),
    editor: (c, id) => ScreenplayEditor(
      key: ValueKey('kind.screenplay.$id'),
      docId: id,                                 // styles DocBlockModel:
    ),                                           // sceneHeading/dialogue/…
  );
}
```

`ScreenplayEditor` reuses the block kernel (`DocBlockModel`,
`project.dart:92-101`; `DocView` at `lib/doc/doc_view.dart:16` is the generic
renderer) and adds Fountain-like styling. If block typing must grow, extend
`DocBlockType` (:89) — a codegen pass (`just gen`), not a new store. The
recursive node model already gives chapters/discussion threads
(`parentDocId`/`anchorSpan`, :189-196).

---

## 3. The "tiny glade" — one scene widget contract, not a game engine

Concept: each kind MAY offer a minimal, cute spatial projection of its items
— a grove where every doc/image is a plant, beats drift as fireflies — as an
OPT-IN presentation (a tab-face toggle or an inspector band), never the
required reading path (North Star: "the harness never becomes mandatory
reading"; DESIGN §10 collapsed-by-default).

### 3.1 What is grounded in today's package surface

Everything below needs NO package change — it composes §1.5 as-is:

- **One item = one `VisualState`** via `SceneMapping.add<T>` on the kind's
  component (or a private `_GladeItem` component spawned into a view-local
  `World`, the `WorkbenchScene` pattern, `workbench_scene.dart:31-52`).
- **Plants**: sphere canopy (size ~ log(wordCount), color ~ freshness/status)
  on a cuboid stem; **fireflies** (beats): unlit `billboard` quads — always
  visible (:86-89 sink), positions written per tick by the app loop; the
  binder's signature diff makes motion free (`ecs_scene_binder.dart:49-68`);
  **links**: `polyline` for `parentDocId`/anchor edges; **ground**: the
  `ground` closure draws floor rails/horizon so it reads as SPACE at every
  altitude (`scene_mapping.dart:33-36`).
- **Labels**: never geometry — a 2D Flutter overlay projected with
  `onCameraChanged` + `SceneCameraBasis`/`pickVisuals`
  (`scene_camera_math.dart:29,161`); `VisualState.label` is the overlay's data
  (`visual_state.dart:56-58`).
- **Interaction**: tap = open the item's tab (`onEntityTap`, pickId = doc id);
  hold = summon the verb sheet (`onEntityHold`, :62-64); drag = consumer-claimed
  manipulation (re-arrange the grove, :71-76); scroll = semantic zoom with
  host-defined LOD tiers via `onDistanceChange` (:52-55) — far = dots, near =
  labels+thumbnails-as-color.
- **Honesty**: `loadingColor` = the host paper (:78-81); the error state
  renders "scene unavailable" truthfully (:143-153).

### 3.2 The contract (one widget per kind, in last_answer)

```dart
/// lib/kinds/glade.dart — the WHOLE scene contract.
final class KindGladeData {           // the kind store's projection, pure data
  const KindGladeData({required this.items, required this.links});
  final List<GladeItem> items;        // id, title, sizeHint, statusArgb, position?
  final List<(String, String)> links;
}
typedef GladeBuilder = Widget Function(BuildContext, KindGladeData);
```

`ContentKindSpec.glade` is a `GladeBuilder`. last_answer composes ONE shared
`GladeView` widget (owns the view-local `World`, the `SceneMapping`, the label
overlay, the LOD tiers, the platform gate) and each kind supplies only a
**styling function** `GladeItem → VisualState` (plant vs firefly vs disc).
That is the entire per-kind scene cost: ~10 lines.

### 3.3 Package additions vs app composition

- **Must be added to `ecsly_flutter_scene`** (each small, each optional):
  (a) 1-2 `SceneShape` values if the grove wants cones/capsules for canopies
  (enum + one sink case, `visual_state.dart:12-27`,
  `flutter_scene_sink.dart:73-113`); (b) textured/sprited material in the sink
  IF cuteness ever requires an image on a quad (today: PBR base color only) —
  defer until a real grove demands it; (c) fix the pin drift (sink doc says
  0.23.0, pubspec `^0.24.3`, :8 vs pubspec:31).
- **last_answer composes** (no package change): layout functions (the adapter
  never lays out — `scene_mapping.dart:7-9`), the label overlay, LOD tiers,
  the app-loop ticker for fireflies, the `sceneSupported` platform gate
  (`FLTEnableFlutterGPU` is macOS-only today, `Info.plist:7-12`; web/Android
  fall back to the kind's list face), and the rule that at most ONE glade is
  live per view (30 Hz binder sync per open scene, `ecs_scene_view.dart:119-126`).

---

## 4. Extension cost table

"What exists" = file:line today. "Free" = what the registry (§2) + boards
template (§1.3) give without new design. "Build" = the honest remainder.

| Kind | Exists today | Registry gives free | Must be built |
|---|---|---|---|
| **note** | `NoteView` `lib/note/note_view.dart:7,35`; model `project.dart:151-160`; route `router.dart:38-45`; repo `projects_repository.dart:12` | tab spec, picker entry, key prefix, l10n hook, Documents-view hosting | ~40-line spec (`matches` on `ProjectModelNote`); restyle off legacy dialect later (shell Phase 4) |
| **idea** | `IdeaView` `lib/idea/idea_view.dart:8,27`; model `project.dart:138-148`; questions `packages/core/lib/src/data/idea_questions.dart`; route `router.dart:54-61` | same | ~40-line spec |
| **image** | NOTHING (filesystem view lists folder paths only, `workspace_files_tab.dart:22`) | tab, keys, l10n, `FileBody` adapter slot, glade slot | binary body adapter (`doc_body_storage.dart` pattern → `images/{id}.png`), `ImageStore`, viewer/library widgets, spec (§2.4) |
| **image-gen** | NOTHING (inference ports are text/ACP: `acp_doc_inference_port.dart:25`, `openrouter_doc_inference_port.dart`) | `KindGenerator` slot; job lifecycle can ride `BoardHost` claim→run→settle (`board_host.dart:23,89`) | `ImageGenerationPort` interface + one provider impl; prompt UI; verdict rendering |
| **screenplay** | NOTHING; kernel exists: `DocBlockModel` `project.dart:92-101`, `DocView` `doc_view.dart:16`, recursive nodes :189-196 | tab, editor slot, DocStore storage, keys | Fountain-styled editor over blocks; optional `DocBlockType` growth (:89) + `just gen`; spec (§2.5) |
| **video** | NOTHING | tab, `FileBody('video')`, keys, l10n | player package decision (license check, PolyForm Noncommercial — AGENTS.md); thumbnailer; spec |
| **audio** | NOTHING (voice exists only as a beat modality word, `ecsly_conversation conversation_components.dart` `BeatModalityEnum.voice`) | tab, `FileBody('audio')`, keys | recorder + player deps; waveform face; spec |
| **book** | PARTIAL: recursive doc tree (ADR 0001) — `parentDocId`/`getChildren` `project.dart:189-196`, `projects_repository.dart:43-45` | tab, DocStore, chapter navigation via existing children query | reader UI (pagination, progress register), spec |
| **tutorial / marketing** | PARTIAL: editable workbench projections (ADR 0015) `workbench_screen.dart:25`, `workbench_candidate_main.dart`; doc formatId slot `project.dart:19-29` | tab, DocStore, glade slot (staged walkthroughs) | styled renderer per format; publish/share face (rides `Sharable`, `project.dart:227-239`); spec |
| **beats/threads** | placeholder view `surfaces.dart:268-274`; data: `HarnessSessionRegistry` (harness `pkgs/xsoulspace_agentic_host/lib/src/session_registry.dart:404`, already polled per `surfaces.dart:317-329`); `WorldChatSurface` `world_chat_surface.dart:26`; ontology `ecsly_conversation` | tab, read-only projection slot, firefly glade (§3) — first kind born inside the registry | Threads list + beat tail projection (shell Phase 3 promises it); spec |

---

## 5. Risks and non-goals

**Non-goals (law, not preference):**

- **No second protocol** (NORTH_STAR :70; ADR 0003). The registry carries no
  wire vocabulary; mesh-shared kind state rides existing `WorldSync` replicas
  (`mesh_task_board.dart:1-47`) and ecsly plugins. A kind that "needs a new
  sync format" is a rejected kind until it fits `DocStore`/`FileBody`/`MeshReplica`.
- **No generic agentify-every-doc before one domain proves out**
  (NORTH_STAR :74-75). `generator` is optional and image-gen is the only
  specced candidate; the agent-doc payload stays `formatId:'agent'`
  (`project.dart:60-81`) — other kinds do NOT gain autonomy by registering.
- **No second surface taxonomy.** Kinds PRODUCE `SurfaceSpec`s; the
  `SurfaceRegistry` stays the one map (unified-views §2: two taxonomies for
  one layout state was the diagnosed disease). If a kind needs its own
  navigation, the kind is wrong.
- **No game engine.** The glade contract is one typedef + one styling
  function (§3.2); anything requiring physics, assets pipelines, or ECS
  systems-in-schedules is out of scope for `ecsly_flutter_scene` and stays out.

**Risks:**

1. **Vocabulary collision** — `ProjectTypes` (`project.dart:12`) vs
   `formatId` (:19-29) vs `kindId`. Rule: new kinds are
   `ProjectModel.doc + formatId==kindId`; legacy note/idea keep their union
   variants and gain `matches` predicates only. `kindFor` must stay a total,
   single-hit function (first-match-wins is a bug farm — enforce disjoint
   `matches` in a registry test).
2. **flutter_scene is pre-1.0** — pinned `^0.24.3` while the sink documents a
   0.23.0 pin (`flutter_scene_sink.dart:8`); API drift is contained to one
   file by design, but the glade must never gate a shipping feature (it is
   opt-in presentation; `sceneSupported=false` is a valid permanent state on
   web/Android — `FLTEnableFlutterGPU` is macOS-only, `Info.plist:7-12`).
3. **Promise/code drift** — the "inspector 3D band" exists in
   `Info.plist:7-9` prose but not in `world_inspector/` code (§1.5). The
   registry should make such claims structural: a kind either registers a
   glade or it does not; no prose-only scene commitments.
4. **Legacy dialect contamination** — note/idea screens are pre-pivot
   vocabulary (shell-redesign D5). Registering them early risks freezing the
   legacy styling into tabs; register the SPEC first, restyle in shell Phase 4.
5. **l10n obligation** — every kind title/state needs EN/IT/RU arb keys
   (`packages/core/lib/src/l10n/intl_*.arb`); existing drift (UPPERCASE
   `"CONVERSAZIONI"`, `intl_it.arb:367`) must not be replicated — sentence
   case is shell law (shell-redesign §3).
6. **License** — video/audio player and image-gen provider deps must be
   PolyForm Noncommercial-compatible (AGENTS.md); the port pattern
   (`ImageGenerationPort`) keeps vendor SDKs out of the registry itself.
7. **Performance** — one live glade per view (30 Hz binder sync,
   `ecs_scene_view.dart:119-126`); `cardsOf`-style O(n) reads are
   coordination-scale only (`board_ontology.dart:243-245`) — an image library
   of thousands needs the store's own index, not world queries per frame.

**Sequencing** (rides the shell-redesign phases, adds none): specs land with
Phase 1 (registry + Documents view are the same PR-sized seam); beats/threads
kind with Phase 3; glades AFTER Phase 2 semantics (a glade without pick
semantics is decoration, and decoration is against the law).
