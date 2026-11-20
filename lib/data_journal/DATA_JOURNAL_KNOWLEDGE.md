# DATA_JOURNAL_KNOWLEDGE.md

**Owns:** the realm journal backend — services that read, fold and drive the
append-only journal (the ONE authority): chat verbs (RealmChatService), world
state projections, actor roster/bindings/creation, kernel conversation verbs,
work-thread spawn, beat linkify, chat media, plus the mesh durability lane
(`mesh/` — live mesh service, storage, relay host io/stub).

**Key files:** `note_asset_store.dart` (the legacy note-image FILE plane: `note-assets/<noteId>/…`, mime sniff, containment guard, backup/restore sinks — survives the legacy-UI retirement), `realm_chat_service.dart` (the verbs everything rides),
`world_state_service.dart` (presence/state fold), `kernel_conversation.dart`
(ADR 0025 thread/beat verbs), `mesh/live_mesh_service.dart`.

**How to extend:** a new journal verb goes through `realm_chat_service.dart`;
a new durable store lane gets a `mesh/` file + one line here. UI domains read
through this folder's exports, never through another UI domain. `journal_contracts.dart`
carries the row shapes other layers fold (`ActorTelemetry`) — `ecs_world/`
consumes the contract, never this service (the former inversion, applied
2026-11-20).
