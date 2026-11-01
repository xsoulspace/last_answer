# ADR 0025 — Conversation threads move onto the ConvergenceDoc kernel

- Status: Accepted (implementation landed; runtime evidence in
  [current-status.mdx](../evidence/current-status.mdx))
- Date: 2026-10-30
- North Star impact: `refines` — the durable threads of
  [0023](0023-chat-first-product-and-retire-materialization.md) and
  [0024](0024-actors-channels-and-panes.md) become kernel ops: delta-native,
  mesh-syncable conversation state instead of app-private journal rows.
- Builds on: [0024](0024-actors-channels-and-panes.md) (actors and channels
  over durable threads; the `channels` registry pattern),
  [0005](0005-doc-multiplayer-over-convergence-kernel.md) (the doc kernel:
  one document, one replica, kernel-owned convergence),
  [0023](0023-chat-first-product-and-retire-materialization.md) (the world
  chat substrate), ecsai ADR 0107 (one world per realm; app-support as the
  project scope; durable state never in `.dart_tool`).

## Context

`RealmWorld.conversation()` returned the harness's journal-backed
`DurableConversation`. Three costs came with it:

- Every read re-parsed the shared realm journal — 2.6 MB+ and growing,
  because the same journal carries the whole ecsaid daemon world. A quiet
  thread list cost a full journal parse.
- `wait` polled: the bot dispatcher's listening loop re-scanned the journal
  every ≤200 ms while idle — 100% busy waiting on the shared store.
- Beats lived as journal rows, unreachable by the ConvergenceDoc kernel: no
  version vectors, no op exchange, no mesh anti-entropy — conversation state
  could never leave the device through the doc-sync seams the rest of the
  product already rides.

## Decision

Threads become ConvergenceDoc replicas. One [DocReplica] per thread, keyed
by the EXISTING `thread-…` id (the `channels` registry references threadIds;
migration must keep them valid), persisted under LA's app-support project
scope at `<support>/world/threads/<threadId>.json` (ADR 0107 store law —
never `.dart_tool`), through a `DocReplicaStore` owned by the conversation
layer (not the mesh lifecycle store, which dies with `leaveMesh`).

- **Beats are kernel ops.** Block text = beat text (RGA lane); author /
  addressedTo / at / beat ride block fields (LWW lane); block order = beat
  order (fractional keys); the int beat counter is position + 1 (also
  written as a block field so migrated legacy numbers survive).
- **Thread metadata is node fields** on the doc's own node: topic, createdBy,
  createdAt, closed, closedAt, participants (saying auto-joins — the
  participants field updates in the same edit as the beat).
- **The journal keeps only cheap index records.** One LA-owned
  `thread_index` collection record per thread in the SAME realm control
  store (the `channels` pattern): threadId, topic, createdBy, createdAt,
  closed, participants, lastBeat, plus lastBeatAuthor / lastBeatText /
  lastBeatAt — so the service's preview projection stops scanning any beat
  store. Deviation from the working notes: the record lives in
  `thread_index`, NOT in the harness's `threads` collection — that
  collection is shared with the live ecsaid daemon and the migration law is
  "additive, never rewrite others' collections".
- **Ordering across stores: kernel edit first, index transact second.** A
  crash between them leaves the index lagging (previews, cursors) while
  beat reads stay correct — the doc is the truth, the record is the cache.
  The gap self-heals: an index-missing doc with a birth record rebuilds its
  index record on first touch, and every world open re-runs the migration
  pass, which rebuilds records from docs.
- **`wait` parks on change notifications (0% idle).** `DocReplicaStore`
  grows a minimal broadcast stream (`changes`: docId + new head) fired on
  every committed edit. `wait` scans once, parks on a completer armed before
  the scan (no missed-wakeup window), re-scans on wake, and falls back to
  `timeoutMs`. The timeout answer keeps the journal shape exactly: empty
  `beats`, the current cursors in `lastBeatByThread`, `timedOut: true` — the
  bot dispatcher's loop semantics are unchanged.
- **Verb surface preserved.** `RealmWorld.conversation()` now returns
  `KernelConversation` with method signatures and result-map shapes identical
  to the `DurableConversation` ones (open / say / read / list / close /
  wait), and the same `DurableRealmRefusal` codes (`thread_topic_missing`,
  `thread_not_visible`, `thread_closed`, `thread_text_too_large: …`,
  `thread_close_not_participant`). Authorization keys on `authority.actor`
  ONLY — never docId/projectId — because the same actor presents authorities
  built two ways in this codebase (`RealmWorld.authorityFor` and harness
  `RealmActorSession.authority`); both must work. Visibility is
  participation.
- **`RealmWorld.sessionFor(actorId)`** returns `RealmWorldSession`, a
  drop-in facade matching the harness `RealmActorSession` members the bot
  host uses (`authority`, `register({serves})`, `say(threadId, text,
  {addressedTo})`), with the say riding the kernel. realm_bot_host.dart is
  NOT edited here — a separate integration step swaps the two construction
  sites.
- **Migration (restart persistence must survive).** On open, journal legacy
  `threads` / `thread_beats` records of THIS project scope seed kernel docs
  (idempotent: a doc that was born is never re-seeded) and write their index
  records. Legacy records stay in place — the journal is shared with the
  live ecsaid daemon; nothing is deleted or rewritten.

## Consequences

- Thread reads and thread lists stop touching the journal entirely (index
  lives in memory; beats live in kernel replicas). The per-verb 2.6 MB
  journal re-parse is gone; journal writes shrink to one small index record
  per mutation.
- Conversation state becomes delta-native: beats can ship through doc-sync
  anti-entropy like every other kernel doc (a follow-up, not wired here).
- Follow-up for the harness (filed to its surface_gaps, not edited here):
  the ecsaid daemon can no longer SEE LA thread beats by scanning the
  journal — cross-process thread visibility becomes a projection (the daemon
  would need to follow kernel docs or read them through an exposed seam).
  Until the bot-host construction-site swap lands, bot replies still go
  through the journal `RealmActorSession.say` and are therefore not
  projected into kernel threads; the swap completes the move.
- `RealmChatService._refreshBeatPreviews` reads previews from the thread
  list records (the list result carries the preview triple) — no beat store
  scan, no signature-guarded journal reads.

## Non-goals

- Editing the harness repo or realm_bot_host.dart / actor_brain.dart (owned
  by a parallel effort).
- Daemon-side kernel following (the surface gap above).
- Mesh-routing thread docs automatically (they are kernel docs; the
  doc-sync wiring is a later slice).

## Amendment (2026-10-30): the replica home moves into the realm project area

Owner-approved ADR 0107 direction: ALL durable state lives under
`<device root>/.xsoulspace/` — one world per computer — and the macOS
app-support directory henceforth holds only disposable state.

- **New replica home.** Kernel thread docs persist under
  `<device root>/.xsoulspace/worlds/<realm id>/project/lastanswer/threads/`
  (`RealmWorld.realmThreadsHome()`); the directory name stays
  `KernelConversation.threadsDirName` — the one home derivation, so no
  path literal is scattered. The hermetic shape stays inside the
  override: `<override>/threads`.
- **The project-scope root STRING is unchanged.** `<support>/world`
  still seals authorities and membership records and filters the
  journal legacy migration; only the replica DIRECTORY moved, so
  nothing that keys on `projectRoot` sees a difference.
- **Migration is copy-not-move.** On world open, every file in the old
  in-scope home (`<root>/threads`) that the new home lacks is COPIED
  across. The old copies stay in place as a safety net — never deleted,
  never rewritten — and nothing durable is counted or logged. The live
  threads of a running installation therefore survive the upgrade on
  first open after this change.
- **Idempotent by construction.** A name already present in the new
  home is never overwritten (the new home is authoritative after the
  first open); a missing old home is a clean no-op; reopening adopts
  nothing anew.
- **The filesystem provider's `.us` durability area moves with the
  replicas** (it is replica recovery state, based at the replica
  home's parent), so app-support keeps nothing durable after the first
  post-upgrade open.
