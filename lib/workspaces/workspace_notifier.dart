/// ADR 0026 — the workspace notifier: the rail's one live projection
/// of the `workspaces` collection.
///
/// A small [ChangeNotifier] between the dumb [WorkspaceRegistry] and
/// the shell: it lazily opens the world's control store (the SAME
/// realm store [RealmWorld] already backs — never a second world),
/// holds the loaded list as state, and re-reads it after every
/// mutation. Selection is deliberately NOT here yet: the rail owns it
/// locally for this slice (the workspace's surface — the file tree —
/// arrives in a later wave and will promote selection into durable
/// state).
library;

import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/workspaces/workspace.dart';
import 'package:lastanswer/workspaces/workspace_registry.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The rail's live workspace list over the realm's one control store.
final class WorkspaceNotifier extends ChangeNotifier {
  /// The production constructor wires the world's own store loader;
  /// tests pass a hermetic [WorkspaceRegistry] or a loader over a
  /// plain directory store instead.
  WorkspaceNotifier({
    Future<RealmControlStore?> Function()? storeLoader,
    WorkspaceRegistry? registry,
  }) : _storeLoader = storeLoader ?? _openWorldStore,
       // The public parameter name stays `registry:`; the field is
       // private so only ensureLoaded assigns it after opening the
       // store.
       // ignore: prefer_initializing_formals
       _registry = registry;

  /// Opens the realm's ONE control store through the world singleton —
  /// the same store the conversations and channels ride. Web has no
  /// filesystem: the loader answers null and the notifier renders the
  /// honest unsupported state.
  static Future<RealmControlStore?> _openWorldStore() async =>
      (await RealmWorld.open())?.store;

  final Future<RealmControlStore?> Function() _storeLoader;

  WorkspaceRegistry? _registry;

  Future<void>? _loading;

  List<Workspace> _workspaces = const <Workspace>[];
  bool _loaded = false;
  bool _unsupported = false;
  String? _loadError;

  /// The loaded workspaces, oldest first; empty until [ensureLoaded]
  /// succeeds (or when no store is available).
  List<Workspace> get workspaces => _workspaces;

  /// Whether the first load attempt finished (successfully or not).
  bool get loaded => _loaded;

  /// True when this platform has no durable store (web) or the store
  /// failed to open — the rail renders the quiet empty state, and a
  /// failure reason stays readable in [loadError].
  bool get unsupported => _unsupported;

  /// The load failure, when [unsupported] was set by an error instead
  /// of a missing filesystem.
  String? get loadError => _loadError;

  /// Loads once; later calls join the first load. Never throws —
  /// callers read [loaded]/[unsupported]/[workspaces] afterwards.
  Future<void> ensureLoaded() =>
      _loading ??= () async {
        try {
          final store = await _storeLoader();
          if (store == null) {
            _unsupported = true;
            return;
          }
          final registry = _registry ??= WorkspaceRegistry(store: store);
          _workspaces = await registry.list();
        } on Object catch (error) {
          _unsupported = true;
          _loadError = error.toString();
        } finally {
          _loaded = true;
          notifyListeners();
        }
      }();

  /// Creates one workspace (name-only is valid; folders attach later).
  /// Null when the store is unavailable or the record was refused —
  /// the caller surfaces that inline; real store failures surface the
  /// same way (the registry stays the strict, tested authority).
  Future<Workspace?> create({
    required final String name,
    final List<String> folderPaths = const <String>[],
  }) => _apply(
    (final registry) => registry.create(name: name, folderPaths: folderPaths),
  );

  Future<Workspace?> rename(final WorkspaceId id, final String name) =>
      _apply((final registry) => registry.rename(id, name));

  Future<Workspace?> addFolders(
    final WorkspaceId id,
    final Iterable<String> paths,
  ) => _apply((final registry) => registry.addFolders(id, paths));

  Future<Workspace?> removeFolders(
    final WorkspaceId id,
    final Iterable<String> paths,
  ) => _apply((final registry) => registry.removeFolders(id, paths));

  Future<Workspace?> addParent(
    final WorkspaceId id,
    final WorkspaceId parentId,
  ) => _apply((final registry) => registry.addParent(id, parentId));

  Future<Workspace?> removeParent(
    final WorkspaceId id,
    final WorkspaceId parentId,
  ) => _apply((final registry) => registry.removeParent(id, parentId));

  Future<Workspace?> addProject(
    final WorkspaceId id,
    final String projectId,
  ) => _apply((final registry) => registry.addProject(id, projectId));

  Future<Workspace?> removeProject(
    final WorkspaceId id,
    final String projectId,
  ) => _apply((final registry) => registry.removeProject(id, projectId));

  /// Deletes one workspace (the registry detaches child links; nothing
  /// recurses). A racing delete is already the requested end state.
  Future<void> delete(final WorkspaceId id) async {
    final registry = _registry;
    if (registry == null) return;
    try {
      await registry.delete(id);
      await _reload(registry);
    } on Object {
      // Already gone (a racing delete) — the projection is honest.
    }
  }

  // ---- internals --------------------------------------------------------

  Future<Workspace?> _apply(
    final Future<Workspace> Function(WorkspaceRegistry registry) mutation,
  ) async {
    final registry = _registry;
    if (registry == null) return null;
    try {
      final workspace = await mutation(registry);
      await _reload(registry);
      return workspace;
    } on Object {
      return null;
    }
  }

  Future<void> _reload(final WorkspaceRegistry registry) async {
    _workspaces = await registry.list();
    notifyListeners();
  }
}
