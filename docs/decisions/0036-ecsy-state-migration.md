# ADR 0036: ecsly state migration — tier law and wave plan

Date: 2026-11-20
Status: accepted (wave 1 applied)
Deciders: owner (directed the ecsly resources/components migration), steward-executed

## Context

The state-placement law says "with ecsly + ecsly_flutter, resources/commands
ARE the state layer" — yet zero ecsly Resources existed, and every hot state
holder was a ChangeNotifier with allocation-heavy habits:

- `HarnessSessionController` notified listeners per streamed delta and the
  agent-doc surface rebuilt entirely per notify; `HarnessTurn.displayedText`
  re-joined the provisional buffers on every read (O(n²) chars churn per
  turn).
- `LaWorld.unreadByThread()` rebuilt an N-room map per call, and the rail's
  per-row selectors called it — N rows × N rooms per notify.
- Chat's `RealmChatService` refolds map-rows lists per 300 ms journal tick
  and allocates `List.unmodifiable` wrappers inside `build`.

The migration's purpose is GC-footprint reduction, not uniformity.

## Decision

**Tier law.** Typed columns (`Int32List`-style, generated `@EcsComponent`)
are for HOT data: streaming text/counters mutated per frame or per delta.
`ObjectColumn` heap rows (today's LaWorld rows) are for COLD batch-fed data
— the ObjectColumn doc's own rule ("only for data that isn't processed 60
times per second"). Cold settings-scale state (emoji, tags, user settings,
purchases) stays provider-backed **by law** — migration churn exceeds any
GC payoff there.

**Wave 1 (applied now):**
1. Streaming notify coalescing: `HarnessSessionController._scheduleNotify`
   folds the per-delta `notifyListeners()` calls of `onText` / text-phase
   `onHostUpdate` into one notify per event-loop turn; structural events
   (session, verdict, permission, error) keep the immediate notify.
2. `HarnessTurn.displayedText` caches behind a dirty flag invalidated by
   `observeText` — writes invalidate, reads reuse the join.
3. `LaWorld.unreadByThread()` cached per commit batch (`_unreadByThreadCache`,
   invalidated in `commitBatch()` — the only mutation boundary), and the new
   `unreadFor(threadId)` gives the rail/strip per-row selectors an O(1) row
   read instead of the N×N map rebuild.
4. `tool/perf/stream_bench.dart` — the 10k-delta meter for the streaming
   path (wall time, notify count, displayedText re-derivations).

**Roadmap rows (documented, not built):**
- Chat threads/beats → an ecsly world projection extending `LaWorldFeed`
  (threads already project to `RoomRow`; beats become a keyed row set), the
  chat surface reading via `EcsWorldSelector` with record-snapshot equality.
- Doc-save debounce: per-keystroke `jsonEncode` ×2 + two file writes in
  `StorageDocumentRepository` — an IO-layer fix (batched flush), not ECS.
- `WorldStateService` telemetry → fold into the existing `TelemetryRow`
  column instead of fresh `List.unmodifiable` projections per refresh.
- Harness turns as typed components (`ecs_plugins/harness_session/`): once
  the coalesced-notify shape proves out live, turn/tool-call counters move
  to typed columns with one `EcsController` flush per drain.

## Falsifiers

If the coalesced notify makes streaming feel laggy (one frame behind), the
event-loop turn is the wrong boundary — move to per-frame flush. If the
unread cache desyncs from identity resolution in practice (not just theory),
invalidate on the identity future instead of the batch. If no measured GC/
jank delta appears after the roadmap waves, the migration over-reached —
revert the cold-state moves first.
