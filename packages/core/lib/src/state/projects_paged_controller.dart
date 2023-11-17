import 'package:ui_kit/ui_kit.dart';

import '../../core.dart';
import 'projects_paged_requests_builder.dart';

final class ProjectsPagedController
    extends ExternalPagedController<ProjectModel> {
  ProjectsPagedController({
    required this.requestBuilder,
  });
  @override
  final ProjectsPagedDataRequestsBuilder requestBuilder;
}
