/// Pure-Dart domain model and storage repositories for Last Answer.
///
/// Implements the recursive document node model (ADR 0001) and the storage
/// repositories behind it (ADR 0002). No Flutter dependencies — usable from
/// the app, TUI, CLI, headless serve mode, and tests.
library;

export 'src/document_node.dart';
export 'src/document_repository.dart';
export 'src/in_memory_document_repository.dart';
export 'src/storage_document_repository.dart';
