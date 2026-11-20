/// The compressed reader path over the dissolved `coding_agent/` mega-folder
/// (2026-11-19 folder-grammar restructure, docs/ARCHITECTURE.md). The domain
/// now lives in `journal/` (realm services over the journal), `chat/` (the
/// chat experience), `ecs_plugins/` (per-plugin ecsly integrations),
/// `data_agents/` (the agent APIs: harness, ACP, subscriptions, product ops)
/// and `ui_inspector/` / `ui_boards/` / `ui_documents/` (surfaces). New code
/// goes to those homes; this barrel only keeps existing callers compiling.
library;

export 'data_agents/harness/harness_host.dart';
export 'data_agents/harness/harness_session_controller.dart';
export 'data_agents/harness/turn_queue.dart';
export 'ui_documents/agent_doc_surface.dart';
