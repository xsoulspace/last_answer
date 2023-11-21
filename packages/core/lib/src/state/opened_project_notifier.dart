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

  void deleteProject() {
    if (value.isLoading) return;
    final item = value.value;
    setValue(LoadableContainer(value: ProjectModel.emptyNote));
    dto.projectsNotifier.deleteProject(item);
  }
}
