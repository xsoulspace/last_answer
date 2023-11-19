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

  void loadProject(final ProjectModel item) {
    setValue(LoadableContainer.loaded(item));
  }

  void updateProject(final ProjectModel item) {
    setValue(value.copyWith(value: item));
    dto.projectsNotifier.updateProject(item);
  }
}
