/// Pure-Dart domain model, replication, and agent transport for Last Answer.
///
/// Implements the recursive document node model (ADR 0001), the storage
/// repositories behind it (ADR 0002), the doc↔op replication layer over the
/// convergence kernel (ADR 0005), and the agent transports (ACP runtime,
/// inference ports, permission routing). No Flutter dependencies — usable
/// from the app, the headless `bin/` CLI, TUI/serve mode, and tests.
///
/// Folder grammar mirrors the app's (ARCHITECTURE.md): `data_models/` holds
/// serializable domain value types, `data_replication/` the doc↔kernel
/// layer, `data_storage/` the repository ladder, `data_agents/` the agent
/// transports, `services/` the orchestration services, `workbench/` the
/// workbench verbs. Barrels are the public API.
library;

export 'data_agents/data_agents.dart';
export 'data_models/data_models.dart';
export 'data_replication/data_replication.dart';
export 'data_storage/data_storage.dart';
export 'services/services.dart';
export 'workbench/workbench.dart'; // single-file folder: the file IS the barrel
