part of 'state.dart';

class OpenedProjectNotifierDto {
  OpenedProjectNotifierDto(final BuildContext context)
    : projectsNotifier = context.read(),
      userNotifier = context.read();
  final ProjectsNotifier projectsNotifier;
  final UserNotifier userNotifier;
}

class OpenedProjectNotifier
    extends ValueNotifier<LoadableContainer<ProjectModel>> {
  OpenedProjectNotifier(final BuildContext context)
    : dto = OpenedProjectNotifierDto(context),
      super(LoadableContainer(value: ProjectModel.emptyNote));

  final OpenedProjectNotifierDto dto;

  void loadProject({
    required final ProjectModel project,
    required final BuildContext context,
  }) {
    onPopProject();
    setValue(LoadableContainer.loaded(project));

    final path = switch (project.type) {
      ProjectTypes.note => ScreenPaths.note(noteId: project.id),
      ProjectTypes.idea => ScreenPaths.idea(ideaId: project.id),
      ProjectTypes.systemChangelog => ScreenPaths.changelog,
      ProjectTypes.doc => ScreenPaths.doc(docId: project.id),
    };
    unawaited(context.push(path));
  }

  void onPopProject({final ProjectModelId? expectedProjectId}) {
    if (value.isLoading) return;
    if (expectedProjectId != null && value.value.id != expectedProjectId) {
      return;
    }

    /// deleting current project, if its empty
    value.value.map(
      idea: (final idea) {
        if (idea.title.isNotEmpty || idea.answers.isNotEmpty) return;
        dto.projectsNotifier.deleteProject(idea);
      },
      note: (final note) {
        if (note.note.isNotEmpty) return;
        dto.projectsNotifier.deleteProject(note);
      },
      changelog: (final value) {
        // noop
      },
      doc: (final doc) {
        final hasNoContent =
            doc.title.isEmpty &&
            doc.blocks.every((final b) => b.content.isEmpty);
        if (hasNoContent) dto.projectsNotifier.deleteProject(doc);
      },
    );
  }

  void updateProject(final ProjectModel item) {
    // A background/addressed page may save while another item is selected.
    // Persistence belongs to its explicit ID; it must not steal selection.
    if (value.value.id == item.id) setValue(value.copyWith(value: item));
    dto.projectsNotifier.updateEditingProject(item);
  }

  List<ProjectTagModelId> get _tagsIds => [dto.projectsNotifier.selectedTagId];
  void createNoteProject(final BuildContext context) {
    final note = ProjectModelNote(
      id: ProjectModelId.generate(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tagsIds: _tagsIds,
      charactersLimit: dto.userNotifier.settings.charactersLimitForNewNotes,
    );
    loadProject(context: context, project: note);
  }

  void createIdeaProject({
    required final BuildContext context,
    required final String title,
  }) {
    final idea = ProjectModelIdea(
      id: ProjectModelId.generate(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tagsIds: _tagsIds,
      title: title,
    );
    if (title.isNotEmpty) dto.projectsNotifier.updateEditingProject(idea);
    loadProject(context: context, project: idea);
  }

  /// ADR 0003 — Agents live in docs (Phase 1): a new agent doc. A null
  /// [worldBinding] (the default) binds the embedded in-process world; a
  /// binding opts the doc into an external, user-chosen harness world.
  void createAgentProject(
    final BuildContext context, {
    final WorldBindingModel? worldBinding,
  }) {
    loadProject(
      context: context,
      project: ProjectModel.emptyAgent(worldBinding: worldBinding),
    );
  }

  void createChatProject(final BuildContext context) {
    loadProject(context: context, project: ProjectModel.emptyChat());
  }

  void deleteProject({final ProjectModel? project}) {
    if (project == null && value.isLoading) return;
    final item = project ?? value.value;
    if (value.value.id == item.id) {
      setValue(LoadableContainer(value: ProjectModel.emptyNote));
    }
    dto.projectsNotifier.deleteProject(item);
  }
}
