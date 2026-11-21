import 'package:lastanswer/data_projects/project_models.dart';
import 'package:lastanswer/data_projects/projects_paged_requests_builder.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';


final class ProjectsPagedController extends BasePagingController<ProjectModel> {
  ProjectsPagedController({required this.requestBuilder})
    : super(firstPageKey: 1);
  @override
  final ProjectsPagedDataRequestsBuilder requestBuilder;
}
