import '../../foundation/foundation.dart';
import '../../models/models.dart';

abstract base class ProjectsLocalDataSource {
  Future<void> putAll({required final List<ProjectModel> projects});
  Future<void> put({required final ProjectModel project});
  Future<void> remove({required final ProjectModelId id});
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<GetProjectsDto> dto,
  });
}
