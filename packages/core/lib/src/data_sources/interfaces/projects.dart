import '../../data_models/data_models.dart';
import '../../foundation/foundation.dart';
import '../../state/projects_paged_requests_builder.dart';

abstract interface class ProjectsLocalDataSource {
  Future<void> putAll({required final List<ProjectModel> projects});
  Future<void> put({required final ProjectModel project});
  Future<void> remove({required final ProjectModelId id});
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  });
}
