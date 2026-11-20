import 'package:lastanswer/common_imports.dart';

/// The ADR 0002 "explicit, user-visible migration" for the legacy idea/note
/// surfaces, in its smallest useful form: ON-DEMAND, IDEMPOTENT, NON-
/// DESTRUCTIVE conversion at open time.
///
/// - Opening a legacy note/idea converts it ONCE into a `ProjectModelDoc`
///   with a DETERMINISTIC id (`legacy-note-<id>` / `legacy-idea-<id>`), so
///   re-opening finds the converted doc instead of duplicating it.
/// - The ORIGINAL row is never rewritten or deleted — it stays in the store
///   and in every backup payload (`DbSaveModel.projects`); the converted doc
///   is a new row alongside it. Note image FILES stay in the
///   `note-assets/` plane (`data_journal/note_asset_store.dart`) and keep
///   riding zip backups.
/// - Known follow-up: the documents grid still lists the original rows next
///   to their converted docs; dedup/hiding is a separate decision.
class LegacyProjectMigration {
  static ProjectModelId docIdFor(final ProjectModel legacy) => ProjectModelId(
    switch (legacy) {
      ProjectModelIdea(:final id) => 'legacy-idea-${id.value}',
      ProjectModelNote(:final id) => 'legacy-note-${id.value}',
      _ => throw ArgumentError('only idea/note rows migrate', 'legacy'),
    },
  );

  static String _titleFor(final ProjectModel legacy) => switch (legacy) {
    ProjectModelIdea(:final title) => title,
    ProjectModelNote(:final note) => () {
      final firstLine = note
          .split('\n')
          .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
      final trimmed = firstLine.trim();
      return trimmed.length > ProjectModel.titleLimit
          ? trimmed.substring(0, ProjectModel.titleLimit)
          : trimmed;
    }(),
    _ => '',
  };

  static List<DocBlockModel> _blocksFor(
    final ProjectModel legacy, {
    required final String Function(LocalizedTextModel) localizeQuestion,
  }) => switch (legacy) {
    ProjectModelNote(:final note) => [
      for (final chunk in note.split('\n\n'))
        if (chunk.trim().isNotEmpty)
          DocBlockModel(
            id: DocBlockId.generate(),
            type: DocBlockType.paragraph,
            content: chunk.trim(),
          ),
    ],
    ProjectModelIdea(:final title, :final answers) => [
      DocBlockModel(
        id: DocBlockId.generate(),
        type: DocBlockType.heading,
        content: title,
        level: 1,
      ),
      for (final answer in answers) ...[
        DocBlockModel(
          id: DocBlockId.generate(),
          type: DocBlockType.heading,
          content: localizeQuestion(answer.question.title),
          level: 2,
        ),
        if (answer.text.trim().isNotEmpty)
          DocBlockModel(
            id: DocBlockId.generate(),
            type: DocBlockType.paragraph,
            content: answer.text.trim(),
          ),
      ],
    ],
    _ => const [],
  };

  /// Convert (or load the already-converted doc) and persist it. Idempotent.
  static Future<ProjectModelDoc> migrateToDoc(
    final ProjectModel legacy, {
    required final ProjectsRepository repository,
    required final String Function(LocalizedTextModel) localizeQuestion,
  }) async {
    final docId = docIdFor(legacy);
    final existing = await repository.getById(id: docId);
    if (existing case final ProjectModelDoc doc) return doc;
    final doc = ProjectModel.doc(
      id: docId,
      createdAt: legacy.createdAt,
      updatedAt: DateTime.now(),
      formatId: '',
      title: _titleFor(legacy),
      type: ProjectTypes.doc,
      tagsIds: legacy.map(
        idea: (value) => value.tagsIds,
        note: (value) => value.tagsIds,
        changelog: (value) => value.tagsIds,
        doc: (value) => value.tagsIds,
      ),
      blocks: _blocksFor(legacy, localizeQuestion: localizeQuestion),
    );
    await repository.put(project: doc);
    return doc as ProjectModelDoc;
  }
}
