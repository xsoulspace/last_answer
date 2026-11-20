/// The realm journal backend: services that read, fold and drive the
/// append-only journal (chat verbs, world state, work threads) plus the
/// mesh durability lane. Actor identity lives in `packages/headless_core`
/// (`ActorRoster`, ADR 0007). See JOURNAL_KNOWLEDGE.md.
library;

export 'realm_chat_service.dart';
export 'world_state_service.dart';
