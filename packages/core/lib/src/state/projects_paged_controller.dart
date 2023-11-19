part of 'state.dart';

final class ProjectsPagedController
    extends ExternalPagedController<ProjectModel> {
  ProjectsPagedController({
    required this.requestBuilder,
  });
  @override
  final ProjectsPagedDataRequestsBuilder requestBuilder;
}
