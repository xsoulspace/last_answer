/// ADR 0026 — the workspace model: the durable container the rail's
/// WORKSPACES section points at.
///
/// A **workspace** is the user's selected slice of the filesystem and
/// project world — the north star's "documents/workspaces are the
/// shared world" read at the model layer:
///
/// - **Multi-root**: a workspace names MANY user-selected folders
///   ([folderPaths]), the VSCode multi-root shape.
/// - **Projects live inside**: at least one project belongs to a
///   workspace ([projectIds]); notes, ideas and docs are file types in
///   its folders, each with its own customized editor surface (later
///   waves — this slice is model + registry + rail).
/// - **Nesting is a graph, not a tree**: a workspace may name MANY
///   parents ([parentIds]) — the same workspace can appear under more
///   than one parent, and a folder may appear in several workspaces.
///   A workspace with zero parents is a **root workspace**.
///
/// The record is a dumb durable value: policy (cycle refusal, detach
/// semantics, query projections) lives in [WorkspaceRegistry].
library;

import 'dart:math';

import 'package:flutter/foundation.dart' show immutable;

import 'package:path/path.dart' as p;

/// The stable identity of one workspace
/// (`workspace-` + 24 hex chars).
typedef WorkspaceId = String;

/// One registered workspace: name, folders, parents, projects.
@immutable
final class Workspace {
  Workspace({
    required this.id,
    required String name,
    required this.createdAt,
    Iterable<String> folderPaths = const <String>[],
    Iterable<WorkspaceId> parentIds = const <WorkspaceId>{},
    Iterable<String> projectIds = const <String>{},
  }) : name = validateName(name),
       folderPaths = List<String>.unmodifiable([
         for (final path in folderPaths) normalizeFolderPath(path),
       ]),
       parentIds = Set<WorkspaceId>.unmodifiable(parentIds),
       projectIds = Set<String>.unmodifiable(projectIds);

  factory Workspace.fromRecord(final Map<String, Object?> record) =>
      Workspace(
        id: record['id']! as String,
        name: record['name']! as String,
        folderPaths: (record['folderPaths']! as List).cast<String>(),
        parentIds: (record['parentIds']! as List).cast<WorkspaceId>(),
        projectIds: (record['projectIds']! as List).cast<String>(),
        createdAt: record['createdAt']! as String,
      );

  /// The stable identity — equality is by id and nothing else.
  final WorkspaceId id;

  /// The user-facing name (non-empty after trim; duplicates allowed —
  /// the id is the identity, names are chrome).
  final String name;

  /// The user-selected absolute, normalized folder paths (multi-root;
  /// may stay empty until folders are chosen).
  final List<String> folderPaths;

  /// The workspaces this one nests under (MANY allowed = overlapping
  /// nesting; zero = a root workspace).
  final Set<WorkspaceId> parentIds;

  /// The projects belonging to this workspace (>= 1 recommended, not
  /// enforced at rest).
  final Set<String> projectIds;

  /// ISO-8601 UTC instant; `list()` orders by it, oldest first.
  final String createdAt;

  /// Refuses an empty or whitespace-only name, returns it trimmed.
  static String validateName(final String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'workspace name is empty');
    }
    return trimmed;
  }

  /// Validates and normalizes one folder path: absolute and in normal
  /// form (`.`/`..`/duplicate separators resolved), so the same folder
  /// always carries the same spelling inside the store.
  static String normalizeFolderPath(final String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(path, 'path', 'folder path is empty');
    }
    final normalized = p.normalize(trimmed);
    if (!p.isAbsolute(normalized)) {
      throw ArgumentError.value(
        path,
        'path',
        'folder path must be absolute',
      );
    }
    return normalized;
  }

  Map<String, Object?> toRecord() => <String, Object?>{
    'id': id,
    'name': name,
    'folderPaths': List<String>.of(folderPaths),
    'parentIds': List<WorkspaceId>.of(parentIds)..sort(),
    'projectIds': List<String>.of(projectIds)..sort(),
    'createdAt': createdAt,
  };

  Workspace copyWith({
    String? name,
    List<String>? folderPaths,
    Set<WorkspaceId>? parentIds,
    Set<String>? projectIds,
  }) => Workspace(
    id: id,
    name: name ?? this.name,
    folderPaths: folderPaths ?? this.folderPaths,
    parentIds: parentIds ?? this.parentIds,
    projectIds: projectIds ?? this.projectIds,
    createdAt: createdAt,
  );

  /// Equality by id (ADR 0026 D1): two records naming the same id ARE
  /// the same workspace, whatever their field drift.
  @override
  bool operator ==(final Object other) =>
      other is Workspace && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Workspace($id, $name, folders: $folderPaths, '
      'parents: $parentIds, projects: $projectIds)';
}

/// `workspace-` + 24 hex chars from [Random.secure] (12 random bytes —
/// byte-identical in shape to the channels collection's
/// `channel-<id>` mint, so one id shape spans the world's LA-owned
/// records).
WorkspaceId mintWorkspaceId() {
  final random = Random.secure();
  return 'workspace-${List<String>.generate(
    12,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join()}';
}
