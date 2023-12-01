import '../../../core.dart';

abstract interface class ProjectsLocalDataSource {
  Future<void> putAll({required final List<ProjectModel> projects});
  Future<void> put({required final ProjectModel project});
  Future<void> remove({required final ProjectModelId id});
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  });
}
