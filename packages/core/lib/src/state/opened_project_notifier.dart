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
}
