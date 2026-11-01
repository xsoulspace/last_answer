/// ADR 0026 — the workspace registry: the LA-owned `workspaces`
/// collection of the realm's ONE control store.
///
/// The registry is a dumb durable store over [RealmControlStore] — the
/// same pattern as the `channels` collection (ADR 0024 store law): one
/// record per workspace keyed by id, mutations as single read-modify-
/// write transactions, queries as scans. The constructor takes the
/// store, it never opens one: the service layer wires the world's
/// store in production, and a plain directory store (a
/// [RealmControlStore] over any directory) in hermetic tests.
///
/// Policy lives here only where the graph shape demands it: parent
/// edges may never close a cycle, so the roots query stays total and
/// every workspace stays reachable from the rail. `delete` detaches
/// child links and never recurses.
library;

import 'package:lastanswer/workspaces/workspace.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The LA-owned `workspaces` collection inside the realm's one control
/// store — the same store the threads and channels live in, never a
/// side table.
final class WorkspaceRegistry {
  WorkspaceRegistry({required this.store});

  final RealmControlStore store;

  static const _collection = 'workspaces';

  /// Creates one workspace. Folder paths are validated and normalized;
  /// every named parent must already exist. Names may repeat (the id is
  /// the identity).
  Future<Workspace> create({
    required final String name,
    final List<String> folderPaths = const <String>[],
    final Set<WorkspaceId> parentIds = const <WorkspaceId>{},
  }) async {
    final workspace = Workspace(
      id: mintWorkspaceId(),
      name: name,
      folderPaths: folderPaths,
      parentIds: parentIds,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    await store.transact((final tx) {
      for (final parentId in workspace.parentIds) {
        _requireRecord(tx, parentId, kind: 'parent');
      }
      tx.put(_collection, workspace.id, workspace.toRecord());
    });
    return workspace;
  }

  /// The workspace named [id], null when absent.
  Future<Workspace?> byId(final WorkspaceId id) async {
    final record = await store.read(_collection, id);
    return record == null ? null : Workspace.fromRecord(record);
  }

  /// All workspaces, oldest first (createdAt, then id for ties).
  Future<List<Workspace>> list() async => _decode(
    await store.scan(_collection),
  );

  Future<Workspace> rename(final WorkspaceId id, final String name) =>
      _mutate(id, (final workspace) => workspace.copyWith(name: name));

  /// Adds user-selected folders (validated, normalized, deduped, order
  /// preserved).
  Future<Workspace> addFolders(
    final WorkspaceId id,
    final Iterable<String> paths,
  ) => _mutate(id, (final workspace) {
    final next = List<String>.of(workspace.folderPaths);
    for (final path in paths) {
      final normalized = Workspace.normalizeFolderPath(path);
      if (!next.contains(normalized)) next.add(normalized);
    }
    return workspace.copyWith(folderPaths: next);
  });

  Future<Workspace> removeFolders(
    final WorkspaceId id,
    final Iterable<String> paths,
  ) => _mutate(id, (final workspace) {
    final drop = {
      for (final path in paths) Workspace.normalizeFolderPath(path),
    };
    return workspace.copyWith(
      folderPaths: [
        for (final path in workspace.folderPaths)
          if (!drop.contains(path)) path,
      ],
    );
  });

  /// Nests [id] under [parentId] — one parent edge of the many
  /// allowed. Refuses an unknown parent, self-parenting, and any edge
  /// that would close a cycle (a cycle would orphan every member from
  /// the roots query). Idempotent when the edge already exists.
  Future<Workspace> addParent(
    final WorkspaceId id,
    final WorkspaceId parentId,
  ) async {
    if (id == parentId) {
      throw StateError('a workspace cannot nest under itself ($id)');
    }
    late final Workspace result;
    await store.transact((final tx) {
      final record = tx.get(_collection, id);
      if (record == null) throw StateError('unknown workspace $id');
      _requireRecord(tx, parentId, kind: 'parent');
      if (_reachesWithin(tx, from: parentId, target: id)) {
        throw StateError(
          'nesting $id under $parentId would close a cycle',
        );
      }
      final workspace = Workspace.fromRecord(record);
      result = workspace.parentIds.contains(parentId)
          ? workspace
          : workspace.copyWith(
              parentIds: {...workspace.parentIds, parentId},
            );
      tx.put(_collection, id, result.toRecord());
    });
    return result;
  }

  /// Removes one parent edge (the workspace keeps existing; when its
  /// last parent goes it becomes a root).
  Future<Workspace> removeParent(
    final WorkspaceId id,
    final WorkspaceId parentId,
  ) => _mutate(
    id,
    (final workspace) => workspace.copyWith(
      parentIds: {...workspace.parentIds}..remove(parentId),
    ),
  );

  Future<Workspace> addProject(
    final WorkspaceId id,
    final String projectId,
  ) => _mutate(
    id,
    (final workspace) => workspace.copyWith(
      projectIds: {...workspace.projectIds, projectId},
    ),
  );

  Future<Workspace> removeProject(
    final WorkspaceId id,
    final String projectId,
  ) => _mutate(
    id,
    (final workspace) => workspace.copyWith(
      projectIds: {...workspace.projectIds}..remove(projectId),
    ),
  );

  /// Deletes one workspace. Child links detach (children naming it as
  /// parent lose exactly that edge and keep their other parents), the
  /// folders and projects on disk are untouched, and the deletion
  /// never recurses.
  Future<void> delete(final WorkspaceId id) => store.transact((final tx) {
    if (tx.get(_collection, id) == null) {
      throw StateError('unknown workspace $id');
    }
    for (final entry in tx.scan(_collection).entries) {
      final record = Workspace.fromRecord(entry.value);
      if (!record.parentIds.contains(id)) continue;
      tx.put(
        _collection,
        record.id,
        record.copyWith(
          parentIds: {...record.parentIds}..remove(id),
        ).toRecord(),
      );
    }
    tx.remove(_collection, id);
  });

  /// Root workspaces: those declaring zero parents.
  Future<List<Workspace>> roots() async => [
    for (final workspace in await list())
      if (workspace.parentIds.isEmpty) workspace,
  ];

  /// Workspaces naming [id] as a parent (one hop; the same child may
  /// also hang under other parents — overlap is the graph's point).
  Future<List<Workspace>> childrenOf(final WorkspaceId id) async => [
    for (final workspace in await list())
      if (workspace.parentIds.contains(id)) workspace,
  ];

  /// Workspaces whose folder list contains [path] exactly (after the
  /// same absolute+normal normalization the model enforces). The same
  /// folder may sit in several workspaces — this is the overlap query.
  Future<List<Workspace>> workspacesContainingFolder(
    final String path,
  ) async {
    final normalized = Workspace.normalizeFolderPath(path);
    return [
      for (final workspace in await list())
        if (workspace.folderPaths.contains(normalized)) workspace,
    ];
  }

  // ---- internals --------------------------------------------------------

  Future<Workspace> _mutate(
    final WorkspaceId id,
    final Workspace Function(Workspace workspace) update,
  ) async {
    late final Workspace result;
    await store.transact((final tx) {
      final record = tx.get(_collection, id);
      if (record == null) throw StateError('unknown workspace $id');
      result = update(Workspace.fromRecord(record));
      tx.put(_collection, id, result.toRecord());
    });
    return result;
  }

  /// True when the upward walk over parent edges from [from] reaches
  /// [target], reading only inside the transaction (no read/write
  /// race: the whole check rides the same lock as the edge write).
  bool _reachesWithin(
    final ControlTransaction tx, {
    required final WorkspaceId from,
    required final WorkspaceId target,
  }) {
    final byId = {
      for (final entry in tx.scan(_collection).entries)
        entry.key: Workspace.fromRecord(entry.value),
    };
    final seen = <WorkspaceId>{};
    final frontier = <WorkspaceId>[from];
    while (frontier.isNotEmpty) {
      final current = byId[frontier.removeLast()];
      if (current == null) continue;
      if (current.id == target) return true;
      for (final parent in current.parentIds) {
        if (seen.add(parent)) frontier.add(parent);
      }
    }
    return false;
  }

  void _requireRecord(
    final ControlTransaction tx,
    final WorkspaceId id, {
    required final String kind,
  }) {
    if (tx.get(_collection, id) == null) {
      throw StateError('unknown $kind workspace $id');
    }
  }

  List<Workspace> _decode(
    final Map<String, Map<String, Object?>> records,
  ) => [
    for (final record in records.values) Workspace.fromRecord(record),
  ]
    ..sort((final a, final b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
}
