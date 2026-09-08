# Report — mesh-remote-agent-analysis: can a MOBILE peer control/observe a DESKTOP agent?

> Investigation brief: `.pi/agent/squad/briefs/mesh-remote-agent-analysis.md`.
> Scope: `dart_flutter_packages/pkgs/universal_storage_{mesh,mesh_transport,convergence,sync}`
> (found at `/Users/antonio/xs/storage_problem/dart_flutter_packages/pkgs/`, not
> `~/xs/dart_flutter_packages`), last_answer app wiring, and the ADR corpus.
> All paths below are relative to the repo root unless prefixed otherwise.

## Current sync architecture (1 paragraph)

The mesh is a **serverless, local-first, op-based CRDT replica set with no
direct P2P link in production**: each device runs a `MeshStorageProvider`
(full replica, whole-file store), trust is established out-of-band by signed
`mesh-pair/v1` QR/paste payloads (Ed25519 identity keys), and connectivity is a
**WebSocket "addressed relay"** hosted by the main device on its LAN
(`AddressedRelayServer`, shelf_web_socket) that peers — including browsers —
connect to as clients. Durable state (projects payload, doc replica files,
actor rosters) converges through **manual anti-entropy sync cycles** (version
vectors + deltas/snapshots over the `universal_storage_convergence` kernel:
HLC-LWW map for registers, RGA for block text, TTL'd ephemeral ops for
presence), while **live presence** rides signed ephemeral frames over the same
always-open relay socket (ADR 0031's "shared connection, doc-scoped channels").
Permission round-trips are already event-sourced as doc ops
(`perm/<requestId>`), so the phone-approves-desktop-writes path exists today —
but it is gated by the manual sync cadence, and there is **no remote procedure
execution**: nothing lets the phone make the desktop *do* anything; the phone
can only observe (shadow doc, presence) and write ops into the shared replica.

---

## Q1 — Transport: what does the mesh use? Can peers discover each other phone↔desktop?

**Transport: WebSocket addressed relay, hosted by the main device. Not WebRTC,
not mDNS (yet).**

- `AddressedRelayClient implements MeshTransport` uses
  `WebSocketChannel.connect(endpoint)` —
  `pkgs/universal_storage_mesh_transport/lib/src/addressed_relay_client.dart:9-13,47-49`.
  One physical socket carries many logical `MeshSession`s plus a dedicated
  ephemeral-frame stream (`ephemeralIncoming`, lines 33-41).
- `AddressedRelayServer` is a shelf + `shelf_web_socket` fan-out relay holding
  `Map<String, WebSocketChannel> _clients` —
  `.../addressed_relay_server.dart:6,15-19`. The relay forwards addressed
  envelopes; it sees no application semantics.
- The "main device" hosts this relay in-process:
  `MeshStorageService.startHosting` → `LocalRelayHost.start` binds
  `ws://127.0.0.1:<ephemeral port>` and advertises a best-effort LAN IPv4
  address via `detectAdvertiseAddress()` (site-local preferred) —
  `lib/settings/features/mesh_storage_service.dart:178-186`,
  `lib/settings/features/mesh_relay_host_io.dart:16-47,58-66`.
- The ADR 0010 design (mDNS + TCP direct transport, BLE later) is a *seam*
  (`MeshTransport`, ADR 0010 §1) — no real direct-radio implementation exists
  in the tree; the WebSocket relay is what ships. Web support exists only
  because the relay accepts browser WebSocket clients
  (`docs/product/multiplayer-device-gates.md` T3: "macOS hosts the relay; web
  app connects over WebSocket").

**Discovery: none automatic. Discovery = pairing code.** The pairing payload
embeds the advertised relay endpoint as `transportHint`
(`mesh_storage_service.dart:213-222`, `createPairingCode`), and
`acceptPairingCode` auto-connects to `endpointHints['ws']`
(`mesh_storage_service.dart:226-246`). So phone↔desktop discovery works only
if (a) the user moves the QR/paste payload across, and (b) both devices share
a network path to the advertised `ws://<LAN-IP>:<port>`. There is no mDNS
browse, no STUN/TURN, no NAT traversal, no persistent cloud endpoint.

## Q2 — What state is synced, and how?

Three planes, two mechanisms (durable ops vs ephemeral frames):

1. **App payload (projects/notes/settings)** — one JSON blob
   (`last-answer-data.json`) shipped by whole-file LWW through
   `MeshStorageService.backup/restore` + provider anti-entropy
   (`mesh_storage_service.dart` `backup`/`restore`; `storage_backends_state.dart`
   `replicate/restoreNow` in `joinWithCode`).
2. **Doc replicas (the multiplayer state)** — `DocReplicaStore` files, one per
   doc channel (`agent-<projectDocId>`), flushed before and absorbed after
   every sync cycle (`attachDocSync`, `mesh_storage_service.dart:290`,
   `_syncCycle`, `mesh_storage_service.dart:381-386`). Ops are kernel
   `OpRecord`s: composite strategy lanes — `'text/'` → `RgaTextStrategy`,
   LWW map otherwise (`packages/headless_core/lib/src/doc_replica.dart:85`),
   block order via fractional keys, plus the `perm/<requestId>` register
   (`announcePermRequest`/`answerPermRequest`, `doc_replica.dart:297,323`).
   The whole lifecycle is event-sourced; the kernel owns ordering/dedupe
   (ADR 0005 §1-2, `permission_doc_router.dart` header).
3. **Actor roster** — an LWW `ConvergenceDoc` keyed `actor/<actorId>`, flushed
   as one file per replica (`actor_rosters/<replicaId>.json`) and re-folded
   from peers' files after each exchange (`_flushRoster`/`_absorbRoster`,
   `mesh_storage_service.dart:590-617`; `lib/coding_agent/actor_roster.dart:5-12`).
4. **Presence** — NOT durable state. Signed ephemeral frames (TTL'd,
   transport-level) + kernel-queryable ephemeral registry, doc-scoped
   (`joinDoc`/`leaveDoc`/`notifyPresenceActivity`/`presence()`,
   `mesh_storage_service.dart:305-355`; ADR 0031 §1-2; ADR 0029 §1). Verified
   against peers' registered identity keys (`MeshFrameAuthenticator`,
   `mesh_storage_service.dart:640-663`).

**Cadence: manual.** Sync runs only on "Sync now" (`mesh_sync_panel.dart:102-108`),
after pairing (`agent_mcp_tools.dart:442`, `storage_backends_state.dart:700`),
or via the `storage_mesh_sync` MCP verb (`lib/mcp/storage_mcp_tools.dart:353`).
There is **no `Timer.periodic`** anywhere in `lib/`, and
`MeshStorageProvider.attachTransport` triggers no auto-sync
(`pkgs/universal_storage_mesh/lib/src/mesh_storage_provider.dart:51`).

## Q3 — Existing remote procedure/verb execution between peers?

**None over the mesh. All verbs are device-local.** The MCP/intent surface
(`agent_doc_create`, `agent_task_delegate`, `agent_doc_bind`, `mesh_routing`,
`mesh_open_doc`, `agent_doc_edit`, … — `lib/coding_agent/agent_mcp_tools.dart`)
is served through `mcp_toolkit`'s per-device service-extension channel; a verb
executed on the phone acts only on the phone's local state
(`AgentDocSurface.debugSurface` / `shadowDoc` statics). What *does* cross
peers is **data, not calls**:

- Permission answers: doc ops on `perm/<requestId>` (Q4).
- Block text edits: real RGA ops via `agent_doc_edit`
  (`agent_mcp_tools.dart:796-862` → `DocReplicaStore.edit` →
  `appendText`/`addBlock`) — "the mesh sync cycle ships it".
- Presence joins/leaves: ephemeral frames.

**How a "run agent turn on the peer that hosts the workspace" verb fits:**
exactly like the permission round-trip, inverted — an event-sourced *task*
op on the shared replica. ADR 0005 §3 already names the topology ("agents
execute on the device that owns the workspace; every other peer holds input
rights: text edits, task claims, permission answers, proposals — delivered as
ops"), and `agents-in-docs.md` Phase 5 says "task assignment and permission
answers ride the existing round-trip". The missing piece is purely the
op schema + the host-side fold observer that turns a `task/<turnId>` op into
`HarnessSessionController.delegate` (see the design below).

## Q4 — How do AgentDocMeshWiring/PermissionDocRouter route permission answers today?

**Yes — the phone-approves-desktop-writes path already exists end-to-end
(gated on routing policy + a sync cycle):**

1. **Desktop (owner) announces.** With `remotePermissionRouting` ON
   (PROFILE toggle / `mesh_routing` verb, `agent_doc_surface.dart:187-219`),
   the controller attaches a `PermissionDocRouter` over the mesh-attached
   `DocReplicaStore` with the deterministic channel `agent-<docId>`
   (`home_screen.dart:19-26`, `agent_doc_surface.dart:114`); each host
   `session/request_permission` is announced as a doc op
   (`harness_session_controller.dart:574-586,600-625` →
   `PermissionDocRouter.announceRequest`, `permission_doc_router.dart:59-81`).
   Deny-by-default is preserved: the host's future completes only when an
   answer op folds; the host's own 5-minute deadline is the backstop
   (`permission_doc_router.dart:10-16`).
2. **Phone (peer) observes + answers.** After `mesh_open_doc` (shadow doc,
   `agent_mcp_tools.dart:741-855`) the phone folds the shared replica;
   `pendingRemote()` returns requests whose `originPeerId != selfId`
   (`permission_doc_router.dart:109-115`), rendered as `_RemotePermRow`, and
   `agent_permission_answer` → `AgentDocShadow.answerRemotePermission` →
   `router.answerRequest(...)` writes the answer op
   (`agent_doc_surface.dart:2228-2247`, `agent_mcp_tools.dart:113-120`).
3. **Desktop completes.** `StorageBackendsNotifier.onSyncCycle` (installed in
   `home_screen.dart:63-65`, called after every cycle) →
   `AgentDocSurface.refreshAfterMeshSync` → `controller.refreshPermissions()`
   which completes the routed future when the ANSWER op folds, attributing a
   remote `originLabel` on the turn (`agent_doc_surface.dart:227`,
   `harness_session_controller.dart:467-520`).

**The catch is step 3's timing**: the phone's answer op reaches the desktop
only "with the next sync cycle" (stated verbatim in `agent_doc_surface.dart:2244-2246`)
— and cycles are manual (Q2). So the path is correct but not prompt; nothing
pushes the answer or triggers the host's anti-entropy on arrival.

## Q5 — Minimal extension for: (a) attach to desktop ACP session, (b) stream deltas into the chat doc, (c) answer request_permission prompts

(c) **exists** (Q4). (a) and (b) need the pieces below.

### Proposed minimal design — "desktop-hosted agent, mobile-controlled over mesh"

Everything reuses the permission-round-trip pattern (ops on the shared
replica + fold observers + sync hooks). No new protocol, per ADR 0005 §5 and
ADR 0003's "no second protocol" law.

**(a) Attach / delegate a turn from the phone**

- New op namespace in `DocReplica` (`packages/headless_core/lib/src/doc_replica.dart`,
  alongside `announcePermRequest` at :297): `task/<turnId>` with
  `{sentence, originPeerId, originActorId, status: pending|claimed|done}` —
  LWW lane; `claimTask(turnId)` on the host writes back a claim op
  (first-claim-wins is enforced by the host refusing a second delegate while
  `isRunning`, the same monotonic refusal `delegateFromIntent` already has,
  `agent_doc_surface.dart:150-171`).
- Host-side fold observer: extend the existing sync hook —
  `AgentDocSurface.refreshAfterMeshSync` (`agent_doc_surface.dart:227`)
  or a new `StorageBackendsNotifier.onSyncCycle` subscriber — to detect
  pending `task/` ops on `_meshDocId` and call the *same*
  `delegateFromIntent` path (workspace binding, `_syncConfigBeforeTurn`,
  `controller.delegate`), then write `status: done` + the verdict op.
  The host is the only writer to the world (ADR 0005 §3 single-writer law).
- Phone-side verb: `mesh_task_delegate` in `agent_mcp_tools.dart`, mirroring
  `mesh_open_doc` (requires shadow open → writes the task op). `agent_doc_state`
  on the shadow gains `pendingTaskAck` so the phone can see claim/progress.
- Attachment semantics: the shadow already binds to the shared doc id and the
  host reports `sessionId` in `AgentDocDebugState.toJson`
  (`agent_doc_surface.dart:259`); `mesh_task_delegate` is "attach on first
  task op" — no separate attach handshake is needed for v1.

**(b) Stream text deltas into the chat doc**

- **Durable skeleton:** one transcript block per turn
  (`text/<turnId>` lane → `RgaTextStrategy`); the host appends finalized
  chunks via `DocReplica.appendText` (`doc_replica.dart:219-243`, explicitly
  documented as "the reliable streaming path"). The kernel's C4 chaos row
  (`multiplayer-device-gates.md`: "100+ deltas/s … identical text folds")
  already specifies the invariant.
- **Live low-latency path:** ride the *already-connected* relay socket —
  `AddressedRelayClient.ephemeralIncoming` / `sendEphemeral`
  (`addressed_relay_client.dart:33-41`) is a real-time fan-out channel that
  today carries only presence. Add a `MeshStreamSession` (next to
  `MeshPresenceSession` in `pkgs/universal_storage_mesh/lib/src/`) that
  forwards throttled delta frames keyed `agent-<docId>/<turnId>`, signed with
  the existing `MeshFrameAuthenticator`. The phone renders them into the
  shadow; when the durable RGA ops arrive with the next cycle, the kernel's
  VV dedupe + RGA fold makes replay idempotent — the shadow reconciles by
  replacing the ephemeral tail with the folded text (same dual-mode split as
  ADR 0005 §4 presence).
- **Trigger the cycle:** on turn end (and on permission announce), the host
  calls `MeshStorageService.sync()` (throttled) so durable state ships without
  waiting for the human's "Sync now". This is a 5-line change in
  `harness_session_controller.dart` (`delegate`'s `finally` block, :362-368)
  wired through the app, not the package.

**(c) Permission prompts** — already built (Q4). Add only the latency fix
above: sync-on-announce on the host and sync-on-answer on the phone, so the
round-trip is one cycle each way instead of "whenever someone presses Sync".

### Critical gaps (be honest about these)

- **NAT traversal / non-LAN reach.** The relay binds the desktop's LAN
  interface and the pairing code advertises a site-local IPv4 address
  (`mesh_relay_host_io.dart:27-66`). Phone-on-cellular → desktop-at-home does
  not work at all today. ADR 0010 §2 anticipates relay/bridge *nodes*, but the
  bridge node (a peer that also speaks a cloud protocol, e.g. git_offline) is
  undesigned; WebRTC/TURN is out of scope of the current packages. Minimal
  mitigation: let the desktop also register a cloud bridge (it is the
  workspace owner, so it can pull tasks/op logs from e.g. the GitHub backend
  asynchronously) — the ops-based design survives the latency gracefully.
- **Mobile background execution.** The phone must be foreground for anything
  to flow: iOS suspends sockets shortly after backgrounding, presence expires
  via TTL sweep (`mesh_storage_service.dart:332-343`), and sync cycles are
  app-driven. Conversely, the *desktop* is the agent host, which is fine
  (macOS apps keep running), but a turn delegated while the phone is locked
  will not answer its own permission prompts — the host's 5-minute deny
  deadline fires and the turn fails. A notification ("permission pending on
  doc X") would need a push path that does not exist in the mesh (bridge-node
  territory).
- **Latency.** Everything interactive is gated on the manual sync cadence.
  With sync-on-event triggers (design above), permission and task round-trips
  become ~one anti-entropy exchange over an already-open WebSocket (tens of
  ms on LAN); without them, the phone approves "eventually". Delta streaming
  *must* use the ephemeral channel — shipping per-delta RGA ops at human sync
  cadence would be unusable, and even with sync-per-batch it is one
  flush+exchange per batch, far heavier than the presence-style frames.
- **Transcript is not yet synced state.** `HarnessTurn`/`HarnessSessionView`
  live in device-local `StringBuffer`s (`harness_session_controller.dart:94`);
  the shadow honestly reports `turnCount: 0` ("turn ops are not yet synced
  (v1)", `agent_doc_surface.dart:2209`). The design above syncs *new* turns as
  blocks; replaying a *historical* transcript onto a late-joining peer is
  extra work (snapshot/backfill of prior turn blocks) not covered here.
- **Auth scope.** Pairing grants transport membership (ADR 0005 §5); any
  paired peer can write task ops. v1 is fine (single user, paired own
  devices), but "who may delegate" is policy the doc-op schema should carry
  from day one (`originActorId` exists on perm ops; reuse it).
- **Relay is a single point of liveness.** If the desktop dies, the phone has
  no peer to talk to (C2 chaos row assumes restart + reconnect). Acceptable
  for the one-main-device topology; name it, don't hide it.

### Named seams (files) for the implementation

| Seam | File |
| --- | --- |
| Task op schema + claim/complete | `packages/headless_core/lib/src/doc_replica.dart` (next to `announcePermRequest`, :297) |
| Host fold observer → delegate | `lib/coding_agent/agent_doc_surface.dart` (`refreshAfterMeshSync`, :227) + `StorageBackendsNotifier.onSyncCycle` (`lib/settings/features/storage_backends_state.dart:92-97`) |
| Phone verb `mesh_task_delegate` | `lib/coding_agent/agent_mcp_tools.dart` (mirror `mesh_open_doc`, :741) |
| Live delta stream session | `pkgs/universal_storage_mesh/lib/src/` (new `MeshStreamSession` beside `mesh_presence_session.dart`), carried by `AddressedRelayClient.sendEphemeral` |
| Sync-on-event triggers | `lib/coding_agent/harness_session_controller.dart` (`delegate` finally, :274; `_announcePermission`, :600) |
| Shadow rendering of streamed tail | `lib/coding_agent/agent_doc_surface.dart` (`AgentDocShadow.toDebugState`, :2212) |
| Gate | extend `docs/product/multiplayer-device-gates.md` T3 script: web delegates a task op → macOS runs the turn → web sees verdict + answers the permission → surfaces byte-identical |

### Bottom line

The architecture was explicitly designed for this feature (ADR 0005 §3:
"agents execute on the device that owns the workspace; every other peer holds
input rights … delivered as ops"), and the permission round-trip is a
complete, tested proof-of-pattern. What stands between "phone approves
desktop writes (eventually)" and "phone controls desktop agent (promptly)"
is: two op namespaces (task, turn transcript), one ephemeral stream session,
and sync-on-event triggers — plus honest non-goals around NAT and background
execution until a bridge node exists.
