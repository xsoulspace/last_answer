import 'dart:convert';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/parsers/parsers.dart' as parsers;

/// Core migration entry used by runtime initialization.
///
/// This function remains Flutter-aware and delegates to the pure-Dart
/// migration helper `migrateWithRepository` so tests can exercise migration
/// without requiring a `BuildContext`.
Future<void> migrate(final BuildContext context) async {
  final parsed = await parsers.parseAndPopulate();
  if (parsed.isEmpty) return;

  // Deduplicate parsed project maps by `id` when available to avoid
  // creating duplicate entries from multiple sources (hive + isar previews).
  final unique = <String, Map<String, dynamic>>{};
  for (final p in parsed) {
    try {
      final id = (p['id'] is String) ? p['id'] as String : jsonEncode(p);
      unique[id] = p;
    } catch (_) {
      unique[jsonEncode(p)] = p;
    }
  }
  final projects = unique.values
      .where((final e) => e['runtimeType'] != null)
      .map(ProjectModel.fromJson)
      .toList(growable: false);

  try {
    await context.read<ProjectsRepository>().putAll(projects: projects);
    print('Migrated ${projects.length} project(s) into local DB');
  } on Exception catch (e, st) {
    // report but don't crash the app during initialization
    print('Failed to persist migrated projects: $e\n$st');
  }
}

/// Pure-Dart migrator used by tests and CLI tools.
/// Accepts a `ProjectsRepository` to avoid depending on `BuildContext`.
Future<void> migrateWithRepository(final ProjectsRepository repository) async {
  final parsed = await parsers.parseAndPopulate();
  if (parsed.isEmpty) return;
  final unique = <String, Map<String, dynamic>>{};
  for (final p in parsed) {
    try {
      final id = (p['id'] is String) ? p['id'] as String : jsonEncode(p);
      unique[id] = p;
    } catch (_) {
      unique[jsonEncode(p)] = p;
    }
  }
  final projects = unique.values
      .map(ProjectModel.fromJson)
      .toList(growable: false);
  await repository.putAll(projects: projects);
}
