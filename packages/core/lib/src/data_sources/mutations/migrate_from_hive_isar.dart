// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:from_json_to_json/from_json_to_json.dart';
// import 'package:shared_models/shared_models.dart';
import 'package:is_dart_empty_or_not/is_dart_empty_or_not.dart';
import 'package:provider/provider.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../data_models/data_models.dart';
import '../../data_repositories/data_repositories.dart';
import 'parsers/parsers.dart' as parsers;

/// Core migration entry used by runtime initialization.
///
/// This function remains Flutter-aware and delegates to the pure-Dart
/// migration helper `migrateWithRepository` so tests can exercise migration
/// without requiring a `BuildContext`.
Future<void> migrateFromHiveAndIsar(final BuildContext context) async {
  try {
    final tagsRepository = context.read<TagsRepository>();
    final projectsRepository = context.read<ProjectsRepository>();
    final parsed = await parsers.parseOldFiles();
    if (parsed.isEmpty) return;

    // Deduplicate parsed project maps by `id` when available to avoid
    // creating duplicate entries from multiple sources (hive + isar previews).
    final unique = <String, Map<String, dynamic>>{};
    final idTypeMap = <String, String>{}; // id -> type
    for (final p in parsed) {
      try {
        final id = jsonDecodeString(p['id']);
        if (id.isEmpty) continue;
        idTypeMap[id] = jsonDecodeString(
          p['runtimeType'],
        ).whenEmptyUse(p['type']);
        final oldUnique = unique[id];
        unique[id] = {...?oldUnique, ...p};
      } catch (_) {}
    }
    final allAnswers = <IdeaProjectAnswerModel>[];

    final parsedProjects = unique.values
        .map((final e) {
          final type = idTypeMap[e['id']];
          if (type == 'changelog') return null;
          if (e['question'] != null) {
            final answer = IdeaProjectAnswerModel.fromJson(e);
            allAnswers.add(answer);
            return null;
          }
          return e
            ..['type'] = type
            ..['runtimeType'] = type;
        })
        .nonNulls
        .map(ProjectModel.fromJson)
        .toList(growable: false);

    for (final project in parsedProjects) {
      final oldProject = await projectsRepository.getById(id: project.id);
      final mergedJson = {...project.toJson(), ...?oldProject?.toJson()};
      final updatedProject = ProjectModel.fromJson(mergedJson);
      await projectsRepository.put(project: updatedProject);
    }

    if (allAnswers.isNotEmpty) {
      await projectsRepository.put(
        project: ProjectModel.idea(
          id: ProjectModelId.generate(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          answers: allAnswers,
          title: 'ALL SAVED ANSWERS',
        ),
      );
    }

    final existingTags = await tagsRepository.getAll();
    final tags = parsedProjects
        .expand((final p) => p.tagsIds)
        .toSet()
        .indexed
        .toMap(
          toKey: (final e) => e.$2,
          toValue: (final e) {
            final existingTag = existingTags[e.$2];
            final data = ProjectTagModel(
              id: e.$2,
              title: existingTag?.title ?? e.$1.toString(),
            );
            return data;
          },
        );

    /// populate cache of tags
    tagsRepository.putAll(tags);
    // await removeDbFiles();
  } on Exception catch (_) {}
}

/// Pure-Dart migrator used by tests and CLI tools.
/// Accepts a `ProjectsRepository` to avoid depending on `BuildContext`.
@visibleForTesting
Future<void> migrateWithRepository(final ProjectsRepository repository) async {
  final parsed = await parsers.parseOldFiles();
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
