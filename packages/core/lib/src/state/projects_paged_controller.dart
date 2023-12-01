part of 'state.dart';

final class ProjectsPagedController
    extends ExternalPagedController<ProjectModel> {
  ProjectsPagedController({
    required this.requestBuilder,
  }) : super(firstPageKey: 0);
  @override
  final ProjectsPagedDataRequestsBuilder requestBuilder;
}
