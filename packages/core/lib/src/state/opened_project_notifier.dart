part of 'state.dart';

class OpenedProjectNotifierDto {
  OpenedProjectNotifierDto(final BuildContext context)
      : projectsNotifier = context.read();
  final ProjectsNotifier projectsNotifier;
}

class OpenedProjectNotifier
    extends ValueNotifier<LoadableContainer<ProjectModel>> {
  OpenedProjectNotifier({required this.dto})
      : super(LoadableContainer(value: ProjectModel.emptyNote));

  factory OpenedProjectNotifier.provide(final BuildContext context) =>
      OpenedProjectNotifier(
        dto: OpenedProjectNotifierDto(context),
      );

  final OpenedProjectNotifierDto dto;

  void loadProject({
    required final ProjectModel project,
    required final BuildContext context,
  }) {
    if (value.isLoaded) {
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
      );
    }
    setValue(LoadableContainer.loaded(project));

    final path = switch (project.type) {
      ProjectTypes.note => ScreenPaths.note(noteId: project.id),
      ProjectTypes.idea => ScreenPaths.idea(ideaId: project.id),
    };
    unawaited(context.push(path));
  }

  void updateProject(final ProjectModel item) {
    setValue(value.copyWith(value: item));
    dto.projectsNotifier.updateProject(item);
  }

  void createNoteProject(final BuildContext context) {
    final note = ProjectModelNote(
      id: ProjectModelId.generate(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      title: title,
    );
    if (title.isNotEmpty) dto.projectsNotifier.updateProject(idea);
    loadProject(context: context, project: idea);
  }

  void deleteProject() {
    if (value.isLoading) return;
    final item = value.value;
    setValue(LoadableContainer(value: ProjectModel.emptyNote));
    dto.projectsNotifier.deleteProject(item);
  }
}
