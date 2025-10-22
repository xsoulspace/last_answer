part of 'state.dart';

final class ProjectsPagedController extends BasePagingController<ProjectModel> {
  ProjectsPagedController({required this.requestBuilder})
    : super(firstPageKey: 1);
  @override
  final ProjectsPagedDataRequestsBuilder requestBuilder;
}
