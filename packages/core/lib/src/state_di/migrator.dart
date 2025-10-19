import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/parsers/parsers.dart' as parsers;

/// Discover archives, parse project data and persist into application local
/// storage via `ProjectsRepository`.
Future<void> migrate(final BuildContext context) async {
  // Use parser library to discover and return parsed project maps.
  final parsed = await parsers.parseAndPopulate();
  if (parsed.isEmpty) return;

  // Convert to ProjectModel and persist in one batch.
  final projects = parsed.map(ProjectModel.fromJson).toList(growable: false);

  try {
    await context.read<ProjectsRepository>().putAll(projects: projects);
    // small log for diagnostics
    print('Migrated ${projects.length} project(s) into local DB');
  } on Exception catch (e, st) {
    // report but don't crash the app during initialization
    print('Failed to persist migrated projects: $e\n$st');
  }
}
