/// The projects data concern: models (Project/Save), data sources, the
/// projects + tags repositories, the paged projects state, and the legacy
/// Hive/Isar migration. See DATA_PROJECTS_KNOWLEDGE.md.
library;

export 'data_sources/interfaces/projects.dart';
export 'data_sources/interfaces/tags.dart';
export 'data_sources/local/projects_web.dart';
export 'data_sources/local/tags.dart';
export 'doc_body_storage.dart';
export 'idea_questions.dart';
export 'migrations/migrate_from_hive_isar.dart';
export 'opened_project_notifier.dart';
export 'paged_requests.dart';
export 'project_models.dart';
export 'projects_notifier.dart';
export 'projects_paged_controller.dart';
export 'projects_paged_requests_builder.dart';
export 'projects_repository.dart';
export 'tags_notifier.dart';
